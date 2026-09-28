module MetalInterface

using ..Metal
using ..Metal: @device_override, DefaultStorageMode, SharedStorage, mtlfunction, mtlconvert, metal_support
using GPUCompiler

import KernelInterface as KI

import Adapt


## back-end

# export MetalBackend

"""
    struct MetalBackend <: KernelInterface.Backend

The `KernelInterface` backend for running on Metal GPUs.
"""
struct MetalBackend <: KI.Backend
end

KI.versioninfo(io::IO, ::MetalBackend) = Metal.versioninfo(io)

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


## memory operations

# Metal's copies are synchronous, so they are ordered with the task's queue
const HostOrDevice{T} = Union{Array{T}, MtlArray{T}}
function KI.copyto!(::MetalBackend, dest::HostOrDevice{T}, src::HostOrDevice{T}) where T
    length(dest) == length(src) ||
        throw(ArgumentError("Arrays must have the same length, got $(length(dest)) and $(length(src))"))
    GC.@preserve dest src copyto!(dest, src)
    return dest
end
KI.copyto!(::MetalBackend, dest, src) =
    throw(ArgumentError("KernelInterface.copyto! only supports dense arrays of the same element type, got $(typeof(dest)) and $(typeof(src))"))

KI.unsafe_free!(A::MtlArray) = Metal.unsafe_free!(A)


## kernel launch

KI.argconvert(::MetalBackend, arg) = mtlconvert(arg)

# The SIMD-group width is a property of the compiled pipeline (`threadExecutionWidth`), but
# it is the same for all pipelines on Apple GPUs. `kernel_function` checks that, so that
# `KI.sub_group_size` can promise it before compiling.
const SIMD_WIDTH = 32

function KI.kernel_function(backend::MetalBackend, f::F, tt::TT=Tuple{}; name=nothing, kwargs...) where {F,TT}
    kern = mtlfunction(f, tt; name, kwargs...)
    kern.exec_width == SIMD_WIDTH ||
        error("Kernel compiled with a SIMD-group width of $(kern.exec_width), while KernelInterface.sub_group_size promises $SIMD_WIDTH")
    KI.Kernel{MetalBackend, typeof(kern)}(backend, kern)
end

function KI.launch(obj::KI.Kernel{MetalBackend}, groups::Dims{3}, items::Dims{3}, args::Vararg{Any, N}; kwargs...) where {N}
    obj.kern(args...; threads=items, groups, kwargs...)
    return
end

# the pipeline's `maxTotalThreadsPerThreadgroup`
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

function KI.record_event(::MetalBackend)
    dev = device()
    ev = Metal.MTLSharedEvent(dev)
    val = ev.signaledValue + 1
    cmdbuf = Metal.MTLCommandBuffer(global_queue(dev))
    MTL.encode_signal!(cmdbuf, ev, val)
    Metal.commit!(cmdbuf)

    return (ev, val)
end

# make the GPU wait, instead of blocking the host: the wait goes into the task's open batch
# of work, before the work that is queued next
function KI.wait_event(::MetalBackend, ev::Tuple{Metal.MTLSharedEvent, UInt64})
    event, value = ev
    bq = global_queue(device())
    Metal.end_encoder!(bq)
    MTL.encode_wait!(Metal.ensure_cmdbuf!(bq), event, value)
    Metal.record_operation!(bq, event)
    Metal.maybe_autoflush!(bq)
    return
end

## other

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
