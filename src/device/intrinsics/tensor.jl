export MtlInlineTensor, matmul2d_descriptor, tensor_ops_matmul2d!

using Core: LLVMPtr

# Wrappers for Metal 4 tensor-ops / `mpp::tensor_ops` device-side APIs.
#
# The host-bound `tensor_handle` form needs opaque kernel arguments and a
# different ABI (see `ISSUE-tensor-ops.md`). The `tensor_inline` form, which
# is what this file targets, constructs the tensor on the kernel stack from
# a buffer pointer and a set of extents/strides — kernel signature stays the
# same as a plain `MtlDeviceArray` kernel.
#
# Each tensor descriptor lives in a per-thread byte buffer held by a
# `Ref{NTuple{N, UInt8}}`. Julia's `llvm-alloc-opt` pass promotes the Ref to
# a stack alloca once everything is inlined into the kernel.

const _TENSOR_DESCRIPTOR_SIZE = 64

const _TensorDescriptorStorage = Base.RefValue{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}


## Tensor descriptor primitives (`air.*` intrinsics).

# Returns the per-thread tensor descriptor size for the given rank/index-size.
@device_function get_descriptor_size_tensor(rank::Int16, index_size::Int16) =
    ccall("extern air.get_descriptor_size_tensor", llvmcall,
          Int16, (Int16, Int16), rank, index_size)

# Build an `i32`-indexed strided tensor view over a device-memory buffer.
# Ccall arg types use `Ref{T}` so that NTuple values passed in get auto-boxed
# into temporary Refs (via `cconvert(::Type{Ref{T}}, ::NTuple{N,T})` from
# `base/refpointer.jl`). `llvm-alloc-opt` promotes those temporaries to
# stack allocas. The element type must match what we pass: a mismatched
# `Ref{T}` would force ccall to emit a `jl_f_throw_methoderror` path, and
# the dead heap alloc on that path defeats the promotion.
@device_function init_strided_tensor_device!(
    handle::_TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.Device},
    extents::NTuple{2, Int32},
    strides::NTuple{2, Int32},
    contiguous::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.global", llvmcall,
          Cvoid,
          (Ref{UInt8}, Int16, LLVMPtr{UInt8, AS.Device},
           Ref{Int32}, Ref{Int32}, Int8),
          handle, rank, data, extents, strides, contiguous)

@device_function get_extent_private_tensor(handle::_TensorDescriptorStorage,
                                           rank::Int16, dim::Int16) =
    ccall("extern air.get_extent_private_tensor.i32", llvmcall,
          Int32, (Ref{UInt8}, Int16, Int16),
          handle, rank, dim)

@device_function slice_private_tensor!(
    dst::_TensorDescriptorStorage,
    src::_TensorDescriptorStorage,
    rank::Int16,
    origin::NTuple{2, Int32},
    extents::NTuple{2, Int32},
) = ccall("extern air.slice_private_tensor_private_tensor.s.i32", llvmcall,
          Cvoid,
          (Ref{UInt8}, Ref{UInt8}, Int16, Ref{Int32}, Ref{Int32}),
          dst, src, rank, origin, extents)


## High-level inline-tensor wrapper.

"""
    MtlInlineTensor{T, R}

Kernel-stack tensor view over an `MtlDeviceArray`, suitable for use as an
operand of [`tensor_ops_matmul2d!`](@ref). `T` is the element type; `R` is
the rank (only rank 2 is supported today). Backed by a thread-private byte
buffer (an inline `Ref`) that the runtime initializes at construction.

Note: extents follow the MSL `dextents<int32_t, R>{e1, e2, ...}` convention
(innermost dimension first), which is the row-major view the matmul kernel
expects. For a Julia column-major `MtlMatrix(M, N)`, pass extents `(M, N)`
if you want to treat columns as the inner dimension.
"""
struct MtlInlineTensor{T, R}
    storage::_TensorDescriptorStorage
end

# In-kernel constructor: build a packed-stride rank-2 tensor over `data`.
@device_function @inline function MtlInlineTensor{T, 2}(
        data::MtlDeviceArray{T, <:Any, AS.Device},
        e1::Integer, e2::Integer) where {T}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_device!(storage, Int16(2),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                (Int32(e1), Int32(e2)),
                                (Int32(1),  Int32(e1)),
                                Int8(1))
    return MtlInlineTensor{T, 2}(storage)
end

@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, AS.Device},
                       extents::NTuple{2, <:Integer}) where {T} =
    MtlInlineTensor{T, 2}(data, extents[1], extents[2])

# In-kernel constructor with explicit strides.
@device_function @inline function MtlInlineTensor{T, 2}(
        data::MtlDeviceArray{T, <:Any, AS.Device},
        e1::Integer, e2::Integer,
        s1::Integer, s2::Integer) where {T}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_device!(storage, Int16(2),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                (Int32(e1), Int32(e2)),
                                (Int32(s1), Int32(s2)),
                                Int8(0))
    return MtlInlineTensor{T, 2}(storage)
