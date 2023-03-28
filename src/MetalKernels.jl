module MetalKernels

import KernelAbstractions
import Metal
import StaticArrays
import GPUCompiler

struct MetalBackend <: KernelAbstractions.GPU
end

export MetalBackend

KernelAbstractions.allocate(::MetalBackend, ::Type{T}, dims::Tuple) where T = Metal.MtlArray{T}(undef, dims)
KernelAbstractions.zeros(::MetalBackend, ::Type{T}, dims::Tuple) where T = Metal.zeros(T, dims)
KernelAbstractions.ones(::MetalBackend, ::Type{T}, dims::Tuple) where T = Metal.ones(T, dims)

# Import through parent
import KernelAbstractions: StaticArrays, Adapt
import .StaticArrays: MArray

KernelAbstractions.get_backend(::Metal.MtlArray) = MetalBackend()
KernelAbstractions.synchronize(::MetalBackend) = Metal.synchronize()
KernelAbstractions.supports_float64(::MetalBackend) = false
KernelAbstractions.supports_atomics(::MetalBackend) = false

Adapt.adapt_storage(::MetalBackend, a::Array) = Adapt.adapt(Metal.MtlArray, a)
Adapt.adapt_storage(::MetalBackend, a::Metal.MtlArray) = a
Adapt.adapt_storage(::KernelAbstractions.CPU, a::Metal.MtlArray) = convert(Array, a)

function KernelAbstractions.copyto!(::MetalBackend, A::Metal.MtlArray{T}, B::Metal.MtlArray{T}) where T
    if Metal.device(dest) == Metal.device(src)
        GC.@preserve A B unsafe_copyto!(Metal.device(A), pointer(A), pointer(B), length(A); async=true)
        return A
    else
        error("Copy between different devices not implemented")
    end
end

function KernelAbstractions.copyto!(::MetalBackend, A::Array{T}, B::Metal.MtlArray{T}) where T
    GC.@preserve A B unsafe_copyto!(Metal.device(B), pointer(A), pointer(B), length(A); async=true)
    return A
end

function KernelAbstractions.copyto!(::MetalBackend, A::Metal.MtlArray{T}, B::Array{T}) where T
    GC.@preserve A B unsafe_copyto!(Metal.device(A), pointer(A), pointer(B), length(A); async=true)
    return A
end

import KernelAbstractions: Kernel, StaticSize, DynamicSize, partition, blocks, workitems, launch_config

###
# Kernel launch
###
function launch_config(kernel::Kernel{MetalBackend}, ndrange, workgroupsize)
    if ndrange isa Integer
        ndrange = (ndrange,)
    end
    if workgroupsize isa Integer
        workgroupsize = (workgroupsize, )
    end

    # partition checked that the ndrange's agreed
    if KernelAbstractions.ndrange(kernel) <: StaticSize
        ndrange = nothing
    end

    iterspace, dynamic = if KernelAbstractions.workgroupsize(kernel) <: DynamicSize &&
        workgroupsize === nothing
        # use ndrange as preliminary workgroupsize for autotuning
        partition(kernel, ndrange, ndrange)
    else
        partition(kernel, ndrange, workgroupsize)
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

function (obj::Kernel{MetalBackend})(args...; ndrange=nothing, workgroupsize=nothing)
    ndrange, workgroupsize, iterspace, dynamic = launch_config(obj, ndrange, workgroupsize)
    # this might not be the final context, since we may tune the workgroupsize
    ctx = mkcontext(obj, ndrange, iterspace)
    kernel = Metal.@metal launch=false obj.f(ctx, args...)

    is_dynamic =
        KernelAbstractions.workgroupsize(obj) <: DynamicSize &&
        isnothing(workgroupsize)
    if is_dynamic
        groupsize = kernel.pipeline.maxTotalThreadsPerThreadgroup
        new_workgroupsize = threads_to_workgroupsize(groupsize, ndrange)
        iterspace, dynamic = partition(obj, ndrange, new_workgroupsize)
        ctx = mkcontext(obj, ndrange, iterspace)
    end

    nblocks = length(blocks(iterspace))
    threads = length(workitems(iterspace))

    if nblocks == 0
        return nothing
    end

    # Launch kernel
    kernel(ctx, args...; threads=threads, groups=nblocks)
    return nothing
end

####################################################################################################

import KernelAbstractions: CompilerMetadata, DynamicCheck, LinearIndices
import KernelAbstractions: __index_Local_Linear, __index_Group_Linear, __index_Global_Linear, __index_Local_Cartesian, __index_Group_Cartesian, __index_Global_Cartesian, __validindex, __print
import KernelAbstractions: mkcontext, expand, __iterspace, __ndrange, __dynamic_checkbounds

function mkcontext(kernel::Kernel{MetalBackend}, _ndrange, iterspace)
    CompilerMetadata{KernelAbstractions.ndrange(kernel), DynamicCheck}(_ndrange, iterspace)
end
function mkcontext(kernel::Kernel{MetalBackend}, I, _ndrange, iterspace, ::Dynamic) where Dynamic
    CompilerMetadata{KernelAbstractions.ndrange(kernel), Dynamic}(I, _ndrange, iterspace)
end

@Metal.device_override @inline function __index_Local_Linear(ctx)
    return Metal.thread_position_in_threadgroup_1d()
end

@Metal.device_override @inline function __index_Group_Linear(ctx)
    return Metal.threadgroup_position_in_grid_1d()
end

@Metal.device_override @inline function __index_Global_Linear(ctx)
    return Metal.thread_position_in_grid_1d()
end

@Metal.device_override @inline function __index_Local_Cartesian(ctx)
    @inbounds workitems(__iterspace(ctx))[Metal.thread_position_in_threadgroup_1d()]
end

@Metal.device_override @inline function __index_Group_Cartesian(ctx)
    @inbounds blocks(__iterspace(ctx))[Metal.threadgroup_position_in_grid_1d()]
end

@Metal.device_override @inline function __index_Global_Cartesian(ctx)
    return @inbounds expand(__iterspace(ctx), Metal.threadgroup_position_in_grid_1d(), Metal.thread_position_in_threadgroup_1d())
end

@Metal.device_override @inline function __validindex(ctx)
    if __dynamic_checkbounds(ctx)
        I = @inbounds expand(__iterspace(ctx), Metal.threadgroup_position_in_grid_1d(), Metal.thread_position_in_threadgroup_1d())
        return I in __ndrange(ctx)
    else
        return true
    end
end

import KernelAbstractions: groupsize, __groupsize, __workitems_iterspace
import KernelAbstractions: SharedMemory, Scratchpad, __synchronize, __size

###
# GPU implementation of shared memory
###
@Metal.device_override @inline function SharedMemory(::Type{T}, ::Val{Dims}, ::Val{Id}) where {T, Dims, Id}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(Dims)))
    Metal.MtlDeviceArray(Dims, ptr)
end

###
# GPU implementation of scratch memory
# - private memory for each workitem
###

@Metal.device_override @inline function Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    StaticArrays.MArray{__size(Dims), T}(undef)
end

@Metal.device_override @inline function __synchronize()
    Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)
end

@Metal.device_override @inline function __print(args...)
    # TODO
end

KernelAbstractions.argconvert(::Kernel{MetalBackend}, arg) = Metal.mtlconvert(arg)

end
