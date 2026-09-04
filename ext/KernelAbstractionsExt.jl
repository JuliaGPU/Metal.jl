module KernelAbstractionsExt # Should be same name as the file (just like a normal package)

using Metal
using Metal: @device_override
using GPUCompiler
import KernelAbstractions as KA
using Adapt

Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)

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
    total = Ref(1)
    return map(ndrange) do n
        x = min(div(threads, total[]), n)
        total[] *= x
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

@device_override @inline function KA.__validindex(ctx)
    if KA.__dynamic_checkbounds(ctx)
        I = @inbounds KA.expand(KA.__iterspace(ctx), threadgroup_position_in_grid().x,
                                thread_position_in_threadgroup().x)
        return I in KA.__ndrange(ctx)
    else
        return true
    end
end

@device_override @inline function KA.Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    # private per-workitem scratch: a stack `alloca` (lowered by GPUCompiler) wrapped in a
    # device array. the slot lives in OpenCL "Function" storage (LLVM addrspace 0), which is
    # where the SPIR-V target places allocas.
    ptr = GPUCompiler.alloca(T, Val(prod(Dims)), Val(Metal.AS.Generic))
    MtlDeviceArray(Dims, ptr)
end


end # module
