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

function partial_scan_simd(op::Function, output::AbstractArray{T}, input::AbstractArray,
                           Rdim, Rpre, Rpost, Rother, neutral, init,
                           ::Val{single_simdgroup}) where {T, single_simdgroup}
    threads = Int(threads_per_threadgroup_3d().x)
    thread = Int(thread_position_in_threadgroup_3d().x)
    lane = Int(thread_index_in_simdgroup())
    simdgroup = Int(simdgroup_index_in_threadgroup())
    assume(threads_per_simdgroup() == 32)

    i = (Int(threadgroup_position_in_grid_3d().x) - 1) * threads + thread
    j = (Int(threadgroup_position_in_grid_3d().z) - 1) *
        Int(threadgroups_per_grid_3d().y) + Int(threadgroup_position_in_grid_3d().y)

    if j > length(Rother)
        return
    end

    @inbounds begin
        I = Rother[j]
        Ipre = Rpre[I[1]]
        Ipost = Rpost[I[2]]
    end

    val = @inbounds if i <= length(Rdim)
        op(neutral, input[Ipre, i, Ipost])
    else
        op(neutral, neutral)
    end

    # Inclusive scan within each SIMD group.
    offset = 1
    while offset < 32
        previous = simd_shuffle_up(val, offset)
        if lane > offset
            val = op(previous, val)
        end
        offset <<= 1
    end

    if single_simdgroup
        @inbounds if i <= length(Rdim)
            if init !== nothing
                val = op(something(init), val)
            end
            output[Ipre, i, Ipost] = val
        end
        return
    end

    # Scan the per-SIMD-group totals using the first SIMD group, then add the total of
    # all preceding groups. This needs only two threadgroup barriers instead of the
    # up-sweep/down-sweep tree used by the generic kernel.
    totals = MtlThreadGroupArray(T, 32)
    last_lane = min(32, threads - (simdgroup - 1) * 32)
    if lane == last_lane
        @inbounds totals[simdgroup] = val
    end
    threadgroup_barrier(MemoryFlagThreadGroup)

    simdgroups = cld(threads, 32)
    if simdgroup == 1
        group_val = lane <= simdgroups ? @inbounds(totals[lane]) : neutral
        offset = 1
        while offset < 32
            previous = simd_shuffle_up(group_val, offset)
            if lane > offset
                group_val = op(previous, group_val)
            end
            offset <<= 1
        end
        if lane <= simdgroups
            @inbounds totals[lane] = group_val
        end
    end
    threadgroup_barrier(MemoryFlagThreadGroup)

    if simdgroup > 1
        @inbounds val = op(totals[simdgroup - 1], val)
    end

    @inbounds if i <= length(Rdim)
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

    full = nextpow(2, length(Rdim))
    simd_type = T <: Union{Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8}
    # A single SIMD group needs no barriers, and the hierarchical SIMD scan wins for
    # 512+ threads. Keep the shared-memory tree for the measured 64-256-thread crossover.
    simd = simd_type && (full <= 32 || full >= 512)

    # the maximum number of threads is limited by the hardware
    dev = device()
    threadgroup_threads, threadgroup_memory = MTL.threadgroup_limits(dev)
    maxthreads = min(threadgroup_threads, threadgroup_memory ÷ sizeof(T) ÷ 2)

    # determine how many threads we can launch for the scan kernel
    kernel = if simd
        @metal launch=false partial_scan_simd(f, output, input, Rdim, Rpre, Rpost,
                                              Rother, neutral, init, Val(false))
    else
        @metal launch=false partial_scan(f, output, input, Rdim, Rpre, Rpost,
                                         Rother, neutral, init, Val(maxthreads),
                                         Val(true))
    end
    threads = Int(kernel.pipeline.maxTotalThreadsPerThreadgroup)

    # determine the grid layout to cover the other dimensions
    blocks_other = (length(Rother), 1)

    # does that suffice to scan the array in one go?
    if full <= threads
        if simd
            @metal(threads=full, groups=(1, blocks_other...),
                   partial_scan_simd(f, output, input, Rdim, Rpre, Rpost, Rother,
                                     neutral, init, Val(full <= 32)))
        else
            @metal(threads=full, groups=(1, blocks_other...),
                   partial_scan(f, output, input, Rdim, Rpre, Rpost, Rother,
                                neutral, init, Val(full), Val(true)))
        end
    else
        # perform partial scans across the scanning dimension
        # NOTE: don't set init here to avoid applying the value multiple times
        partial = prevpow(2, threads)
        blocks_dim = cld(length(Rdim), partial)
        if simd
            @metal(threads=partial, groups=(blocks_dim, blocks_other...),
                   partial_scan_simd(f, output, input, Rdim, Rpre, Rpost, Rother,
                                     neutral, nothing, Val(false)))
        else
            @metal(threads=partial, groups=(blocks_dim, blocks_other...),
                   partial_scan(f, output, input, Rdim, Rpre, Rpost, Rother,
                                neutral, nothing, Val(partial), Val(true)))
        end

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

