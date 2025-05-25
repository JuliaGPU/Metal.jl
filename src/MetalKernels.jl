module MetalKernels

using ..Metal
using ..Metal: @device_override

import KernelAbstractions as KA

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

KA.allocate(::MetalBackend, ::Type{T}, dims::Tuple) where T = MtlArray{T}(undef, dims)
KA.zeros(::MetalBackend, ::Type{T}, dims::Tuple) where T = Metal.zeros(T, dims)
KA.ones(::MetalBackend, ::Type{T}, dims::Tuple) where T = Metal.ones(T, dims)

KA.get_backend(::MtlArray) = MetalBackend()
KA.synchronize(::MetalBackend) = synchronize()

KA.functional(::MetalBackend) = Metal.functional()

KA.supports_float64(::MetalBackend) = false
KA.supports_atomics(::MetalBackend) = false

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


## indexing

## COV_EXCL_START
@device_override @inline function KA.__index_Local_Linear(ctx)
    return thread_position_in_threadgroup_1d()
end

@device_override @inline function KA.__index_Group_Linear(ctx)
    return threadgroup_position_in_grid_1d()
end

@device_override @inline function KA.__index_Global_Linear(ctx)
    I =  @inbounds KA.expand(KA.__iterspace(ctx), threadgroup_position_in_grid_1d(), thread_position_in_threadgroup_1d())
    # TODO: This is unfortunate, can we get the linear index cheaper
    @inbounds LinearIndices(KA.__ndrange(ctx))[I]
end

@device_override @inline function KA.__index_Local_Cartesian(ctx)
    @inbounds KA.workitems(KA.__iterspace(ctx))[thread_position_in_threadgroup_1d()]
end

@device_override @inline function KA.__index_Group_Cartesian(ctx)
    @inbounds KA.blocks(KA.__iterspace(ctx))[threadgroup_position_in_grid_1d()]
end

@device_override @inline function KA.__index_Global_Cartesian(ctx)
    return @inbounds KA.expand(KA.__iterspace(ctx), threadgroup_position_in_grid_1d(),
                               thread_position_in_threadgroup_1d())
end

@device_override @inline function KA.__validindex(ctx)
    if KA.__dynamic_checkbounds(ctx)
        I = @inbounds KA.expand(KA.__iterspace(ctx), threadgroup_position_in_grid_1d(),
                                thread_position_in_threadgroup_1d())
        return I in KA.__ndrange(ctx)
    else
        return true
    end
end


## shared memory

@device_override @inline function KA.SharedMemory(::Type{T}, ::Val{Dims},
                                                  ::Val{Id}) where {T, Dims, Id}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(Dims)))
    MtlDeviceArray(Dims, ptr)
end

@device_override @inline function KA.Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    MArray{KA.__size(Dims), T}(undef)
end


## other

@device_override @inline function KA.__synchronize()
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)
end

@device_override @inline function KA.__print(args...)
    # TODO
end
## COV_EXCL_STOP

end
