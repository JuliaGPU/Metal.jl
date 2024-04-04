module BFloat16sExt

using Metal: MPS.MPSDataType, MPS.MPSDataTypeBFloat16, MPS.jl_mps_to_typ, macos_version
using BFloat16s

# BFloat is only supported in MPS starting in MacOS 14
if macos_version() >= v"14"
    Base.convert(::Type{MPSDataType}, ::Type{BFloat16}) = MPSDataTypeBFloat16
    jl_mps_to_typ[MPSDataTypeBFloat16] = BFloat16
end

end # module
