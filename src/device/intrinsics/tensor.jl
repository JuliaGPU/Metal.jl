export MtlInlineTensor, matmul2d_descriptor, TensorOpsMatmul2D,
       matmul2d_multiply, matmul2d_multiply_accumulate, tensor_matmul!

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

# Conservative upper bound on the size of an i32-indexed tensor descriptor.
# Apple's compiler emits a dynamic `alloca i8, i64 %sz` where `%sz` comes
# from `air.get_descriptor_size_tensor` (marked deferred-static-alloca-size
# so it's resolved at metallib build time). We use one static size that
# covers the ranks we care about (≤ 8 for i32-indexed tensors); higher
# ranks would need a bigger buffer.
const _TENSOR_DESCRIPTOR_SIZE = 128

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
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    contiguous::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.global", llvmcall,
          Cvoid,
          (Ref{UInt8}, Int16, LLVMPtr{UInt8, AS.Device},
           Ref{Int32}, Ref{Int32}, Int8),
          handle, rank, data, extents, strides, contiguous)

@device_function init_strided_tensor_threadgroup!(
    handle::_TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.ThreadGroup},
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    contiguous::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.local", llvmcall,
          Cvoid,
          (Ref{UInt8}, Int16, LLVMPtr{UInt8, AS.ThreadGroup},
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
    origin::NTuple{<:Any, Int32},
    extents::NTuple{<:Any, Int32},
) = ccall("extern air.slice_private_tensor_private_tensor.s.i32", llvmcall,
          Cvoid,
          (Ref{UInt8}, Ref{UInt8}, Int16, Ref{Int32}, Ref{Int32}),
          dst, src, rank, origin, extents)


## High-level inline-tensor wrapper.

"""
    MtlInlineTensor{T, R, ASpace}

Kernel-stack tensor view over an `MtlDeviceArray` or `MtlThreadGroupArray`.
`T` is the element type, `R` the rank, `ASpace` the address space of the
underlying data (`AS.Device` or `AS.ThreadGroup`). Backed by a thread-
private byte buffer (an inline `Ref`) that the runtime initializes at
construction.

Extents follow the MSL `dextents<int32_t, R>{e1, e2, ...}` convention
(innermost dimension first), which is the row-major view the matmul kernel
expects. For a Julia column-major `MtlMatrix(M, N)`, pass extents `(M, N)`
if you want to treat columns as the inner dimension.

`tensor_ops::matmul2d` itself is rank-2 — higher-rank tensors are useful
for slicing, multi-batch lifts, and the future `convolution2d` op.
"""
struct MtlInlineTensor{T, R, ASpace}
    storage::_TensorDescriptorStorage
end

# `tensor_inline` packed-stride strides: stride(0) = 1, stride(k) = prod(extents[1:k]).
@inline function _packed_strides(extents::NTuple{R, Int32}) where {R}
    ntuple(Val(R)) do k
        s = Int32(1)
        for j in 1:(k - 1)
            s *= extents[j]
        end
        s
    end
end

# In-kernel constructors (packed strides):
@device_function @inline function MtlInlineTensor{T, R, AS.Device}(
        data::MtlDeviceArray{T, <:Any, AS.Device},
        extents::NTuple{R, <:Integer}) where {T, R}
    e = Int32.(extents)
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_device!(storage, Int16(R),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                e, _packed_strides(e), Int8(1))
    return MtlInlineTensor{T, R, AS.Device}(storage)
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer}) where {T, R}
    e = Int32.(extents)
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     e, _packed_strides(e), Int8(1))
    return MtlInlineTensor{T, R, AS.ThreadGroup}(storage)
end

# Explicit-stride variants:
@device_function @inline function MtlInlineTensor{T, R, AS.Device}(
        data::MtlDeviceArray{T, <:Any, AS.Device},
        extents::NTuple{R, <:Integer},
        strides::NTuple{R, <:Integer}) where {T, R}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_device!(storage, Int16(R),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                Int32.(extents), Int32.(strides), Int8(0))
    return MtlInlineTensor{T, R, AS.Device}(storage)
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer},
        strides::NTuple{R, <:Integer}) where {T, R}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     Int32.(extents), Int32.(strides), Int8(0))
    return MtlInlineTensor{T, R, AS.ThreadGroup}(storage)
end

# Convenience: infer rank and address space from the inputs.
@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, A},
                        extents::NTuple{R, <:Integer}) where {T, R, A} =
    MtlInlineTensor{T, R, A}(data, extents)

@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, A},
                        extents::NTuple{R, <:Integer},
                        strides::NTuple{R, <:Integer}) where {T, R, A} =
    MtlInlineTensor{T, R, A}(data, extents, strides)

