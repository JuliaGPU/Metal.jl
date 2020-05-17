@inline cos(x::Float32) = ccall("extern @air.cos.f32", llvmcall, Cfloat, (Cfloat,), x)
@inline cos_fast(x::Float32) = ccall("extern @air.fast_cos.f32", llvmcall, Cfloat, (Cfloat,), x)

@inline sin(x::Float32) = ccall("extern @air.sin.f32", llvmcall, Cfloat, (Cfloat,), x)
@inline sin_fast(x::Float32) = ccall("extern @air.fast_sin.f32", llvmcall, Cfloat, (Cfloat,), x)

@inline exp(x::Float32) = ccall("extern @air.exp.f32", llvmcall, Cfloat, (Cfloat,), x)
@inline exp_fast(x::Float32) = ccall("extern @air.fast_exp.f32", llvmcall, Cfloat, (Cfloat,), x)
