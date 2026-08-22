module MetalKernels

using ..Metal
using ..Metal: @device_override, DefaultStorageMode, SharedStorage, mtlfunction, mtlconvert, metal_support
using GPUCompiler

import KernelInterface as KI

import Adapt


## back-end

export MetalBackend

"""
    struct MetalBackend <: KernelAbstractions.GPU

The `KernelAbstractions` backend for running on Metal GPUs.
"""
struct MetalBackend <: KI.GPU
end

KI.versioninfo(io::IO, ::MetalBackend) = Metal.versioninfo(io)

# Ensure type stability. See JuliaGPU/KernelAbstractions#634
@inline KI.allocate(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = MtlArray{T, length(dims), unified ? SharedStorage : DefaultStorageMode}(undef, dims)
KI.zeros(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = Metal.zeros(T, dims; storage=unified ? SharedStorage : DefaultStorageMode)
KI.ones(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = Metal.ones(T, dims; storage=unified ? SharedStorage : DefaultStorageMode)

KI.get_backend(::MtlArray) = MetalBackend()
KI.synchronize(::MetalBackend) = synchronize()

KI.functional(::MetalBackend) = Metal.functional()

KI.supports_float64(::MetalBackend) = false
KI.supports_atomics(::MetalBackend) = metal_support() >= v"4.1"
KI.supports_unified(::MetalBackend) = true

Adapt.adapt_storage(::MetalBackend, a::Array) = Adapt.adapt(MtlArray, a)
Adapt.adapt_storage(::MetalBackend, a::MtlArray) = a


## memory operations

function KI.copyto!(::MetalBackend, dest::MtlArray{T}, src::MtlArray{T}) where T
    if device(dest) == device(src)
        GC.@preserve dest src copyto!(dest, src)
        return dest
    else
        error("Copy between different devices not implemented")
    end
end

function KI.copyto!(::MetalBackend, dest::Array{T}, src::MtlArray{T}) where T
    GC.@preserve dest src copyto!(dest, src)
    return dest
end

function KI.copyto!(::MetalBackend, dest::MtlArray{T}, src::Array{T}) where T
    GC.@preserve dest src copyto!(dest, src)
    return dest
end


## kernel launch

KI.argconvert(::MetalBackend, arg) = mtlconvert(arg)

function KI.kernel_function(::MetalBackend, f::F, tt::TT=Tuple{}; name=nothing, kwargs...) where {F,TT}
    kern = mtlfunction(f, tt; name, kwargs...)
    KI.Kernel{MetalBackend, typeof(kern)}(MetalBackend(), kern)
end

function (obj::KI.Kernel{MetalBackend})(args...; numworkgroups=(), workgroupsize=(), ndrange=(), max_work_group_size=typemax(Int))
    KI.check_launch_args(numworkgroups, workgroupsize, ndrange)
    prod(ndrange) == 0 && return nothing

    numworkgroups, workgroupsize = KI.auto_launch_sizes(obj, numworkgroups, workgroupsize, ndrange, max_work_group_size)

    obj.kern(args...; threads=workgroupsize, groups=numworkgroups)
end

function KI.kernel_max_work_group_size(kikern::KI.Kernel{<:MetalBackend}; max_work_items::Int=typemax(Int))::Int
    Int(min(kikern.kern.maxthreads, max_work_items))
end
function KI.max_work_group_size(::MetalBackend)::Int
    Int(device().maxThreadsPerThreadgroup.width)
end
function KI.sub_group_size(::MetalBackend)::Int
    32
end
function KI.multiprocessor_count(::MetalBackend)::Int
    Metal.num_gpu_cores()
end

KI.shfl_down_types(::MetalBackend) = DataType[Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, UInt8]



## indexing

## COV_EXCL_START
@device_override @inline function KI.get_local_id()
    return (; x = Int(thread_position_in_threadgroup().x), y = Int(thread_position_in_threadgroup().y), z = Int(thread_position_in_threadgroup().z))
end

@device_override @inline function KI.get_group_id()
    return (; x = Int(threadgroup_position_in_grid().x), y = Int(threadgroup_position_in_grid().y), z = Int(threadgroup_position_in_grid().z))
end

@device_override @inline function KI.get_global_id()
    return (; x = Int(thread_position_in_grid().x), y = Int(thread_position_in_grid().y), z = Int(thread_position_in_grid().z))
end

@device_override @inline function KI.get_local_size()
    return (; x = Int(threads_per_threadgroup().x), y = Int(threads_per_threadgroup().y), z = Int(threads_per_threadgroup().z))
end

@device_override @inline function KI.get_num_groups()
    return (; x = Int(threadgroups_per_grid().x), y = Int(threadgroups_per_grid().y), z = Int(threadgroups_per_grid().z))
end

@device_override @inline function KI.get_global_size()
    return (; x = Int(threads_per_grid().x), y = Int(threads_per_grid().y), z = Int(threads_per_grid().z))
end

@device_override KI.get_sub_group_size() = threads_per_simdgroup()

@device_override KI.get_max_sub_group_size() = threads_per_simdgroup()

@device_override KI.get_num_sub_groups() = simdgroups_per_threadgroup()

@device_override KI.get_sub_group_id() = simdgroup_index_in_threadgroup()

@device_override KI.get_sub_group_local_id() = thread_index_in_simdgroup()


## shared memory

@device_override @inline function KI.localmemory(::Type{T}, ::Val{Dims}) where {T, Dims}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(Dims)))
    MtlDeviceArray(Dims, ptr)
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
## COV_EXCL_STOP

end
