module MetalKernels

using ..Metal
using ..Metal: @device_override, DefaultStorageMode, SharedStorage, mtlfunction, mtlconvert

import KernelAbstractions as KA
import KernelAbstractions: KernelIntrinsics as KI

using StaticArrays: MArray

import Adapt


## back-end

export MetalBackend

"""
    struct MetalBackend <: KernelAbstractions.GPU

The `KernelAbstractions` backend for running on Metal GPUs.
"""
struct MetalBackend <: KA.GPU
end

# Ensure type stability. See JuliaGPU/KernelAbstractions#634
@inline KA.allocate(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = MtlArray{T, length(dims), unified ? SharedStorage : DefaultStorageMode}(undef, dims)
KA.zeros(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = Metal.zeros(T, dims; storage=unified ? SharedStorage : DefaultStorageMode)
KA.ones(::MetalBackend, ::Type{T}, dims::Tuple; unified::Bool = false) where T = Metal.ones(T, dims; storage=unified ? SharedStorage : DefaultStorageMode)

KA.get_backend(::MtlArray) = MetalBackend()
KA.synchronize(::MetalBackend) = synchronize()

KA.functional(::MetalBackend) = Metal.functional()

KA.supports_float64(::MetalBackend) = false
KA.supports_atomics(::MetalBackend) = false
KA.supports_unified(::MetalBackend) = true

Adapt.adapt_storage(::MetalBackend, a::Array) = Adapt.adapt(MtlArray, a)
Adapt.adapt_storage(::MetalBackend, a::MtlArray) = a
Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)


## memory operations

function KA.copyto!(::MetalBackend, dest::MtlArray{T}, src::MtlArray{T}) where T
    if device(dest) == device(src)
        GC.@preserve dest src copyto!(dest, src)
        return dest
    else
        error("Copy between different devices not implemented")
    end
end

function KA.copyto!(::MetalBackend, dest::Array{T}, src::MtlArray{T}) where T
    GC.@preserve dest src copyto!(dest, src)
    return dest
end

function KA.copyto!(::MetalBackend, dest::MtlArray{T}, src::Array{T}) where T
    GC.@preserve dest src copyto!(dest, src)
    return dest
end


## kernel launch

function KA.mkcontext(kernel::KA.Kernel{MetalBackend}, _ndrange, iterspace)
    KA.CompilerMetadata{KA.ndrange(kernel), KA.DynamicCheck}(_ndrange, iterspace)
end
function KA.mkcontext(kernel::KA.Kernel{MetalBackend}, I, _ndrange, iterspace,
                      ::Dynamic) where Dynamic
    KA.CompilerMetadata{KA.ndrange(kernel), Dynamic}(I, _ndrange, iterspace)
end

function KA.launch_config(kernel::KA.Kernel{MetalBackend}, ndrange, workgroupsize)
    if ndrange isa Integer
        ndrange = (ndrange,)
    end
    if workgroupsize isa Integer
        workgroupsize = (workgroupsize, )
    end

    # partition checked that the ndrange's agreed
    if KA.ndrange(kernel) <: KA.StaticSize
        ndrange = nothing
    end

    iterspace, dynamic = if KA.workgroupsize(kernel) <: KA.DynamicSize &&
                            workgroupsize === nothing
        # use ndrange as preliminary workgroupsize for autotuning
        KA.partition(kernel, ndrange, ndrange)
    else
        KA.partition(kernel, ndrange, workgroupsize)
    end

    return ndrange, workgroupsize, iterspace, dynamic
end

function threads_to_workgroupsize(threads, ndrange)
    total = 1
    return map(ndrange) do n
        x = min(div(threads, total), n)
        total *= x
        return x
    end
end

KA.argconvert(::KA.Kernel{MetalBackend}, arg) = Metal.mtlconvert(arg)

function (obj::KA.Kernel{MetalBackend})(args...; ndrange=nothing, workgroupsize=nothing)
    ndrange, workgroupsize, iterspace, dynamic = KA.launch_config(obj, ndrange, workgroupsize)
    # this might not be the final context, since we may tune the workgroupsize
    ctx = KA.mkcontext(obj, ndrange, iterspace)
    kernel = @metal launch=false obj.f(ctx, args...)

    if KA.workgroupsize(obj) <: KA.DynamicSize && workgroupsize === nothing
        groupsize = kernel.pipeline.maxTotalThreadsPerThreadgroup
        new_workgroupsize = threads_to_workgroupsize(groupsize, ndrange)
        iterspace, dynamic = KA.partition(obj, ndrange, new_workgroupsize)
        ctx = KA.mkcontext(obj, ndrange, iterspace)
    end

    groups = length(KA.blocks(iterspace))
    threads = length(KA.workitems(iterspace))

    if groups == 0
        return nothing
    end

    # Launch kernel
    kernel(ctx, args...; threads, groups)
    return nothing
end

KI.kiconvert(::MetalBackend, arg) = mtlconvert(arg)

function KI.kifunction(::MetalBackend, f::F, tt::TT=Tuple{}; name=nothing, kwargs...) where {F,TT}
    kern = mtlfunction(f, tt; name, kwargs...)
    KI.KIKernel{MetalBackend, typeof(kern)}(MetalBackend(), kern)
end

function (obj::KI.KIKernel{MetalBackend})(args...; numworkgroups=nothing, workgroupsize=nothing)
    threadsPerThreadgroup = isnothing(workgroupsize) ? 1 : workgroupsize
    threadgroupsPerGrid = isnothing(numworkgroups) ? 1 : numworkgroups

    obj.kern(args...; threads=threadsPerThreadgroup, groups=threadgroupsPerGrid)
end


function KI.kernel_max_work_group_size(::MetalBackend, kikern::KI.KIKernel{<:MetalBackend}; max_work_items::Int=typemax(Int))::Int
    Int(min(kikern.kern.pipeline.maxTotalThreadsPerThreadgroup, max_work_items))
end
function KI.max_work_group_size(::MetalBackend)::Int
    Int(device().maxThreadsPerThreadgroup.width)
end
function KI.multiprocessor_count(::MetalBackend)::Int
    Metal.num_gpu_cores()
end



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

@device_override @inline function KA.__validindex(ctx)
    if KA.__dynamic_checkbounds(ctx)
        I = @inbounds KA.expand(KA.__iterspace(ctx), threadgroup_position_in_grid().x,
                                thread_position_in_threadgroup().x)
        return I in KA.__ndrange(ctx)
    else
        return true
    end
end


## shared memory

@device_override @inline function KI.localmemory(::Type{T}, ::Val{Dims}) where {T, Dims}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(Dims)))
    MtlDeviceArray(Dims, ptr)
end

@device_override @inline function KA.Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    MArray{KA.__size(Dims), T}(undef)
end


## other

@device_override @inline function KI.barrier()
    threadgroup_barrier(Metal.MemoryFlagDevice | Metal.MemoryFlagThreadGroup)
end

@device_override @inline function KI._print(args...)
    # TODO
end
## COV_EXCL_STOP

end
