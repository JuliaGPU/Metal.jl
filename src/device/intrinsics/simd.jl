export simdgroup_load, simdgroup_store, simdgroup_multiply, simdgroup_multiply_accumulate,
        MtlSimdgroupMatrix,
        simd_shuffle_down, simd_shuffle_up, simd_shuffle_and_fill_down, simd_shuffle_and_fill_up,
        simd_shuffle, simd_shuffle_xor, simd_ballot, simd_vote_all, simd_vote_any,
        quad_shuffle_down, quad_shuffle_up, quad_shuffle_and_fill_down, quad_shuffle_and_fill_up,
        quad_shuffle, quad_shuffle_xor, quad_ballot, quad_vote_all, quad_vote_any

using Core: LLVMPtr

function convert_origin(origin::NTuple{2, Int64})
    return (VecElement{Int64}(origin[1]-1), VecElement{Int64}(origin[2]-1))
end

# the load/store intrinsics use their newest (AIR 2.8) signature, taking dims, strides
# and origin vectors. AIR 2.8 expresses transposition by swapping those vectors' elements:
# the transposed layout of a column-major matrix is dims = (8, epr), strides = (epr, 1),
# and a row/column-swapped origin, while the non-transposed layout swaps each to
# dims = (epr, 8), strides = (1, epr) and an unswapped origin. when targeting older AIR
# versions, `finish_ir!` rewrites these calls to the legacy elements-per-row + transpose
# flag signature (keep in sync with the downgrade rule in src/compiler/compilation.jl).
for (jltype, suffix) in ((:Float16, "f16"), (:Float32, "f32"), (:BFloat16, "bf16"))
    for as in (AS.Device, AS.ThreadGroup)
        @eval begin
            @device_function simdgroup_load(
                data::MtlDeviceArray{$jltype, <:Any, $as},
                matrix_origin::NTuple{2, Int64} = (1, 1),
                ::Val{transpose} = Val(true),
            ) where {transpose} = @typed_ccall($"air.simdgroup_matrix_8x8_load.v64$suffix.p$as$suffix",
                llvmcall, NTuple{64, VecElement{$jltype}},
                (LLVMPtr{$jltype, $as}, NTuple{2, VecElement{Int64}},
                 NTuple{2, VecElement{Int64}}, NTuple{2, VecElement{Int64}}),
                pointer(data),
                transpose ? (VecElement{Int64}(8), VecElement{Int64}(size(data)[1])) :
                            (VecElement{Int64}(size(data)[1]), VecElement{Int64}(8)),
                transpose ? (VecElement{Int64}(size(data)[1]), VecElement{Int64}(1)) :
                            (VecElement{Int64}(1), VecElement{Int64}(size(data)[1])),
                transpose ? convert_origin(reverse(matrix_origin)) :
                            convert_origin(matrix_origin))

            @device_function simdgroup_store(
                src::NTuple{64, VecElement{$jltype}},
                dest::MtlDeviceArray{$jltype, <:Any, $as},
                matrix_origin::NTuple{2, Int64} = (1, 1),
                ::Val{transpose} = Val(true),
            ) where {transpose} = @typed_ccall($"air.simdgroup_matrix_8x8_store.v64$suffix.p$as$suffix",
                llvmcall, Cvoid,
                (NTuple{64, VecElement{$jltype}}, LLVMPtr{$jltype, $as},
                 NTuple{2, VecElement{Int64}}, NTuple{2, VecElement{Int64}},
                 NTuple{2, VecElement{Int64}}),
                src, pointer(dest),
                transpose ? (VecElement{Int64}(8), VecElement{Int64}(size(dest)[1])) :
                            (VecElement{Int64}(size(dest)[1]), VecElement{Int64}(8)),
                transpose ? (VecElement{Int64}(size(dest)[1]), VecElement{Int64}(1)) :
                            (VecElement{Int64}(1), VecElement{Int64}(size(dest)[1])),
                transpose ? convert_origin(reverse(matrix_origin)) :
                            convert_origin(matrix_origin))
        end
    end

    @eval begin
        @device_function simdgroup_multiply(
            a::NTuple{64, VecElement{$jltype}},
            b::NTuple{64, VecElement{$jltype}},
        ) = ccall($"extern air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix",
            llvmcall, NTuple{64, VecElement{$jltype}},
            (NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}),
            a, b, ntuple(_ -> VecElement{$jltype}(0.0), Val(64)))

        @device_function simdgroup_multiply_accumulate(
            a::NTuple{64, VecElement{$jltype}},
            b::NTuple{64, VecElement{$jltype}},
            c::NTuple{64, VecElement{$jltype}},
        ) = ccall($"extern air.simdgroup_matrix_8x8_multiply_accumulate.v64$suffix.v64$suffix.v64$suffix.v64$suffix",
            llvmcall, NTuple{64, VecElement{$jltype}},
            (NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}, NTuple{64, VecElement{$jltype}}),
            a, b, c)
    end