end

@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, AS.Device},
                       extents::NTuple{2, <:Integer},
                       strides::NTuple{2, <:Integer}) where {T} =
    MtlInlineTensor{T, 2}(data, extents[1], extents[2], strides[1], strides[2])

Base.eltype(::Type{<:MtlInlineTensor{T}}) where {T} = T
Base.eltype(::MtlInlineTensor{T}) where {T} = T

# Slice. Origins are zero-based to match MSL semantics.
@device_function @inline function _slice_inline_tensor(
        t::MtlInlineTensor{T, 2},
        o1::Integer, o2::Integer,
        e1::Integer, e2::Integer) where {T}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    slice_private_tensor!(storage, t.storage, Int16(2),
                          (Int32(o1), Int32(o2)),
                          (Int32(e1), Int32(e2)))
    return MtlInlineTensor{T, 2}(storage)
end

@inline Base.view(t::MtlInlineTensor{T, 2}, origin::NTuple{2, <:Integer},
                  extents::NTuple{2, <:Integer}) where {T} =
    _slice_inline_tensor(t, origin[1], origin[2], extents[1], extents[2])


## matmul2d descriptor (mirrors `mpp::tensor_ops::matmul2d_descriptor`).

@enum Matmul2DMode::Int32 begin
    matmul2d_multiply            = 0
    matmul2d_multiply_accumulate = 1
end

"""
    matmul2d_descriptor(m, n, [k]; transpose_left=false, transpose_right=false,
                        relaxed_precision=false, mode=matmul2d_multiply)

Configuration descriptor for a `tensor_ops::matmul2d` operation. `k`
defaults to `-1` (dynamic — inferred from the input tensors at runtime).
Layout matches the 20-byte `mpp::tensor_ops::matmul2d_descriptor` POD.
"""
struct matmul2d_descriptor
    m::Int32
    n::Int32
    k::Int32
    transpose_left::Int8
    transpose_right::Int8
    relaxed_precision::Int8
    matmul_mode::Matmul2DMode
end

matmul2d_descriptor(m::Integer, n::Integer, k::Integer = -1;
                    transpose_left::Bool = false,
                    transpose_right::Bool = false,
                    relaxed_precision::Bool = false,
                    mode::Matmul2DMode = matmul2d_multiply) =
    matmul2d_descriptor(Int32(m), Int32(n), Int32(k),
                        Int8(transpose_left), Int8(transpose_right),
                        Int8(relaxed_precision), mode)


## matmul2d run (inline-tensor → inline-tensor variant).

const _TENSOR_DESC_INLINE = Int32(2)   # `__tensor_ops_tensor_descriptor_type::tensor_inline`

# Element-type suffix for `__tensorops_impl_matmul2d_op_run_*` symbols.
# The 4-bit integer formats (`i4`, `ui4`) aren't exposed yet — Julia has no
# native 4-bit integer type. `int32` is only valid as the destination of
# an `i8`/`ui8` × `i4`/`ui4` matmul.
_tensorops_suffix(::Type{Float16})      = "f16"
_tensorops_suffix(::Type{Float32})      = "f32"
_tensorops_suffix(::Type{Core.BFloat16}) = "b16"
_tensorops_suffix(::Type{Int8})         = "i8"
_tensorops_suffix(::Type{UInt8})        = "ui8"
_tensorops_suffix(::Type{Int32})        = "i32"

"""
    tensor_ops_matmul2d!(desc, left, right, dest, threads)

`dest = left * right (+ dest if mode=multiply_accumulate)` executed
cooperatively by `threads` participating threads (i.e.
`simdgroup_size * num_simdgroups`). Each operand is an
[`MtlInlineTensor`](@ref).

Supported element-type combinations follow `MPPTensorOpsMatMul2d.h`; only
`(f16, f16, f16)`, `(f16, f16, f32)`, `(f32, f32, f32)` are wired up here.
"""
@generated function tensor_ops_matmul2d!(
        desc::matmul2d_descriptor,
        left::MtlInlineTensor{TL, 2},
        right::MtlInlineTensor{TR, 2},
        dest::MtlInlineTensor{TD, 2},
        threads::Int32) where {TL, TR, TD}
    sym = "__tensorops_impl_matmul2d_op_run_dv_$(_tensorops_suffix(TL))" *
          "_dv_$(_tensorops_suffix(TR))" *
          "_dv_$(_tensorops_suffix(TD))"
    quote
        ccall($"extern $sym", llvmcall, Cvoid,
              (Ref{matmul2d_descriptor},
               Ref{UInt8}, Int32,
               Ref{UInt8}, Int32,
               Ref{UInt8}, Int32,
               Int32),
              desc,
              left.storage,  $_TENSOR_DESC_INLINE,
              right.storage, $_TENSOR_DESC_INLINE,
              dest.storage,  $_TENSOR_DESC_INLINE,
              threads)
        return nothing
    end
end
