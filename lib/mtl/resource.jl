# Extra definition for MTLResourceOptions defined in libmtl.jl
## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MTLResourceOptions}, x::Integer) = MTLResourceOptions(x)

#
# resourcs
#

export MTLResource

# @objcwrapper MTLResource <: MTLAllocation
