export MtlInlineTensor, matmul2d_descriptor, TensorOpsMatmul2D,
       matmul2d_multiply, matmul2d_multiply_accumulate

using Core: LLVMPtr
using BFloat16s: BFloat16

# Wrappers for Metal 4 tensor-ops / `mpp::tensor_ops` device-side APIs.

# Conservative upper bound on the size of an i32-indexed tensor descriptor.
# TODO: use a dynamic `alloca i8, i64 %sz` where `%sz` comes from `air.get_descriptor_size_tensor`.
const TENSOR_DESCRIPTOR_SIZE = 128

# A tensor descriptor is an opaque, fixed-size, thread-private byte buffer. The `air.*`
# intrinsics initialize/slice it through an out-pointer, so we hand them a `Ref` to one.
const TensorDescriptor = NTuple{TENSOR_DESCRIPTOR_SIZE, UInt8}
const TensorDescriptorStorage = Base.RefValue{TensorDescriptor}


## Tensor descriptor primitives (`air.*` intrinsics).

# These thin `air.*` wrappers must inline. The constructors and `view` below hand them
# descriptor storage through a `Ref`; that `Ref` only stays a stack `alloca` (rather than a
# heap allocation, which GPUCompiler then rejects) as long as it never crosses a call boundary.

# Returns the per-thread tensor descriptor size for the given rank/index-size.
@device_function get_descriptor_size_tensor(rank::Int16, index_size::Int16) =
    ccall("extern air.get_descriptor_size_tensor", llvmcall,
          Int16, (Int16, Int16), rank, index_size)

# Build an `i32`-indexed strided tensor view over a device-memory buffer.
@device_function @inline init_strided_tensor_device!(
    handle::TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.Device},
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    contiguous::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.global", llvmcall,
          Cvoid,
          (Ref{TensorDescriptor}, Int16, LLVMPtr{UInt8, AS.Device},
           Ref{Int32}, Ref{Int32}, Int8),
          handle, rank, data, extents, strides, contiguous)

@device_function @inline init_strided_tensor_threadgroup!(
    handle::TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.ThreadGroup},
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    contiguous::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.local", llvmcall,
          Cvoid,
          (Ref{TensorDescriptor}, Int16, LLVMPtr{UInt8, AS.ThreadGroup},
           Ref{Int32}, Ref{Int32}, Int8),
          handle, rank, data, extents, strides, contiguous)

@device_function @inline get_extent_private_tensor(handle::TensorDescriptor,
                                                   rank::Int16, dim::Int16) =
    ccall("extern air.get_extent_private_tensor.i32", llvmcall,
          Int32, (Ref{TensorDescriptor}, Int16, Int16),
          handle, rank, dim)

@device_function @inline slice_private_tensor!(
    dst::TensorDescriptorStorage,
    src::TensorDescriptor,
    rank::Int16,
    origin::NTuple{<:Any, Int32},
    extents::NTuple{<:Any, Int32},
) = ccall("extern air.slice_private_tensor_private_tensor.s.i32", llvmcall,
          Cvoid,
          (Ref{TensorDescriptor}, Ref{TensorDescriptor}, Int16, Ref{Int32}, Ref{Int32}),
          dst, src, rank, origin, extents)


## High-level inline-tensor wrapper.

"""
    MtlInlineTensor{T, R, AS}

Kernel-stack tensor view over an `MtlDeviceArray` or `MtlThreadGroupArray`, for the Metal 4
`tensor_ops` primitives. `T` is the element type, `R` the rank, `AS` the address space of the
backing data (`AS.Device` or `AS.ThreadGroup`). A thread-private descriptor is initialized at
construction.

Extents and strides follow Julia's column-major convention, matching the backing array: the
first dimension is contiguous. `MtlInlineTensor(A)` views all of `A` (its `size`);
`MtlInlineTensor(A, dims)` and `MtlInlineTensor(A, dims, strides)` set an explicit shape.
Slice a tile with [`view`](@ref), using 1-based origins.
"""
struct MtlInlineTensor{T, R, AS}
    storage::TensorDescriptor
