module MetalKernels

using ..Metal
using ..Metal: @device_override, DefaultStorageMode, SharedStorage, metal_support,
               mtlfunction, mtlconvert, try_launch, MTL, MTLSize, @autoreleasepool,
               MTLSharedEvent, MTLCommandBuffer, encode_signal!, encode_wait!, commit!

import KernelInterface as KI

import Adapt


## back-end

export MetalBackend

"""
    MetalBackend()

The KernelInterface back end for running on Metal GPUs, which KernelAbstractions uses to
launch `@kernel` kernels.
"""
struct MetalBackend <: KI.Backend
end

# Ensure type stability. See JuliaGPU/KernelAbstractions#634
@inline KI.allocate(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = MtlArray{T, length(dims), unified ? SharedStorage : DefaultStorageMode}(undef, dims)

KI.get_backend(::MtlArray) = MetalBackend()
KI.synchronize(::MetalBackend) = synchronize()

KI.functional(::MetalBackend) = Metal.functional()

KI.supports_float64(::MetalBackend) = false
KI.supports_atomics(::MetalBackend) = metal_support() >= v"4.1"
KI.supports_unified(::MetalBackend) = true
KI.supports_subgroups(::MetalBackend) = true
KI.supports_shuffle(::MetalBackend, ::Type{T}) where {T} =
    T <: Union{Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8}

Adapt.adapt_storage(::MetalBackend, a::AbstractArray) = Adapt.adapt(MtlArray, a)
Adapt.adapt_storage(::MetalBackend, a::MtlArray) = a


## memory operations

# dense arrays, and contiguous views of host arrays (those of an `MtlArray` are `MtlArray`s)
const ContiguousArray{T} =
    Union{Array{T}, MtlArray{T}, Base.FastContiguousSubArray{T, <:Any, <:Array}}

# Metal's copies are ordered with respect to the other work on the task's queue, and copies
# between host and device memory complete before returning, so a host view can be wrapped
# in an `Array` for the duration of the copy
dense(A::Union{Array, MtlArray}) = A
dense(A::SubArray) = unsafe_wrap(Array, pointer(A), size(A))

function KI.copyto!(::MetalBackend, dest::ContiguousArray{T}, src::ContiguousArray{T}) where T
    length(dest) == length(src) ||
        throw(ArgumentError("Arrays must have the same length, got $(length(dest)) and $(length(src))"))
    if dest isa MtlArray && src isa MtlArray && device(dest) != device(src)
        error("Copy between different devices not implemented")
    end
    if dest isa MtlArray || src isa MtlArray
        GC.@preserve dest src copyto!(dense(dest), dense(src))
    else
        # host-to-host copies, including of element types a wrapped `Array` can't hold
        copyto!(dest, src)
    end
    return dest
end
KI.copyto!(::MetalBackend, dest, src) =
    throw(ArgumentError("KernelInterface.copyto! only supports contiguous arrays of the same element type, got $(typeof(dest)) and $(typeof(src))"))

KI.unsafe_free!(A::MtlArray) = Metal.unsafe_free!(A)


## kernel launch

KI.argconvert(::MetalBackend, arg) = mtlconvert(arg)

# The SIMD-group width is a property of the compiled pipeline (`threadExecutionWidth`), but
# it is the same for all pipelines on Apple GPUs. `kernel_function` checks that, so that
# `KI.sub_group_size` can promise it before compiling.
const SIMD_WIDTH = 32

function KI.kernel_function(backend::MetalBackend, f::F, tt::TT=Tuple{}; name=nothing, kwargs...) where {F,TT}
    # KernelInterface passes the callable unconverted: it is converted again at every launch,
    # like with `@metal`, so that the buffers it captures are declared and kept alive
    kern = mtlfunction(mtlconvert(f), tt; source=f, name, kwargs...)
    kern.exec_width == SIMD_WIDTH ||
        error("Kernel compiled with a SIMD-group width of $(kern.exec_width), while KernelInterface.sub_group_size promises $SIMD_WIDTH")
    KI.Kernel(backend, kern)
end

# passes the arguments on as a tuple, like calling the `HostKernel` does. like it, waits for
# the queue of another task that still uses an argument's buffer, and launches again
function KI.launch(obj::KI.Kernel{MetalBackend}, groups::Dims{3}, items::Dims{3},
                   args::Tuple; queue=nothing, submit::Bool=false, kwargs...)
    if !isempty(kwargs)
        # KernelInterface has validated the launch geometry
        if haskey(kwargs, :threads) || haskey(kwargs, :groups)
            throw(ArgumentError("KernelInterface kernels take `numgroups`, `workgroupsize` or `ndrange`, not `threads` or `groups`"))
        end
        throw(ArgumentError("Unsupported keyword argument `$(first(keys(kwargs)))`"))
    end
    gs, ts = MTLSize(groups), MTLSize(items)
    while true
        conflict = try_launch(obj.kern, queue, gs, ts, args, submit)
        conflict === nothing && return
        synchronize(conflict)
    end
end

# the pipeline's `maxTotalThreadsPerThreadgroup`. KernelInterface's default
# `launch_configuration` launches workgroups of that size, as Metal always has.
KI.max_work_group_size(kernel::KI.Kernel{MetalBackend})::Int = kernel.kern.maxthreads
function KI.max_work_group_size(::MetalBackend)::Int
    MTL.max_threadgroup_threads(device())
end
function KI.max_work_group_dims(::MetalBackend)::NTuple{3, Int}
    MTL.max_threadgroup_dims(device())
end
# the number of threads along each dimension of the grid has to fit in 32 bits
function KI.max_num_groups(backend::MetalBackend)::NTuple{3, Int}
    Int(typemax(UInt32)) .÷ KI.max_work_group_dims(backend)
end
KI.sub_group_size(::MetalBackend)::Int = SIMD_WIDTH
function KI.multiprocessor_count(::MetalBackend)::Int
    Metal.num_gpu_cores()
end


## indexing

# computed with `% T`, which unlike `T(x)` has no error path

@device_override @inline function KI.get_local_id(::Type{T}) where {T}
    id = thread_position_in_threadgroup()
    return (; x = id.x % T, y = id.y % T, z = id.z % T)
end

@device_override @inline function KI.get_group_id(::Type{T}) where {T}
    id = threadgroup_position_in_grid()
    return (; x = id.x % T, y = id.y % T, z = id.z % T)
end

@device_override @inline function KI.get_local_size(::Type{T}) where {T}
    size = threads_per_threadgroup()
    return (; x = size.x % T, y = size.y % T, z = size.z % T)
end

@device_override @inline function KI.get_num_groups(::Type{T}) where {T}
    size = threadgroups_per_grid()
    return (; x = size.x % T, y = size.y % T, z = size.z % T)
end

# SIMD-groups are formed from consecutive linear thread indices, so only the last one of a
# threadgroup can be partial
@inline function active_simdgroup_size()
    size = threads_per_threadgroup()
    threads = size.x * size.y * size.z
    first_thread = (simdgroup_index_in_threadgroup() - 0x1) * threads_per_simdgroup()
    return min(threads_per_simdgroup(), threads - first_thread)
end

@device_override KI.get_sub_group_size(::Type{T}) where {T} = active_simdgroup_size() % T

@device_override KI.get_max_sub_group_size(::Type{T}) where {T} = threads_per_simdgroup() % T

@device_override KI.get_num_sub_groups(::Type{T}) where {T} = simdgroups_per_threadgroup() % T

@device_override KI.get_sub_group_id(::Type{T}) where {T} = simdgroup_index_in_threadgroup() % T

@device_override KI.get_sub_group_local_id(::Type{T}) where {T} = thread_index_in_simdgroup() % T


## shared memory

@device_override @inline function KI.localmemory(::Type{T}, ::Val{Dims}) where {T, Dims}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(Dims)))
    MtlDeviceArray(Dims, ptr)
