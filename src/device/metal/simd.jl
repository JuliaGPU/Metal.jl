# Single Instruction Multiple Data

export simd_shuffle_down, simd_shuffle_up

# Shuffles
@device_function simd_shuffle_down(data::Float32,  delta::Integer) = ccall("extern air.simd_shuffle_down.f32", llvmcall, Cfloat, (Cfloat, Cshort), data, delta)
@device_function simd_shuffle_down(data::Float16,  delta::Integer) = ccall("extern air.simd_shuffle_down.f16", llvmcall, Float16, (Float16, Cshort), data, delta)
@device_function simd_shuffle_down(data::Int32,    delta::Integer) = ccall("extern air.simd_shuffle_down.s.i32", llvmcall, Cint, (Cint, Cshort), data, delta)
@device_function simd_shuffle_down(data::UInt32,   delta::Integer) = ccall("extern air.simd_shuffle_down.u.i32", llvmcall, Cuint, (Cuint, Cshort), data, delta)
@device_function simd_shuffle_down(data::Int16,    delta::Integer) = ccall("extern air.simd_shuffle_down.s.i16", llvmcall, Cshort, (Cshort, Cshort), data, delta)
@device_function simd_shuffle_down(data::UInt16,   delta::Integer) = ccall("extern air.simd_shuffle_down.u.i16", llvmcall, Cushort, (Cushort, Cshort), data, delta)
@device_function simd_shuffle_down(data::Int8,     delta::Integer) = ccall("extern air.simd_shuffle_down.s.i8", llvmcall, Cchar, (Cchar, Cshort), data, delta)
@device_function simd_shuffle_down(data::UInt8,    delta::Integer) = ccall("extern air.simd_shuffle_down.u.i8", llvmcall, Cuchar, (Cuchar, Cshort), data, delta)

@device_function simd_shuffle_up(data::Float32,  delta::Integer) = ccall("extern air.simd_shuffle_up.f32", llvmcall, Cfloat, (Cfloat, Cshort), data, delta)
@device_function simd_shuffle_up(data::Float16,  delta::Integer) = ccall("extern air.simd_shuffle_up.f16", llvmcall, Float16, (Float16, Cshort), data, delta)
@device_function simd_shuffle_up(data::Int32,    delta::Integer) = ccall("extern air.simd_shuffle_up.s.i32", llvmcall, Cint, (Cint, Cshort), data, delta)
@device_function simd_shuffle_up(data::UInt32,   delta::Integer) = ccall("extern air.simd_shuffle_up.u.i32", llvmcall, Cuint, (Cuint, Cshort), data, delta)
@device_function simd_shuffle_up(data::Int16,    delta::Integer) = ccall("extern air.simd_shuffle_up.s.i16", llvmcall, Cshort, (Cshort, Cshort), data, delta)
@device_function simd_shuffle_up(data::UInt16,   delta::Integer) = ccall("extern air.simd_shuffle_up.u.i16", llvmcall, Cushort, (Cushort, Cshort), data, delta)
@device_function simd_shuffle_up(data::Int8,     delta::Integer) = ccall("extern air.simd_shuffle_up.s.i8", llvmcall, Cchar, (Cchar, Cshort), data, delta)
@device_function simd_shuffle_up(data::UInt8,    delta::Integer) = ccall("extern air.simd_shuffle_up.u.i8", llvmcall, Cuchar, (Cuchar, Cshort), data, delta)