end

# column-major packed strides: stride(1) = 1, stride(k) = prod(extents[1:k-1]).
@inline function packed_strides(extents::NTuple{R, Int32}) where {R}
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
    e = unsafe_trunc.(Int32, extents)
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_device!(storage, Int16(R),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                e, packed_strides(e), Int8(0))
    return MtlInlineTensor{T, R, AS.Device}(storage[])
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer}) where {T, R}
    e = unsafe_trunc.(Int32, extents)
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     e, packed_strides(e), Int8(0))
    return MtlInlineTensor{T, R, AS.ThreadGroup}(storage[])
end

# Explicit-stride variants:
@device_function @inline function MtlInlineTensor{T, R, AS.Device}(
        data::MtlDeviceArray{T, <:Any, AS.Device},
        extents::NTuple{R, <:Integer},
        strides::NTuple{R, <:Integer}) where {T, R}
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_device!(storage, Int16(R),
                                reinterpret(LLVMPtr{UInt8, AS.Device}, pointer(data)),
                                unsafe_trunc.(Int32, extents),
                                unsafe_trunc.(Int32, strides), Int8(0))
    return MtlInlineTensor{T, R, AS.Device}(storage[])
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer},
        strides::NTuple{R, <:Integer}) where {T, R}
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     unsafe_trunc.(Int32, extents),
                                     unsafe_trunc.(Int32, strides), Int8(0))
    return MtlInlineTensor{T, R, AS.ThreadGroup}(storage[])
end

# Convenience: infer rank and address space from the inputs.
@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, A}) where {T, A} =
    MtlInlineTensor{T, ndims(data), A}(data, size(data))

@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, A},
                        extents::NTuple{R, <:Integer}) where {T, R, A} =
    MtlInlineTensor{T, R, A}(data, extents)

@inline MtlInlineTensor(data::MtlDeviceArray{T, <:Any, A},
                        extents::NTuple{R, <:Integer},
                        strides::NTuple{R, <:Integer}) where {T, R, A} =
    MtlInlineTensor{T, R, A}(data, extents, strides)

Base.eltype(::Type{<:MtlInlineTensor{T}}) where {T} = T
Base.eltype(::MtlInlineTensor{T}) where {T} = T

# Slice a tile. Origins are 1-based, like Julia's `view` (the underlying intrinsic is
# 0-based, so subtract one here).
@device_function @inline function Base.view(
        t::MtlInlineTensor{T, R, A},
        origin::NTuple{R, <:Integer},
        extents::NTuple{R, <:Integer}) where {T, R, A}
    storage = Ref{TensorDescriptor}()
    slice_private_tensor!(storage, t.storage, Int16(R),
                          Int32.(origin) .- Int32(1), Int32.(extents))
    return MtlInlineTensor{T, R, A}(storage[])
end


## matmul2d descriptor (mirrors `mpp::tensor_ops::matmul2d_descriptor`).

@enum Matmul2DMode::Int32 begin
    matmul2d_multiply            = 0
    matmul2d_multiply_accumulate = 1
end

