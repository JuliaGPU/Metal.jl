# memory operations
# TODO: Properly use dispatch capabilities for these functions


## managed buffers

# GPU operations execute asynchronously, so before accessing memory from the CPU we need to
# wait for the GPU operations that use it. instead of synchronizing the entire device, we
# keep track of the queue that last used a buffer, and whether it may still be using it.
#
# ownership is only changed while holding the `submission_lock`, and before encoding the
# operation that uses the buffer, so that other tasks can safely wait for that operation.

mutable struct Managed
    const buffer::MTLBuffer

    # the CPU address of the buffer's contents, or C_NULL for private buffers
    const host_ptr::Ptr{Cvoid}

    # the queue that last used the buffer
    queue::Union{Nothing,BatchedCommandQueue}

    # whether operations on `queue` may still be using the buffer
    Base.@atomic dirty::Bool

    # incremented on every use, to detect uses that happen while synchronizing
    epoch::Int

    function Managed(buffer::MTLBuffer)
        host_ptr = buffer.storageMode == MTL.MTLStorageModePrivate ? C_NULL :
                   convert(Ptr{Cvoid}, buffer)
        new(buffer, host_ptr, nothing, false, 0)
    end
end

Base.sizeof(managed::Managed) = sizeof(managed.buffer)

# whether `bq` can use the buffer without first waiting for another queue
function can_take_ownership(managed::Managed, bq::BatchedCommandQueue)
    managed.queue === bq || managed.queue === nothing || !(Base.@atomic managed.dirty)
end

# record that `bq` is about to use the buffer. the caller must hold the `submission_lock`
# until the operation has been encoded, and must have checked `can_take_ownership` first.
function take_ownership!(managed::Managed, bq::BatchedCommandQueue)
    managed.queue = bq
    managed.epoch += 1
    Base.@atomic :release managed.dirty = true
    return managed
end

# wait for the GPU to finish using the buffer, e.g., before accessing it from the CPU
@inline function maybe_synchronize(managed::Managed)
    (Base.@atomic :acquire managed.dirty) && synchronize(managed)
    return
end
@noinline function synchronize(managed::Managed)
    while true
        # look up the work to wait for
        queue, epoch = @autoreleasepool Base.@lock submission_lock begin
            (Base.@atomic managed.dirty) ? (managed.queue, managed.epoch) : (nothing, nothing)
        end
        epoch === nothing && return

        # wait for it, without holding any locks
        queue === nothing || synchronize_queue(queue)

        # the buffer may have been used again while we were waiting
        done = @autoreleasepool Base.@lock submission_lock begin
            managed.epoch == epoch && (Base.@atomic managed.dirty = false; true)
        end
        done && return
    end
end


## pointer type

# we cannot take a MTLBuffer's handle and work with that as it were a pointer to memory.
# instead, the Metal APIs always take the original handle and an offset parameter.

struct MtlPtr{T}
    buffer::MTLBuffer
    offset::UInt    # in bytes

    # the managed allocation this pointer points into, if any
    managed::Union{Nothing,Managed}

    function MtlPtr{T}(buffer::MTLBuffer, offset=0, managed=nothing) where {T}
        new(buffer, offset, managed)
    end
end
MtlPtr{T}(managed::Managed, offset=0) where {T} = MtlPtr{T}(managed.buffer, offset, managed)

Base.eltype(::Type{<:MtlPtr{T}}) where {T} = T

# limited arithmetic
Base.:(+)(x::MtlPtr{T}, y::Integer) where {T} = MtlPtr{T}(x.buffer, x.offset+y, x.managed)
Base.:(-)(x::MtlPtr{T}, y::Integer) where {T} = MtlPtr{T}(x.buffer, x.offset-y, x.managed)
Base.:(+)(x::Integer, y::MtlPtr{T}) where {T} = y + x


# take ownership of the memory behind `ptrs` for `bq`, unless another queue may still be
# using some of it. in that case, that memory is returned so that the caller can wait for
# it (without holding any locks) and try again. the caller must hold the `submission_lock`.
function try_take_ownership!(bq::BatchedCommandQueue, ptrs::MtlPtr...)
    for ptr in ptrs
        managed = ptr.managed
        managed === nothing || can_take_ownership(managed, bq) || return managed
    end
    for ptr in ptrs
        managed = ptr.managed
        managed === nothing || take_ownership!(managed, bq)
    end
    return nothing
end

# accessing memory from the CPU: wait for the GPU to finish using it
function Base.convert(::Type{Ptr{T}}, ptr::MtlPtr) where {T}
    managed = ptr.managed
    # private buffers have no CPU address, so let `MTLBuffer` throw the error
    (managed === nothing || managed.host_ptr == C_NULL) &&
        return convert(Ptr{T}, ptr.buffer) + ptr.offset
    maybe_synchronize(managed)
    convert(Ptr{T}, managed.host_ptr) + ptr.offset
end

# return the GPU virtual address, so that alignment checks like
# `UInt(ptr) % N == 0` work the same as for a regular Ptr. note that this is
# the GPU-side address, distinct from the CPU-side `contents` pointer.
Base.UInt(ptr::MtlPtr) = UInt(ptr.buffer.gpuAddress) + ptr.offset
Base.Int(ptr::MtlPtr) = Int(UInt(ptr))


## operations

