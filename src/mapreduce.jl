## COV_EXCL_START

# TODO
# - serial version for lower latency
# - group-stride loop to delay need for second kernel launch

# Reduce a value across a warp using shuffle down intrinsic
@inline function reduce_warp(op, val)
    assume(threads_per_simdgroup() == 32)
    offset = 0x00000001
    while offset < 32
        val = op(val, simd_shuffle_down(val, offset))
        offset <<= 1
    end

    return val
end

# Reduce a value across a threadgroup, using shared memory for communication and shuffle intrinsics
@inline function reduce_group(op, val::T, neutral, shuffle::Val{true}, ::Val{maxthreads}) where {T, maxthreads}
    # shared mem for partial sums
    assume(threads_per_simdgroup() == 32)
    shared = MtlThreadGroupArray(T, 32)

    wid  = simdgroup_index_in_threadgroup()
    lane = thread_index_in_simdgroup()

    # each warp performs partial reduction
    val = reduce_warp(op, val)

    # write reduced value to shared memory
    if lane == 1
        @inbounds shared[wid] = val
    end

    # wait for all partial reductions
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    # read from shared memory only if that warp existed
    val = if thread_index_in_threadgroup() <= fld1(threads_per_threadgroup_1d(), 32)
        @inbounds shared[lane]
    else
        neutral
    end

    # final reduce within first warp
    if wid == 1
        val = reduce_warp(op, val)
    end
    return val
end

# Reduce a value across a group, using local memory for communication
@inline function reduce_group(op, val::T, neutral, shuffle::Val{false}, ::Val{maxthreads}) where {T, maxthreads}
    threads = threads_per_threadgroup_1d()
    thread = thread_position_in_threadgroup_1d()

    # local mem for a complete reduction
    shared = MtlThreadGroupArray(T, (maxthreads,))
    @inbounds shared[thread] = val

    # perform a reduction
    d = 1
    while d < threads
        threadgroup_barrier(MemoryFlagThreadGroup)
        index = 2 * d * (thread-1) + 1
        @inbounds if index <= threads
            other_val = if index + d <= threads
                shared[index+d]
            else
                neutral
            end
            shared[index] = op(shared[index], other_val)
        end
        d *= 2
    end

    # load the final value on the first thread
    if thread == 1
        val = @inbounds shared[thread]
    end

    return val
end

Base.@propagate_inbounds _map_getindex(args::Tuple, I) = ((args[1][I]), _map_getindex(Base.tail(args), I)...)
Base.@propagate_inbounds _map_getindex(args::Tuple{Any}, I) = ((args[1][I]),)
Base.@propagate_inbounds _map_getindex(args::Tuple{}, I) = ()

# Reduce an array across the grid. All elements to be processed can be addressed by the
# product of the two iterators `Rreduce` and `Rother`, where the latter iterator will have
# singleton entries for the dimensions that should be reduced (and vice versa).
function partial_mapreduce_device(f, op, neutral, maxthreads, ::Val{Rreduce},
    ::Val{Rother}, ::Val{Rlen}, ::Val{stride}, shuffle, R, As...) where {Rreduce, Rother, Rlen, stride}
    # decompose the 1D hardware indices into separate ones for reduction (across items
    # and possibly groups if it doesn't fit) and other elements (remaining groups)
    localIdx_reduce = thread_position_in_threadgroup_1d()
    localDim_reduce = threads_per_threadgroup_1d() * stride
    groupIdx_reduce, groupIdx_other = fldmod1(threadgroup_position_in_grid_1d(), Rlen)

    # group-based indexing into the values outside of the reduction dimension
    # (that means we can safely synchronize items within this group)
    iother = groupIdx_other
    @inbounds if iother <= length(Rother)
        Iother = Rother[iother]

        # load the neutral value
        Iout = CartesianIndex(Tuple(Iother)..., groupIdx_reduce)
        neutral = if neutral === nothing
            R[Iout]
        else
            neutral
        end

        val = op(neutral, neutral)

        # read multiple consecutive values in reduction dimension to improve efficiency
        ireduce = (localIdx_reduce - 1) * stride + (groupIdx_reduce - 1) * localDim_reduce
        limit = ireduce + stride
        while ireduce < limit
            ireduce += 1
            next = if ireduce <= length(Rreduce)
                Ireduce = Rreduce[ireduce]
                J = max(Iother, Ireduce)
                f(_map_getindex(As, J)...)
            else
                neutral
            end
            val = op(val, next)
        end

        val = reduce_group(op, val, neutral, shuffle, maxthreads)

        # write back to memory
        if localIdx_reduce == 1
            R[Iout] = val
        end
    end

    return
