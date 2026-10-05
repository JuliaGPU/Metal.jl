module KernelAbstractionsExt

using Metal
using Metal: @device_override

import KernelAbstractions as KA

import Adapt

Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)

## scratch memory

@device_override @inline function KA.Scratchpad(ctx, ::Type{T}, ::Val{Dims}) where {T, Dims}
    # the thread's private memory is LLVM addrspace 0
    KA.PrivateArray{T}(undef, Val(Dims), Val(Metal.AS.Generic))
end

end
