module KernelAbstractionsExt

using Metal
using Metal: @device_override

import KernelAbstractions as KA

import GPUCompiler

import Adapt

Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)

## scratch memory

@device_override @inline function KA.Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    # private per-workitem scratch: a stack `alloca` (lowered by GPUCompiler) wrapped in a
    # device array, in the thread's private memory (LLVM addrspace 0)
    ptr = GPUCompiler.alloca(T, Val(prod(Dims)), Val(Metal.AS.Generic))
    MtlDeviceArray(Dims, ptr)
end

end
