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
    MtlArrayStyle{N, Shared}()

# allocation of output arrays
Base.similar(bc::Broadcasted{MtlArrayStyle{N,S}}, ::Type{T}, dims) where {T,N,S} =
    similar(MtlArray{T,length(dims),S}, dims)

# specialization of the broadcast implementation to avoid expensive integer divisions
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
                is = is .+ stride
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
                is = is .+ stride
             end
             return
        end

        kernel = @metal launch=false broadcast_3d(dest, bc)
        w = min(size(dest, 1), kernel.pipeline.threadExecutionWidth)
        h = min(size(dest, 2), kernel.pipeline.threadExecutionWidth)
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
