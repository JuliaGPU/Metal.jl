## Some extra definitions for MPSDataType defined in libmps.jl

## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MPSDataType}, x::Integer) = MPSDataType(x)

# Conversions for MPSDataTypes with Julia equivalents
const jl_mps_to_typ = Dict{MPSDataType, DataType}()
for type in [
        :Bool, :UInt8, :UInt16, :UInt32, :UInt64, :Int8, :Int16, :Int32, :Int64,
        :Float16, :BFloat16, :Float32, (:ComplexF16, :MPSDataTypeComplexFloat16),
        (:ComplexF32, :MPSDataTypeComplexFloat32),
    ]
    jltype, mpstype = if type isa Symbol
        type, Symbol(:MPSDataType, type)
    else
        type
    end
    @eval Base.convert(::Type{MPSDataType}, ::Type{$jltype}) = $(mpstype)
    @eval jl_mps_to_typ[$(mpstype)] = $jltype
end
Base.sizeof(t::MPSDataType) = sizeof(jl_mps_to_typ[t])

Base.convert(::Type{DataType}, mpstyp::MPSDataType) = jl_mps_to_typ[mpstyp]
