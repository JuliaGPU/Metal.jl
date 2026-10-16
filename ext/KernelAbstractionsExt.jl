module KernelAbstractionsExt

using Metal

import KernelAbstractions as KA

import Adapt

Adapt.adapt_storage(::KA.CPU, a::MtlArray) = convert(Array, a)

# `@Const` applies `constify` inside the kernel, where arguments have already been
# converted to device arrays, so the rule has to be registered for `MtlDeviceArray`
# rather than for `MtlArray`.
Adapt.adapt_storage(::KA.ConstAdaptor, a::MtlDeviceArray) = Base.Experimental.Const(a)

end