end

## Documentation

@doc """
    simdgroup_load(data::MtlDeviceArray{T}, matrix_origin=(1, 1), Val(transpose)=Val(true))

Loads data from device or threadgroup memory into an 8x8 SIMD-group matrix
and returns it. `T` must be either `Float16`, `Float32`, or `BFloat16`.

# Arguments
- `matrix_origin::NTuple{2, Int64}=(1, 1)`: origin in the source memory to load from.
- `Val(transpose)::Val{Bool}=Val(true)`: whether to transpose the loaded matrix. The
  default `Val(true)` treats the column-major source as a regular (non-transposed)
  matrix; pass `Val(false)` to load the transpose.
""" simdgroup_load

@doc """
    simdgroup_store(src, dest::MtlDeviceArray{T}, matrix_origin=(1, 1), Val(transpose)=Val(true))

Stores data from an 8x8 SIMD-group matrix into device or threadgroup memory.
`T` must be either `Float16`, `Float32`, or `BFloat16`.

# Arguments
- `matrix_origin::NTuple{2, Int64}=(1, 1)`: origin in the destination memory to store to.
- `Val(transpose)::Val{Bool}=Val(true)`: whether to transpose the matrix on store. The
  default `Val(true)` matches the column-major convention; pass `Val(false)` to store the
  transpose.
""" simdgroup_store

@doc """
    simdgroup_multiply(a, b)

Returns `a * b`.
""" simdgroup_multiply

@doc """
    simdgroup_multiply_accumulate(a, b, c)

Returns `a * b + c`.
""" simdgroup_multiply_accumulate


## Typed wrapper

"""
    MtlSimdgroupMatrix{T,R,C}

Typed wrapper around a SIMD-group matrix fragment. `T` is the element type
(`Float16`, `Float32`, or `BFloat16`); `R` and `C` are the matrix dimensions. Only the
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


## SIMD Shuffle Up/Down

simd_shuffle_map = ((Float32, "f32"),
                    (Float16, "f16"),
                    (BFloat16,"bf16"),
                    (Int32,   "s.i32"),
                    (UInt32,  "u.i32"),
                    (Int16,   "s.i16"),
                    (UInt16,  "u.i16"),
                    (Int8,    "s.i8"),
                    (UInt8,   "u.i8"))

for (jltype, suffix) in simd_shuffle_map, (mod_f, prefix) in ((threads_per_simdgroup, "simd"),(()->UInt32(4), "quad"))
    _shuffle = Symbol(prefix, :_shuffle)
    _shuffle_xor = Symbol(prefix, :_shuffle_xor)
    _shuffle_down = Symbol(prefix, :_shuffle_down)
    _shuffle_up = Symbol(prefix, :_shuffle_up)
    _shuffle_and_fill_down = Symbol(prefix, :_shuffle_and_fill_down)
    _shuffle_and_fill_up = Symbol(prefix, :_shuffle_and_fill_up)
    @eval begin
        @device_function $_shuffle(data::$jltype, simd_lane_id::Integer) =
            ccall($"extern air.$(prefix)_shuffle.$suffix",
                llvmcall, $jltype, ($jltype, Int16), data, simd_lane_id - 0x1)

        @device_function $_shuffle_xor(data::$jltype, mask::Integer) =
            ccall($"extern air.$(prefix)_shuffle_xor.$suffix",
                llvmcall, $jltype, ($jltype, Int16), data, mask)

        @device_function $_shuffle_down(data::$jltype, delta::Integer) =
            ccall($"extern air.$(prefix)_shuffle_down.$suffix",
                llvmcall, $jltype, ($jltype, Int16), data, delta)

        @device_function $_shuffle_up(data::$jltype, delta::Integer) =
            ccall($"extern air.$(prefix)_shuffle_up.$suffix",
                llvmcall, $jltype, ($jltype, Int16), data, delta)

        @device_function $_shuffle_and_fill_down(data::$jltype, filling_data::$jltype, delta::Integer, modulo::Integer=mod_f()) =
            ccall($"extern air.$(prefix)_shuffle_and_fill_down.$suffix",
                llvmcall, $jltype, ($jltype, $jltype, Int16, Int16), data, filling_data, delta, modulo)

        @device_function $_shuffle_and_fill_up(data::$jltype, filling_data::$jltype, delta::Integer, modulo::Integer=mod_f()) =
            ccall($"extern air.$(prefix)_shuffle_and_fill_up.$suffix",
                llvmcall, $jltype, ($jltype, $jltype, Int16, Int16), data, filling_data, delta, modulo)
    end
end

## SIMD Voting Functions

@device_function simd_ballot(predicate::Bool) =
    ccall("extern air.simd_ballot.i64", llvmcall, UInt64, (Bool,), predicate)

@device_function simd_vote_all(bitmask::UInt64) =
    ccall("extern air.simd_vote_all.i64", llvmcall, Bool, (UInt64,), bitmask)

@device_function simd_vote_any(bitmask::UInt64) =
    ccall("extern air.simd_vote_any.i64", llvmcall, Bool, (UInt64,), bitmask)

@device_function quad_ballot(predicate::Bool) =
    ccall("extern air.quad_ballot.i64", llvmcall, UInt64, (Bool,), predicate)

@device_function quad_vote_all(bitmask::UInt64) =
    ccall("extern air.quad_vote_all.i64", llvmcall, Bool, (UInt64,), bitmask)

@device_function quad_vote_any(bitmask::UInt64) =
    ccall("extern air.quad_vote_any.i64", llvmcall, Bool, (UInt64,), bitmask)


## Documentation

@doc """
    simd_shuffle_xor(data::T, simd_lane_id::Integer)