# CPU -> GPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPtr{T}, src::Ptr{T}, N::Integer;
                             queue=global_queue(dev), async::Bool=false) where T
    iszero(N) && return dst
    storage_type = dst.buffer.storageMode
    if storage_type == MTL.MTLStorageModePrivate
        # stage through a shared buffer
        nocopy = MTL.can_alloc_nocopy(src, N*sizeof(T))
        tmp_buf = alloc(dev, N*sizeof(T), src; storage=SharedStorage, nocopy)

        # copy to the private buffer
        unsafe_copyto!(dev, dst, MtlPtr{T}(tmp_buf, 0), N;
                       queue, async=(nocopy && async))
        free(tmp_buf)
    elseif storage_type == MTL.MTLStorageModeShared
        unsafe_copyto!(convert(Ptr{T}, dst), src, N)
    end
    return dst
end

# GPU -> CPU
function Base.unsafe_copyto!(dev::MTLDevice, dst::Ptr{T}, src::MtlPtr{T}, N::Integer;
                             queue=global_queue(dev), async::Bool=false) where T
    iszero(N) && return dst
    storage_type = src.buffer.storageMode
    if storage_type == MTL.MTLStorageModePrivate
        # stage through a shared buffer
        nocopy = MTL.can_alloc_nocopy(dst, N*sizeof(T))
        tmp_buf = if nocopy
            alloc(dev, N*sizeof(T), dst; storage=SharedStorage, nocopy)
        else
            alloc(dev, N*sizeof(T); storage=SharedStorage)
        end
        unsafe_copyto!(dev, MtlPtr{T}(tmp_buf, 0), src, N;
                       queue, async=(nocopy && async))

        # copy from the shared buffer
        if !nocopy
            unsafe_copyto!(dst, convert(Ptr{T}, tmp_buf), N)
        end
        free(tmp_buf)
    elseif storage_type ==  MTL.MTLStorageModeShared
        unsafe_copyto!(dst, convert(Ptr{T}, src), N)
    end
    return dst
end

# GPU -> GPU
# Split up copies > 2GiB to avoid silent failures when copying buffers > 4Gib
# to fix JuliaGPU/Metal.jl#710. Solution inspired by
# https://github.com/pytorch/pytorch/pull/126104
function Base.unsafe_copyto!(dev::MTLDevice, dst::MtlPtr{T}, src::MtlPtr{T}, N::Integer;
                             queue=global_queue(dev), async::Bool=false) where T
    N > 0 || return dst
    nbytes = N * sizeof(T)

    # For small copies of Shared memory arrays, CPU memcpy avoids GPU command buffer overhead.
    # Otherwise, use GPU blit for large copies (>32MiB) where it's faster than CPU memcpy.
    if dst.buffer.storageMode == src.buffer.storageMode == MTL.MTLStorageModeShared && nbytes < 2^25
        unsafe_copyto!(convert(Ptr{T}, dst), convert(Ptr{T}, src), N)
        return dst
    end

    bq = batched_queue(queue)
    while true
        conflict = encode_copy!(bq, dst, src, nbytes)
        conflict === nothing && break
        synchronize(conflict)
    end
    async ? maybe_autoflush!(bq) : synchronize(bq)
    return dst
end

@autoreleasepool function encode_copy!(bq::BatchedCommandQueue, dst::MtlPtr, src::MtlPtr,
                                       nbytes::Integer)
    Base.@lock submission_lock begin
        conflict = try_take_ownership!(bq, dst, src)
        conflict === nothing || return conflict

        total_bytes = nbytes
        chunk_size = 2^31
        enc = blit_encoder(bq)
        offset = 0
        while nbytes > 0
            transfer_bytes = min(nbytes, chunk_size)
            append_copy!(enc, dst.buffer, dst.offset + offset,
                         src.buffer, src.offset + offset, transfer_bytes)
            offset += transfer_bytes
            nbytes -= transfer_bytes
        end

        op = MTL.profile_metadata[] === nothing ? nothing :
             (; kind = :copy, name = "copyto!", bytes = Int(total_bytes))
        record_operation!(bq, dst.buffer, src.buffer; bytes=total_bytes, op=op)
    end
    return nothing
end

function unsafe_fill!(dev::MTLDevice, dst::MtlPtr{T}, value::Union{UInt8,Int8}, N::Integer;
                      queue=global_queue(dev), async::Bool=false) where T
    N > 0 || return dst
    nbytes = N * sizeof(T)

    bq = batched_queue(queue)
    while true
        conflict = encode_fill!(bq, dst, value, nbytes)
        conflict === nothing && break
        synchronize(conflict)
    end
    async ? maybe_autoflush!(bq) : synchronize(bq)
    return dst
end

@autoreleasepool function encode_fill!(bq::BatchedCommandQueue, dst::MtlPtr,
                                       value::Union{UInt8,Int8}, nbytes::Integer)
    Base.@lock submission_lock begin
        conflict = try_take_ownership!(bq, dst)
        conflict === nothing || return conflict

        enc = blit_encoder(bq)
        append_fillbuffer!(enc, dst.buffer, value, nbytes, dst.offset)

        op = MTL.profile_metadata[] === nothing ? nothing :
             (; kind = :fill, name = "fill!", bytes = Int(nbytes))
        record_operation!(bq, dst.buffer; bytes=nbytes, op=op)
    end
    return nothing
end

# TODO: Implement generic fill since mtBlitCommandEncoderFillBuffer is limiting
