export MtlSimdgroupMatrix

"""
    MtlSimdgroupMatrix{T,R,C}

Typed wrapper around a SIMD-group matrix fragment. `T` is the element type
(`Float16` or `Float32`); `R` and `C` are the matrix dimensions. Only the
8×8 shape is supported by current Apple GPUs.

The fragment data is distributed across the 32 lanes of a SIMD-group; the
per-lane element layout is implementation-defined and elements cannot be
accessed directly. To inspect or modify individual entries, store the
matrix to device or threadgroup memory first.

Construct via [`simdgroup_load`](@ref), [`zero`](@ref) or the explicit
fill constructor `MtlSimdgroupMatrix{T,8,8}(val::T)`.
"""
struct MtlSimdgroupMatrix{T,R,C}
    data::NTuple{64, VecElement{T}}

    global _unsafe_wrap_simdgroup_matrix(::Type{MtlSimdgroupMatrix{T,R,C}},
                                        data::NTuple{64, VecElement{T}}) where {T,R,C} =
        new{T,R,C}(data)
end

Base.size(::Type{<:MtlSimdgroupMatrix{<:Any,R,C}}) where {R,C} = (R, C)
Base.size(m::MtlSimdgroupMatrix) = size(typeof(m))
Base.eltype(::Type{<:MtlSimdgroupMatrix{T}}) where {T} = T
Base.eltype(m::MtlSimdgroupMatrix) = eltype(typeof(m))

# Fill constructor: materialize a fragment whose elements are all `val`.
@inline function MtlSimdgroupMatrix{T,8,8}(val::T) where {T}
    return _unsafe_wrap_simdgroup_matrix(MtlSimdgroupMatrix{T,8,8},
                                         ntuple(_ -> VecElement{T}(val), Val(64)))
end

@inline Base.zero(::Type{MtlSimdgroupMatrix{T,8,8}}) where {T} =
    MtlSimdgroupMatrix{T,8,8}(zero(T))

# Load: build a fragment from a device or threadgroup array tile.
@device_function @inline function simdgroup_load(::Type{MtlSimdgroupMatrix{T,8,8}},
                                                 src::MtlDeviceArray{T},
                                                 matrix_origin::NTuple{2, Int64} = (1, 1)) where {T}
    return _unsafe_wrap_simdgroup_matrix(MtlSimdgroupMatrix{T,8,8},
                                         simdgroup_load(src, matrix_origin))
end

# Store: write the fragment back to a device or threadgroup array tile.
@device_function @inline function simdgroup_store(m::MtlSimdgroupMatrix{T,8,8},
                                                  dest::MtlDeviceArray{T},
                                                  matrix_origin::NTuple{2, Int64} = (1, 1)) where {T}
    return simdgroup_store(m.data, dest, matrix_origin)
end

# Multiply: D = A * B.
@inline function Base.:(*)(a::MtlSimdgroupMatrix{T,8,8},
                           b::MtlSimdgroupMatrix{T,8,8}) where {T}
    return _unsafe_wrap_simdgroup_matrix(MtlSimdgroupMatrix{T,8,8},
                                         simdgroup_multiply(a.data, b.data))
end

# Fused multiply-add: D = A * B + C.
@inline function Base.muladd(a::MtlSimdgroupMatrix{T,8,8},
                             b::MtlSimdgroupMatrix{T,8,8},
                             c::MtlSimdgroupMatrix{T,8,8}) where {T}
    return _unsafe_wrap_simdgroup_matrix(MtlSimdgroupMatrix{T,8,8},
                                         simdgroup_multiply_accumulate(a.data, b.data, c.data))
end
