struct Adaptor end

# convert Metal Buffers Metal device pointers # should be generic
Adapt.adapt_storage(to::Adaptor, p::MtlBuffer{T}) where {T} = reinterpret(Core.LLVMPtr{T,AS.Device}, handle(p))

# Base.RefValue isn't GPU compatible, so provide a compatible alternative
struct MtlRefValue{T} <: Ref{T}
  x::T
end
Base.getindex(r::MtlRefValue) = r.x
Adapt.adapt_structure(to::Adaptor, r::Base.RefValue) = MtlRefValue(adapt(to, r[]))

"""
    mtlconvert(x)
This function is called for every argument to be passed to a kernel, allowing it to be
converted to a GPU-friendly format. By default, the function does nothing and returns the
input object `x` as-is.
Do not add methods to this function, but instead extend the underlying Adapt.jl package and
register methods for the the `CUDAnative.Adaptor` type.
"""
mtlconvert(arg) = adapt(Adaptor(), arg)
