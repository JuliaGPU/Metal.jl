# broadcasting

using Base.Broadcast: BroadcastStyle, Broadcasted

struct MtlArrayStyle{N,S} <: AbstractGPUArrayStyle{N} end
MtlArrayStyle{M,S}(::Val{N}) where {N,M,S} = MtlArrayStyle{N,S}()

# identify the broadcast style of a (wrapped) MtlArray
BroadcastStyle(::Type{<:MtlArray{T,N,S}}) where {T,N,S} = MtlArrayStyle{N,S}()
BroadcastStyle(W::Type{<:WrappedMtlArray{T,N}}) where {T,N} =
    MtlArrayStyle{N, storagemode(Adapt.unwrap_type(W))}()

# when we are dealing with different buffer styles, we cannot know
# which one is better, so use shared memory
BroadcastStyle(::MtlArrayStyle{N, S1},
               ::MtlArrayStyle{N, S2}) where {N,S1,S2} =
    MtlArrayStyle{N, SharedStorage}()

# allocation of output arrays
Base.similar(::Broadcasted{MtlArrayStyle{N, S}}, ::Type{T}, dims) where {T, N, S} =
    similar(MtlArray{T,length(dims),S}, dims)

# a static version of CartesianIndices that helps avoiding integer division
# (at the expense of additional compilation)
struct StaticCartesianIndices{N, I} end
StaticCartesianIndices(iter::CartesianIndices{N}) where {N} =
    StaticCartesianIndices{N, iter.indices}()
StaticCartesianIndices(x) = StaticCartesianIndices(CartesianIndices(x))
Base.CartesianIndices(iter::StaticCartesianIndices{N, I}) where {N, I} =
    CartesianIndices{N, typeof(I)}(I)
Base.@propagate_inbounds Base.getindex(I::StaticCartesianIndices, i::Integer) =
    CartesianIndices(I)[Int(i)]
Base.length(I::StaticCartesianIndices) = length(CartesianIndices(I))
function Base.show(io::IO, I::StaticCartesianIndices)
    print(io, "Static")
    show(io, CartesianIndices(I))
end

# specialization of the broadcast implementation to avoid expensive integer divisions
const _broadcast_shapes = Base.IdDict()
const BROADCAST_SPECIALIZATION_THRESHOLD = 10
@inline function Base.materialize!(::Style, dest, bc::Broadcasted) where {Style<:MtlArrayStyle}
    return _copyto!(dest, Broadcast.instantiate(Broadcasted{Style}(bc.f, bc.args, axes(dest))))
end
@inline Base.copyto!(dest::MtlArray, bc::Broadcasted{Nothing}) =
    _copyto!(dest, bc) # Keep it for ArrayConflict
@inline Base.copyto!(dest::AbstractArray, bc::Broadcasted{<:MtlArrayStyle}) =
    _copyto!(dest, bc)
@inline function _copyto!(dest::AbstractArray, bc::Broadcasted)
    axes(dest) == axes(bc) || Broadcast.throwdm(axes(dest), axes(bc))
    isempty(dest) && return dest
    bc = Broadcast.preprocess(dest, bc)

    # if this is a common broadcast shape, specialize the kernel on it
    Is = CartesianIndices(dest)
    if !haskey(_broadcast_shapes, Is)
        _broadcast_shapes[Is] = 1
    else
        _broadcast_shapes[Is] += 1
    end
    if _broadcast_shapes[Is] > BROADCAST_SPECIALIZATION_THRESHOLD
        function broadcast_cartesian_static(dest, bc, Is)
             i = thread_position_in_grid_1d()
             stride = threads_per_grid_1d()
             while 1 <= i <= length(dest)
                I = @inbounds Is[i]
                @inbounds dest[I] = bc[I]
                i += stride
             end
             return
        end

        Is = StaticCartesianIndices(Is)
        kernel = @metal launch=false broadcast_cartesian_static(dest, bc, Is)
        elements = cld(length(dest), 4)
        threads = min(elements, kernel.pipeline.maxTotalThreadsPerThreadgroup)
        groups = cld(elements, threads)
        kernel(dest, bc, Is; threads, groups)
        return dest
    end

    # try to use the most appropriate hardware index to avoid integer division
    if ndims(dest) == 1 ||
       (isa(IndexStyle(dest), IndexLinear) && isa(IndexStyle(bc), IndexLinear))
        function broadcast_linear(dest, bc)
             i = thread_position_in_grid_1d()
             stride = threads_per_grid_1d()
             while 1 <= i <= length(dest)
                 @inbounds dest[i] = bc[i]
                 i += stride
             end
             return
        end

        kernel = @metal launch=false broadcast_linear(dest, bc)
        elements = cld(length(dest), 4)
        threads = min(elements, kernel.pipeline.maxTotalThreadsPerThreadgroup)
        groups = cld(elements, threads)
    elseif ndims(dest) == 2
        function broadcast_2d(dest, bc)
             is = Tuple(thread_position_in_grid_2d())
             stride = threads_per_grid_2d()
             while 1 <= is[1] <= size(dest, 1) && 1 <= is[2] <= size(dest, 2)
                I = CartesianIndex(is)
                @inbounds dest[I] = bc[I]
                is = (is[1] + stride[1], is[2] + stride[2])
             end
             return
        end

        kernel = @metal launch=false broadcast_2d(dest, bc)
        w = min(size(dest, 1), kernel.pipeline.threadExecutionWidth)
        h = min(size(dest, 2), kernel.pipeline.maxTotalThreadsPerThreadgroup ÷ w)
        threads = (w, h)
        groups = cld.(size(dest), threads)
    elseif ndims(dest) == 3
        function broadcast_3d(dest, bc)
             is = Tuple(thread_position_in_grid_3d())
             stride = threads_per_grid_3d()
             while 1 <= is[1] <= size(dest, 1) &&
                   1 <= is[2] <= size(dest, 2) &&
                   1 <= is[3] <= size(dest, 3)
                I = CartesianIndex(is)
                @inbounds dest[I] = bc[I]
                is = (is[1] + stride[1], is[2] + stride[2], is[3] + stride[3])
             end
             return
        end

        kernel = @metal launch=false broadcast_3d(dest, bc)
        w = min(size(dest, 1), kernel.pipeline.threadExecutionWidth)
        h = min(size(dest, 2), kernel.pipeline.threadExecutionWidth,
                               kernel.pipeline.maxTotalThreadsPerThreadgroup ÷ w)
        d = min(size(dest, 3), kernel.pipeline.maxTotalThreadsPerThreadgroup ÷ (w*h))
        threads = (w, h, d)
        groups = cld.(size(dest), threads)
    else
        function broadcast_cartesian(dest, bc)
             i = thread_position_in_grid_1d()
             stride = threads_per_grid_1d()
             while 1 <= i <= length(dest)
                I = @inbounds CartesianIndices(dest)[i]
                @inbounds dest[I] = bc[I]
                i += stride
             end
             return
        end

        kernel = @metal launch=false broadcast_cartesian(dest, bc)
        elements = cld(length(dest), 4)
        threads = min(elements, kernel.pipeline.maxTotalThreadsPerThreadgroup)
        groups = cld(elements, threads)
    end
    kernel(dest, bc; threads, groups)

    return dest
end
