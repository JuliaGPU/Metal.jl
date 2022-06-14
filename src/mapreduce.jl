## COV_EXCL_START

# TODO
# - serial version for lower latency
# - group-stride loop to delay need for second kernel launch

# Reduce a value across a group, using local memory for communication
@inline function reduce_group(op, val::T, neutral, ::Val{maxthreads}) where {T, maxthreads}
    threads = threads_per_threadgroup_1d()
    thread = thread_position_in_threadgroup_1d()

    # local mem for a complete reduction
    shared = MtlThreadGroupArray(T, (maxthreads,))
    @inbounds shared[thread] = val

    # perform a reduction
    d = 1
    while d < threads
        threadgroup_barrier()
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
function partial_mapreduce_device(f, op, neutral, maxthreads, Rreduce, Rother, R, As...)
    # decompose the 1D hardware indices into separate ones for reduction (across items
    # and possibly groups if it doesn't fit) and other elements (remaining groups)
    localIdx_reduce = thread_position_in_threadgroup_1d()
    localDim_reduce = threads_per_threadgroup_1d()
    groupIdx_reduce, groupIdx_other = fldmod1(threadgroup_position_in_grid_1d(), length(Rother))
    groupDim_reduce = threadgroups_per_grid_1d() ÷ length(Rother)

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

        # reduce serially across chunks of input vector that don't fit in a group
        ireduce = localIdx_reduce + (groupIdx_reduce - 1) * localDim_reduce
        while ireduce <= length(Rreduce)
            Ireduce = Rreduce[ireduce]
            J = max(Iother, Ireduce)
            val = op(val, f(_map_getindex(As, J)...))
            ireduce += localDim_reduce * groupDim_reduce
        end

        val = reduce_group(op, val, neutral, maxthreads)

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

    # how many threads do we want?
    #
    # threads in a group work together to reduce values across the reduction dimensions;
    # we want as many as possible to improve algorithm efficiency and execution occupancy.
    wanted_items = length(Rreduce)
    function compute_items(max_items)
        if wanted_items > max_items
            max_items
        else
            wanted_items
        end
    end

    # how many threads can we launch?
    #
    # we might not be able to launch all those threads to reduce each slice in one go.
    # that's why each threads also loops across their inputs, processing multiple values
    # so that we can span the entire reduction dimension using a single item group.
    # XXX: can we query the 1024?
    kernel = @metal launch=false partial_mapreduce_device(f, op, init, Val(1024), Rreduce,
                                                          Rother, R′, A)
    pipeline = MtlComputePipelineState(kernel.fun.lib.device, kernel.fun)
    reduce_threads = compute_items(pipeline.maxTotalThreadsPerThreadgroup)

    # how many groups should we launch?
    #
    # even though we can always reduce each slice in a single item group, that may not be
    # optimal as it might not saturate the GPU. we already launch some groups to process
    # independent dimensions in parallel; pad that number to ensure full occupancy.
    other_groups = length(Rother)
    reduce_groups = cld(length(Rreduce), reduce_threads)

    # determine the launch configuration
    threads = reduce_threads
    groups = reduce_groups*other_groups

    # perform the actual reduction
    if reduce_groups == 1
        # we can cover the dimensions to reduce using a single group
        @metal threads=threads grid=groups partial_mapreduce_device(
            f, op, init, Val(threads), Rreduce, Rother, R′, A)
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
            f, op, init, Val(threads), Rreduce, Rother, partial, A)

        GPUArrays.mapreducedim!(identity, op, R′, partial; init=init)
    end

    return R
end