const scan_alg = ScopedValue(:auto)
const mpsgraph_scan_threshold = 64 * 1024

# MPSGraph has no efficient 64-bit-integer cumulative kernel: on the
# `accumulate(+, rand(Int64, 3, 10^6); dims=1)` shape it is ~2.6× slower than the
# native scan (vs ~0.85× for ≤32-bit ints and floats, which MPSGraph handles
# well), and the slowdown grows as the scanned dimension shrinks. So keep 64-bit
# integers on the native scan in `:auto`; they remain correct (just slow) and
# available under an explicit `:MPSGraph` request.
mpsgraph_scan_worthwhile(::Type{T}) where {T} = !(T === Int64 || T === UInt64)

# MPSGraph cumulative max/min ignore NaNs while Base accumulate(max/min)
# propagates them, so don't use MPSGraph scan for these operations on
# Float inputs
mpsgraph_scan_operation(::DataType, ::typeof(+)) = :sum
mpsgraph_scan_operation(::DataType, ::typeof(Base.add_sum)) = :sum
mpsgraph_scan_operation(::DataType, ::typeof(*)) = :product
mpsgraph_scan_operation(::DataType, ::typeof(Base.mul_prod)) = :product
mpsgraph_scan_operation(::Type{<:Integer}, ::typeof(min)) = :minimum
mpsgraph_scan_operation(::Type{<:Integer}, ::typeof(max)) = :maximum
mpsgraph_scan_operation(_T, _op) = nothing

function mpsgraph_scan_supported(op, output::MtlArray{T}, input::MtlArray{T},
                            dims::Integer, init::Nothing) where {T}
    mpsgraph_scan_operation(T, op) === nothing && return false
    T <: Union{MPSGraphs.MPSGRAPH_VALID_SCAN_TYPES...} || return false
    axes(output) == axes(input) || return false
    1 <= dims <= ndims(input) || return false
    return output.offset == 0 && input.offset == 0
end

mpsgraph_scan_supported(op, output, input, dims::Integer, init) = false

# same as MPSGraphs.graph_scan!, but errors on unsupported input when explicitly requested
function mpsgraph_scan!(op, output::MtlArray{T}, input::MtlArray{T}; dims::Integer,
                   init) where {T}
    init === nothing ||
        throw(ArgumentError("MPSGraph scan does not support init"))
    return MPSGraphs.graph_scan!(op, output, input; dim=dims)
end
function mpsgraph_scan!(op, output, input; dims::Integer, init)
    throw(ArgumentError("MPSGraph scan does not support this accumulate query"))
end

function scan_with_algorithm!(op, output::WrappedMtlArray, input::WrappedMtlArray;
                              dims::Integer, init=nothing)
    alg = scan_alg[]
    supported = mpsgraph_scan_supported(op, output, input, dims, init)
    if alg === :MPSGraph
        return mpsgraph_scan!(op, output, input; dims, init)
    elseif alg === :auto && supported && mpsgraph_scan_worthwhile(eltype(input)) &&
           length(input) >= mpsgraph_scan_threshold
        return MPSGraphs.graph_scan!(op, output, input; dim=dims)
    elseif alg === :auto || alg === :native
        return scan!(op, output, input; dims, init)
    else
        error(":$alg is not a valid scan algorithm. Options are: `:auto`, `:MPSGraph`, `:native`")
    end
end

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlVector, dims::Nothing, init::Nothing) =
    scan_with_algorithm!(op, output, input; dims=1, init)

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlArray, dims::Integer, init::Nothing) =
    scan_with_algorithm!(op, output, input; dims=dims, init)

Base._accumulate!(op, output::WrappedMtlArray, input::MtlVector, dims::Nothing, init::Some) =
    scan_with_algorithm!(op, output, input; dims=1, init)

Base._accumulate!(op, output::WrappedMtlArray, input::WrappedMtlArray, dims::Integer, init::Some) =
    scan_with_algorithm!(op, output, input; dims=dims, init)

Base.accumulate_pairwise!(op, result::WrappedMtlVector, v::WrappedMtlVector) = accumulate!(op, result, v)

# default behavior unless dims are specified by the user
function Base.accumulate(op, A::WrappedMtlArray;
                         dims::Union{Nothing,Integer}=nothing, kw...)
    if dims === nothing && !(A isa AbstractVector)
        # This branch takes care of the cases not handled by `_accumulate!`.
        return reshape(accumulate(op, A[:]; kw...), size(A))
    end
    nt = values(kw)
    if isempty(kw)
        out = similar(A, Base.promote_op(op, eltype(A), eltype(A)))
    elseif keys(nt) === (:init,)
        out = similar(A, Base.promote_op(op, typeof(nt.init), eltype(A)))
    else
        throw(ArgumentError("accumulate does not support the keyword arguments $(setdiff(keys(nt), (:init,)))"))
    end
    accumulate!(op, out, A; dims=dims, kw...)
end