Return `data` from the thread whose SIMD lane ID is equal to the bitwise `xor` of the
caller's (0-based) SIMD lane ID and `mask`. The value of `mask` needs to be the same
for all threads in a SIMD-group.

T must be one of the following: Float32, Float16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle_xor

@doc """
    simd_shuffle(data::T, simd_lane_id::Integer)

Return `data` from the thread whose SIMD lane ID is `simd_lane_id`. The `simd_lane_id`
needs to be a valid SIMD lane ID but doesn't have to be the same for all threads in the
SIMD-group

T must be one of the following: Float32, Float16, BFloat16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle

@doc """
    simd_shuffle_down(data::T, delta::Integer)

Return `data` from the thread whose SIMD lane ID is the sum of caller's SIMD lane ID and `delta`.

The value for `delta` must be the same for all threads in the SIMD-group. This function
doesn't modify the upper `delta` lanes of `data` because it doesn't wrap values around
the SIMD-group.

T must be one of the following: Float32, Float16, BFloat16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle_down

@doc """
    simd_shuffle_up(data::T, delta::Integer)

Return `data` from the thread whose SIMD lane ID is the difference from the caller's SIMD
lane ID minus `delta`.

The value of `delta` must be the same for all threads in a SIMD-group. This function doesn't
modify the lower `delta` lanes of `data` because it doesn't wrap values around the SIMD-group.

T must be one of the following: Float32, Float16, BFloat16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle_up

@doc """
    simd_shuffle_and_fill_down(data::T, filling_data::T, delta::Integer, [modulo::Integer])

Returns `data` or `filling_data` for each vector from the thread whose SIMD lane ID is the
difference from the caller's SIMD lane ID minus `delta`.

If the difference is negative, the operation copies values from the upper `delta` lanes of
`filling_data` to the lower `delta` lanes of `data`.

The value of `delta` needs to be the same for all threads in a SIMD-group.

The `modulo` parameter defines the vector width that splits the SIMD-group into separate vectors
 and must be 2, 4, 8, 16, or 32.

T must be one of the following: Float32, Float16, BFloat16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle_and_fill_down

@doc """
    simd_shuffle_and_fill_up(data::T, filling_data::T, delta::Integer, [modulo::Integer])

Returns `data` or `filling_data` for each vector from the thread whose SIMD lane ID is the
sum of the caller's SIMD lane ID and `delta`.

If the sum is greater than `modulo`, the function copies values from the lower `delta` lanes of
`filling_data` into the upper `delta` lanes of `data`.

The value of `delta` needs to be the same for all threads in a SIMD-group.

The `modulo` parameter defines the vector width that splits the SIMD-group into separate vectors
 and must be 2, 4, 8, 16, or 32.

T must be one of the following: Float32, Float16, BFloat16, Int32, UInt32, Int16, UInt16, Int8, or UInt8
"""
simd_shuffle_and_fill_up

@doc """
    simd_ballot(predicate::Bool)

Returns a UInt64 bitmask of the evaluation of the Boolean expression for all active
threads in the SIMD-group for which `predicate` is true. The function sets the bits that correspond
to inactive threads to 0.
"""
simd_ballot

@doc """
    simd_vote_all(bitmask::UInt64)

Returns true if all bits corresponding to threads in the SIMD-group are set. The input is a
voting `bitmask`, such as the one returned by `simd_ballot`.
"""
simd_vote_all

@doc """
    simd_vote_any(bitmask::UInt64)

Returns true if any bits corresponding to threads in the SIMD-group are set. The input is a
voting `bitmask`, such as the one returned by `simd_ballot`.
"""
simd_vote_any
