## COV_EXCL_START
function partial_scan(op::Function, output::AbstractArray{T}, input::AbstractArray,
                      Rdim, Rpre, Rpost, Rother, neutral, init,
                      ::Val{maxthreads}, ::Val{inclusive}=Val(true)) where {T, maxthreads, inclusive}
    threads = threads_per_threadgroup_3d().x
    thread = thread_position_in_threadgroup_3d().x

    temp = MtlThreadGroupArray(T, (Int32(2) * maxthreads,))

    i = (threadgroup_position_in_grid_3d().x - Int32(1)) * threads_per_threadgroup_3d().x + thread_position_in_threadgroup_3d().x
    j = (threadgroup_position_in_grid_3d().z - Int32(1)) * threadgroups_per_grid_3d().y + threadgroup_position_in_grid_3d().y

    if j > length(Rother)
        return
    end

    @inbounds begin
        I = Rother[j]
        Ipre = Rpre[I[1]]
        Ipost = Rpost[I[2]]
    end

    @inbounds temp[thread] = if i <= length(Rdim)
        op(neutral, input[Ipre, i, Ipost])
    else
        op(neutral, neutral)
    end

    offset = one(thread)
    d = threads >> 0x1
    while d > zero(d)
        threadgroup_barrier(MemoryFlagThreadGroup)
        @inbounds if thread <= d
            ai = offset * (thread << 0x1 - 0x1)
            bi = offset * (thread << 0x1)
            temp[bi] = op(temp[ai], temp[bi])
        end
        offset <<= 0x1
        d >>= 0x1
    end

    @inbounds if isone(thread)
        temp[threads] = neutral
    end

    d = one(thread)
    while d < threads
        offset >>= 0x1
        threadgroup_barrier(MemoryFlagThreadGroup)
        @inbounds if thread <= d
            ai = offset * (thread << 0x1 - 0x1)
            bi = offset * (thread << 0x1)

            t = temp[ai]
            temp[ai] = temp[bi]
            temp[bi] = op(t, temp[bi])
        end
        d <<= 0x1
    end

    threadgroup_barrier(MemoryFlagThreadGroup)

    @inbounds if i <= length(Rdim)
        val = if inclusive
            op(temp[thread], input[Ipre, i, Ipost])
        else
            temp[thread]
        end
        if init !== nothing
            val = op(something(init), val)
        end
        output[Ipre, i, Ipost] = val
    end

    return
end

function aggregate_partial_scan(op::Function, output::AbstractArray, aggregates::AbstractArray, Rdim, Rpre, Rpost, Rother, init)
    block = threadgroup_position_in_grid_3d().x

    i = (threadgroup_position_in_grid_3d().x - Int32(1)) * threads_per_threadgroup_3d().x + thread_position_in_threadgroup_3d().x
    j = (threadgroup_position_in_grid_3d().z - Int32(1)) * threadgroups_per_grid_3d().y + threadgroup_position_in_grid_3d().y

    @inbounds if i <= length(Rdim) && j <= length(Rother)
        I = Rother[j]
        Ipre = Rpre[I[1]]
        Ipost = Rpost[I[2]]

        val = if block > 1
            op(aggregates[Ipre, block - Int32(1), Ipost], output[Ipre, i, Ipost])
        else
            output[Ipre, i, Ipost]
        end

        if init !== nothing
            val = op(something(init), val)
        end

        output[Ipre, i, Ipost] = val
    end

    return
end
## COV_EXCL_STOP

