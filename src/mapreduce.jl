## COV_EXCL_START

# TODO
# - serial version for lower latency
# - group-stride loop to delay need for second kernel launch

# Reduce a value across a warp
@inline function reduce_warp(op, val)
    # assume(threads_per_simdgroup() == 32)
    offset = 0x00000001
    while offset < 32
        val = op(val, simd_shuffle_down(val, offset))
        offset <<= 1
    end

    return val
end

# Reduce a value across a threadgroup, using shared memory for communication and shuffle intrinsics
@inline function reduce_threadgroup(op, val::T, neutral, shuffle::Val{true}, ::Val{SHMEM_LEN}) where {T, SHMEM_LEN}
    # shared mem for partial sums
    # assume(threads_per_simdgroup() == 32)
    shared = MtlStaticSharedArray(T, 32)

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
        shared[lane]
    else
        neutral
    end

    # final reduce within first warp
    if wid == 1
        val = reduce_warp(op, val)
    end
    return val
end

@inline function reduce_threadgroup(op, val::T, neutral, shuffle::Val{false}, ::Val{SHMEM_LEN}) where {T, SHMEM_LEN}
    threads = threads_per_threadgroup_1d()
    thread  = thread_index_in_threadgroup()

    # shared mem for a complete reduction
    shared = MtlStaticSharedArray(T, (SHMEM_LEN,))
    @inbounds shared[thread] = val

    # perform a reduction
    d = 1
    while d < threads
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
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
