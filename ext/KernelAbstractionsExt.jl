module KernelAbstractionsExt

using Metal

import KernelAbstractions as KA

import Adapt

Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)

end
