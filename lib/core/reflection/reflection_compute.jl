export MtlComputePipelineReflection

const MTLComputePipelineReflection = Ptr{MtComputePipelineReflection}

mutable struct MtlComputePipelineReflection
    handle::MTLComputePipelineReflection

    "Get a handle to a kernel function in a Metal Library."
    function MtlComputePipelineReflection(handle)
        obj = new(handle)
        finalizer(unsafe_destroy!, obj)
        return obj
    end
end

function unsafe_destroy!(fun::MtlComputePipelineReflection)
    fun.handle !== C_NULL && mtRelease(fun.handle)
end

Base.unsafe_convert(::Type{MTLComputePipelineReflection}, fun::MtlComputePipelineReflection) = fun.handle

Base.:(==)(a::MtlComputePipelineReflection, b::MtlComputePipelineReflection) = a.handle == b.handle
Base.hash(fun::MtlComputePipelineReflection, h::UInt) = hash(mod.handle, h)

function arguments(refl::MtlComputePipelineReflection)
    args = mtComputePipelinereflectionArguments(refl)
    

end