"""
    matmul2d_descriptor(M, N, [K]; transpose_left=false, transpose_right=false,
                        relaxed_precision=false, mode=matmul2d_multiply)

Configuration descriptor for a `tensor_ops::matmul2d` op computing the Julia column-major
product `C[M, N] = A[M, K] * B[K, N]`. `K` defaults to `-1` (inferred from the inputs at
runtime). `transpose_left`/`transpose_right` transpose `A`/`B`.

For an outer `K`-loop where each iteration accumulates a partial product into the
destination, set `mode = matmul2d_multiply_accumulate` and zero the destination before the
loop. A typical pattern:

```julia
# C[M, N] = A[M, K] * B[K, N], accumulated over K-tiles of width TileK
op = TensorOpsMatmul2D{matmul2d_descriptor(M, N, TileK;
                                           mode = matmul2d_multiply_accumulate),
                       Int32(NSIMD)}()
for s in 0:(nslices - 1)
    k0 = Int32(s) * Int32(TileK)
    sA = view(tA, (Int32(1), k0 + Int32(1)), (Int32(M), Int32(TileK)))
    sB = view(tB, (k0 + Int32(1), Int32(1)), (Int32(TileK), Int32(N)))
    op(sA, sB, tC)
end
```

Limitation: the loop trip count needs to be kept dynamic (not a compile-time constant) to
avoid crashing Apple's back-end.
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

const TENSOR_DESC_INLINE = Int32(2)   # `__tensor_ops_tensor_descriptor_type::tensor_inline`

# Element-type suffix for `__tensorops_impl_matmul2d_op_run_*` symbols.
# TODO: expose the 4-bit integer formats
tensorops_suffix(::Type{Float16})       = "f16"
tensorops_suffix(::Type{Float32})       = "f32"
tensorops_suffix(::Type{BFloat16})      = "b16"
tensorops_suffix(::Type{Int8})          = "i8"
tensorops_suffix(::Type{UInt8})         = "ui8"
tensorops_suffix(::Type{Int32})         = "i32"

# Address-space prefix for the run helpers
tensorops_AS_prefix(::Val{AS.Device})      = "dv"
tensorops_AS_prefix(::Val{AS.ThreadGroup}) = "tg"

"""
    TensorOpsMatmul2D{DESC, NSIMD}

Configured `tensor_ops::matmul2d` op. `DESC` is the [`matmul2d_descriptor`](@ref) value and
`NSIMD` the simdgroup count (`execution_simdgroups<N>` in MSL).

Construct with [`TensorOpsMatmul2D(desc, Val(N))`](@ref) and invoke it to compute the Julia
column-major product `C = A*B` (or `C += A*B` in `matmul2d_multiply_accumulate` mode):

```julia
op = TensorOpsMatmul2D(matmul2d_descriptor(64, 32), Val(4))
op(A, B, C)            # C[64, 32] = A[64, K] * B[K, 32]
```
"""
struct TensorOpsMatmul2D{DESC, NSIMD} end

TensorOpsMatmul2D(desc::matmul2d_descriptor, ::Val{NSIMD}) where {NSIMD} =
    TensorOpsMatmul2D{desc, Int32(NSIMD)}()

@device_function @inline @generated function (::TensorOpsMatmul2D{DESC, NSIMD})(
        A::MtlInlineTensor{TA, 2, AA},
        B::MtlInlineTensor{TB, 2, AB},
        C::MtlInlineTensor{TC, 2, AC}) where {DESC, NSIMD, TA, TB, TC, AA, AB, AC}
    # matmul2d produces its (row-major) output as the transpose of the Julia column-major
    # one, so `C = A*B` follows from running it with the operands swapped (its left = B, its
    # right = A) and the descriptor's m/n (and transpose flags) swapped to match. DESC is a
    # compile-time parameter, so this rewrite is constant-folded.
    apple = matmul2d_descriptor(DESC.n, DESC.m, DESC.k,
                                DESC.transpose_right, DESC.transpose_left,
                                DESC.relaxed_precision, DESC.matmul_mode)
    sym = "__tensorops_impl_matmul2d_op_run" *
          "_$(tensorops_AS_prefix(Val(AB)))_$(tensorops_suffix(TB))" *
          "_$(tensorops_AS_prefix(Val(AA)))_$(tensorops_suffix(TA))" *
          "_$(tensorops_AS_prefix(Val(AC)))_$(tensorops_suffix(TC))"
    quote
        threads = Int32(NSIMD) * (threads_per_simdgroup() % Int32)
        ccall($"extern $sym", llvmcall, Cvoid,
              (Ref{matmul2d_descriptor},
               Ref{TensorDescriptor}, Int32,
               Ref{TensorDescriptor}, Int32,
               Ref{TensorDescriptor}, Int32,
               Int32),
              $(QuoteNode(apple)),
              B.storage, $TENSOR_DESC_INLINE,
              A.storage, $TENSOR_DESC_INLINE,
              C.storage, $TENSOR_DESC_INLINE,
              threads)
        return nothing
    end
end