function scan!(f::Function, output::WrappedMtlArray{T}, input::WrappedMtlArray;
               dims::Integer, init=nothing, neutral=GPUArrays.neutral_element(f, T)) where {T}
    dims > 0 || throw(ArgumentError("dims must be a positive integer"))
    inds_t = axes(input)
    axes(output) == inds_t || throw(DimensionMismatch("shape of B must match A"))
    dims > ndims(input) && return copyto!(output, input)
    isempty(inds_t[dims]) && return output

    # iteration domain across the main dimension
    Rdim = CartesianIndices((size(input, dims),))

    # iteration domain for the other dimensions
    Rpre = CartesianIndices(size(input)[1:dims-1])
    Rpost = CartesianIndices(size(input)[dims+1:end])
    Rother = CartesianIndices((length(Rpre), length(Rpost)))

    # the maximum number of threads is limited by the hardware
    dev = device()
    maxthreads = min(Int(dev.maxThreadsPerThreadgroup.width),
                     Int(dev.maxThreadgroupMemoryLength) ÷ sizeof(T) ÷ 2)

    # determine how many threads we can launch for the scan kernel
    kernel = @metal launch=false partial_scan(f, output, input, Rdim, Rpre, Rpost, Rother, neutral, init, Val(maxthreads), Val(true))
    threads = Int(kernel.pipeline.maxTotalThreadsPerThreadgroup)

    # determine the grid layout to cover the other dimensions
    blocks_other = (length(Rother), 1)

    # does that suffice to scan the array in one go?
    full = nextpow(2, length(Rdim))
    if full <= threads
        @metal(threads=full, groups=(1, blocks_other...),
               partial_scan(f, output, input, Rdim, Rpre, Rpost, Rother, neutral, init, Val(full), Val(true)))
    else
        # perform partial scans across the scanning dimension
        # NOTE: don't set init here to avoid applying the value multiple times
        partial = prevpow(2, threads)
        blocks_dim = cld(length(Rdim), partial)
        @metal(threads=partial, groups=(blocks_dim, blocks_other...),
              partial_scan(f, output, input, Rdim, Rpre, Rpost, Rother, neutral, nothing, Val(partial), Val(true)))

        # get the total of each thread block (except the first) of the partial scans
        aggregates = fill(neutral, Base.setindex(size(input), blocks_dim, dims))
        partials = selectdim(output, dims, partial:partial:length(Rdim))
        indices = CartesianIndices(partials)
        copyto!(aggregates, indices, partials, indices)

        # scan these totals to get totals for the entire partial scan
        accumulate!(f, aggregates, aggregates; dims=dims)

        # add those totals to the partial scan result
        # NOTE: we assume that this kernel requires fewer resources than the scan kernel.
        #       if that does not hold, launch with fewer threads and calculate
        #       the aggregate block index within the kernel itself.
        @metal(threads=partial, groups=(blocks_dim, blocks_other...),
              aggregate_partial_scan(f, output, aggregates, Rdim, Rpre, Rpost, Rother, init))

        unsafe_free!(aggregates)
    end

    return output
end


## Base interface

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlVector, dims::Nothing, init::Nothing) =
    @inline AK.accumulate!(op, output, input; dims, init=AK.neutral_element(op, eltype(output)), alg=AK.ScanPrefixes())

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlArray, dims::Integer, init::Nothing) =
    @inline AK.accumulate!(op, output, input; dims, init=AK.neutral_element(op, eltype(output)), alg=AK.ScanPrefixes())
Base._accumulate!(op, output::WrappedMtlArray, input::MtlVector, dims::Nothing, init::Some) =
    @inline AK.accumulate!(op, output, input; dims, init=something(init), alg=AK.ScanPrefixes())

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlArray, dims::Integer, init::Some) =
    @inline AK.accumulate!(op, output, input; dims, init=something(init), alg=AK.ScanPrefixes())

Base.accumulate_pairwise!(op, result::WrappedMtlVector, v::WrappedMtlVector) = @inline AK.accumulate!(op, result, v; init=AK.neutral_element(op, eltype(result)), alg=AK.ScanPrefixes())

# default behavior unless dims are specified by the user
function Base.accumulate(op, A::WrappedMtlArray;
                         dims::Union{Nothing,Integer}=nothing, kw...)
    nt = values(kw)
    if dims === nothing && !(A isa AbstractVector)
        # This branch takes care of the cases not handled by `_accumulate!`.
        return reshape(AK.accumulate(op, A[:]; init = (:init in keys(kw) ? nt.init : AK.neutral_element(op, eltype(A))), alg=AK.ScanPrefixes()), size(A))
    end
    if isempty(kw)
        out = similar(A, Base.promote_op(op, eltype(A), eltype(A)))
    elseif keys(nt) === (:init,)
        out = similar(A, Base.promote_op(op, typeof(nt.init), eltype(A)))
    else
        throw(ArgumentError("accumulate does not support the keyword arguments $(setdiff(keys(nt), (:init,)))"))
    end
    accumulate!(op, out, A; dims=dims, kw...)
end