end


## events

# signal a new event once the work the task has queued so far completes
@autoreleasepool function KI.record_event(::MetalBackend)
    dev = device()
    event = MTLSharedEvent(dev)
    value = event.signaledValue + 1
    # committing the command buffer first submits the task's open batch of work
    cmdbuf = MTLCommandBuffer(global_queue(dev))
    encode_signal!(cmdbuf, event, value)
    commit!(cmdbuf)
    return (event, value)
end

# make the GPU wait, instead of blocking the host: the wait goes into the task's open batch
# of work, before the work that is queued next
function KI.wait_event(::MetalBackend, ev::Tuple{MTLSharedEvent, UInt64})
    event, value = ev
    bq = global_queue(device())
    # other tasks may commit the open batch, but only while holding this lock
    Base.@lock Metal.submission_lock begin
        Metal.end_encoder!(bq)
        encode_wait!(Metal.ensure_cmdbuf!(bq), event, value)
        Metal.record_operation!(bq, event)
    end
    Metal.maybe_autoflush!(bq)
    return
end


## synchronization and printing

@device_override @inline function KI.barrier()
    threadgroup_barrier(Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup)
end

@device_override @inline function KI.sub_group_barrier()
    simdgroup_barrier(Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup)
end

@device_override function KI.shfl_down(val::T, offset::Integer) where T
    simd_shuffle_down(val, offset)
end

@device_override @inline function KI._print(args...)
    Metal._mtlprint(args...)
end

end