Base.eltype(::Type{<:MtlInlineTensor{T}}) where {T} = T
Base.eltype(::MtlInlineTensor{T}) where {T} = T

# Slice. Origins are zero-based to match MSL semantics.
@device_function @inline function Base.view(
        t::MtlInlineTensor{T, R, A},
        origin::NTuple{R, <:Integer},
        extents::NTuple{R, <:Integer}) where {T, R, A}
    storage = Ref{NTuple{_TENSOR_DESCRIPTOR_SIZE, UInt8}}()
    slice_private_tensor!(storage, t.storage, Int16(R),
                          Int32.(origin), Int32.(extents))
    return MtlInlineTensor{T, R, A}(storage)
end


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

For an outer `K`-loop where each iteration accumulates a partial product
into the destination, set `mode = matmul2d_multiply_accumulate` and zero
the destination before the loop. A typical pattern:

```julia
op = TensorOpsMatmul2D{matmul2d_descriptor(M, N, TileK;
                                           mode = matmul2d_multiply_accumulate),
                       Int32(NSIMD)}()
for s in 0:(nslices - 1)
    sA = view(tA, (Int32(s) * Int32(TileK), Int32(0)), (Int32(TileK), Int32(M)))
    sB = view(tB, (Int32(0), Int32(s) * Int32(TileK)), (Int32(N), Int32(TileK)))
    op(sA, sB, tC)
end
```

Keep the loop's trip count dynamic — a compile-time-known trip count
that fully unrolls into multiple op call sites currently crashes Apple's
back-end (see `ISSUE-tensor-ops.md`).
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
_tensorops_suffix(::Type{Float16})       = "f16"
_tensorops_suffix(::Type{Float32})       = "f32"
_tensorops_suffix(::Type{Core.BFloat16}) = "b16"
_tensorops_suffix(::Type{Int8})          = "i8"
_tensorops_suffix(::Type{UInt8})         = "ui8"
_tensorops_suffix(::Type{Int32})         = "i32"

# Address-space prefix for the run helpers (`dv` for device, `tg` for threadgroup).
_tensorops_aspace_prefix(::Val{AS.Device})      = "dv"
_tensorops_aspace_prefix(::Val{AS.ThreadGroup}) = "tg"

"""
    TensorOpsMatmul2D{DESC, NSIMD}

Configured `tensor_ops::matmul2d` op. Mirrors Apple's MSL
`matmul2d<desc, execution_simdgroups<N>>` template: `DESC` is the
[`matmul2d_descriptor`](@ref) value, `NSIMD` is the simdgroup count
(`execution_simdgroups<N>`). Both are encoded as type parameters so the
generated AIR carries them as compile-time constants — `NSIMD`
specifically: the AGX register allocator runs out of stack registers
when the simdgroup count is a runtime value and two matmul calls live
in the same kernel.

Construct with [`TensorOpsMatmul2D(desc, Val(N))`](@ref) and invoke
like a function:

```julia
op = TensorOpsMatmul2D(matmul2d_descriptor(64, 32, -1), Val(4))
op(left, right, dest)            # run; mirrors `op.run(...)` in MSL
```
"""
struct TensorOpsMatmul2D{DESC, NSIMD} end

TensorOpsMatmul2D(desc::matmul2d_descriptor, ::Val{NSIMD}) where {NSIMD} =
    TensorOpsMatmul2D{desc, Int32(NSIMD)}()

@device_function @inline @generated function (::TensorOpsMatmul2D{DESC, NSIMD})(
        left::MtlInlineTensor{TL, 2, AL},
        right::MtlInlineTensor{TR, 2, AR},
        dest::MtlInlineTensor{TD, 2, AD}) where {DESC, NSIMD, TL, TR, TD, AL, AR, AD}
    sym = "__tensorops_impl_matmul2d_op_run" *
          "_$(_tensorops_aspace_prefix(Val(AL)))_$(_tensorops_suffix(TL))" *
          "_$(_tensorops_aspace_prefix(Val(AR)))_$(_tensorops_suffix(TR))" *
          "_$(_tensorops_aspace_prefix(Val(AD)))_$(_tensorops_suffix(TD))"
    quote
        threads = Int32(NSIMD) * Int32(threads_per_simdgroup())
        ccall($"extern $sym", llvmcall, Cvoid,
              (Ref{matmul2d_descriptor},
               Ref{UInt8}, Int32,
               Ref{UInt8}, Int32,
               Ref{UInt8}, Int32,
               Int32),
              $(QuoteNode(DESC)),
              left.storage,  $_TENSOR_DESC_INLINE,
              right.storage, $_TENSOR_DESC_INLINE,
              dest.storage,  $_TENSOR_DESC_INLINE,
              threads)
        return nothing
    end
end