end

## COV_EXCL_STOP

function GPUArrays.mapreducedim!(f::F, op::OP, R::WrappedMtlArray{T},
                                 A::Union{AbstractArray,Broadcast.Broadcasted};
                                 init=nothing) where {F, OP, T}
    Base.check_reducedims(R, A)
    length(A) == 0 && return R # isempty(::Broadcasted) iterates

     # be conservative about using shuffle instructions
     shuffle = T <: Union{Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8}

    # add singleton dimensions to the output container, if needed
    if ndims(R) < ndims(A)
        dims = Base.fill_to_length(size(R), 1, Val(ndims(A)))
        R = reshape(R, dims)
    end

    # iteration domain, split in two: one part covers the dimensions that should
    # be reduced, and the other covers the rest. combining both covers all values.
    Rall = CartesianIndices(axes(A))
    Rother = CartesianIndices(axes(R))
    Rreduce = CartesianIndices(ifelse.(axes(A) .== axes(R), Ref(Base.OneTo(1)), axes(A)))
    # NOTE: we hard-code `OneTo` (`first.(axes(A))` would work too) or we get a
    #       CartesianIndices object with UnitRanges that behave badly on the GPU.
    @assert length(Rall) == length(Rother) * length(Rreduce)

    # allocate an additional, empty dimension to write the reduced value to.
    # this does not affect the actual location in memory of the final values,
    # but allows us to write a generalized kernel supporting partial reductions.
    R′ = reshape(R, (size(R)..., 1))

    # number of consecutive values in reduction dimension read by each thread
    # TODO: experiment and document this choice
    stride = 16 ÷ sizeof(T)

    # how many threads can we launch?
    #
    # we might not be able to launch all those threads to reduce each slice in one go.
    # that's why each threads also loops across their inputs, processing multiple values
    # so that we can span the entire reduction dimension using a single item group.
    # XXX: can we query the 1024?
    kernel = @metal launch=false partial_mapreduce_device(f, op, init, Val(1024), Val(Rreduce), Val(Rother),
                                                          Val(UInt64(length(Rother))), Val(stride), Val(shuffle), R′, A)
    pipeline = MTLComputePipelineState(kernel.fun.device, kernel.fun)

    # how many threads do we want?
    #
    # threads in a group work together to reduce values across the reduction dimensions;
    # we want as many as possible to improve algorithm efficiency and execution occupancy.
    wanted_threads = shuffle ? nextwarp(pipeline, length(Rreduce)) : length(Rreduce)
    function compute_threads(max_threads)
        if wanted_threads > max_threads
            shuffle ? prevwarp(pipeline, max_threads) : max_threads
        else
            wanted_threads
        end
    end

    reduce_threads = compute_threads(pipeline.maxTotalThreadsPerThreadgroup)

    # how many groups should we launch?
    #
    # even though we can always reduce each slice in a single item group, that may not be
    # optimal as it might not saturate the GPU. we already launch some groups to process
    # independent dimensions in parallel; pad that number to ensure full occupancy.
    other_groups = length(Rother)
    reduce_groups = cld(length(Rreduce), reduce_threads * stride)

    # determine the launch configuration
    threads = reduce_threads
    groups = reduce_groups*other_groups

    # perform the actual reduction
    if reduce_groups == 1
        # we can cover the dimensions to reduce using a single group
        @metal threads=threads grid=groups partial_mapreduce_device(
            f, op, init, Val(threads), Val(Rreduce), Val(Rother),
            Val(UInt64(length(Rother))), Val(stride), Val(shuffle), R′, A)
    else
        # we need multiple steps to cover all values to reduce
        partial = similar(R, (size(R)..., reduce_groups))
        if init === nothing
            # without an explicit initializer we need to copy from the output container
            sz = prod(size(R))
            for i in 1:reduce_groups
                # TODO: async copies (or async fill!, but then we'd need to load first)
                #       or maybe just broadcast since that extends singleton dimensions
                copyto!(partial, (i-1)*sz+1, R, 1, sz)
            end
        end
        @metal threads=threads grid=groups partial_mapreduce_device(
            f, op, init, Val(threads), Val(Rreduce), Val(Rother),
            Val(UInt64(length(Rother))), Val(stride), Val(shuffle), partial, A)

        GPUArrays.mapreducedim!(identity, op, R′, partial; init=init)
    end

    return R
end
