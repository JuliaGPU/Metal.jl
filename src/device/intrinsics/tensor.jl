export MtlInlineTensor, MtlCooperativeTensor, matmul2d_descriptor, TensorOpsMatmul2D,
       matmul2d_multiply, matmul2d_multiply_accumulate

using Core: LLVMPtr
using BFloat16s: BFloat16

# Wrappers for Metal 4 tensor-ops / `mpp::tensor_ops` device-side APIs.

# A tensor descriptor is opaque, thread-private memory, which the `air.*` intrinsics
# initialize and read through a pointer. Its size is only known to the back end (it is what
# `air.get_descriptor_size_tensor` returns, and differs between macOS versions), so
# `finish_ir!` replaces every descriptor's storage with an `alloca` sized like Apple's front
# end does. This placeholder type only gives that storage an identity: Julia code never
# reads or writes it.
primitive type TensorDescriptor 8 end
const TensorDescriptorStorage = Base.RefValue{TensorDescriptor}


## Declarations

# What the pointer parameters of the tensor functions point to, in order, as Apple's front
# end declares them: `:tensor` (the opaque `%struct._tensor_t`), `:matmul2d_descriptor` or
# `:i8`. Our pointers are untyped, so `finish_ir!` passes these on to the AIR downgrader,
# after it has rewritten the calls for the targeted AIR version. The matmul2d entry points
# are linked against Apple's library when the pipeline is created, which reportedly fails
# on macOS 27.3 if the types differ; the `air.*` intrinsics need them for Apple's verifier.
const MATMUL2D_RUN_V2 = r"^(__tensorops_impl_matmul2d_op_run(?:_(?:dv|tg)_[a-z0-9]+){3})_v2$"
# (into a cooperative tensor, which has no address space)
const MATMUL2D_RUN_COOPERATIVE_V2 =
    r"^(__tensorops_impl_matmul2d_op_run_cooperative(?:_(?:dv|tg)_[a-z0-9]+){2}_[a-z0-9]+)_v2$"
const COOPERATIVE_TENSOR = "__tensorops_impl_matmul2d_op_cooperative_tensor_"
const COOPERATIVE_DESTINATION = "__tensorops_impl_matmul2d_op_cooperative_destination_tensor_"
const TENSOR_POINTEES = [
    # (name, number of parameters) => pointees
    (r"^air\.init_strided_private_tensor\.i32\.(global|local)$", 9) =>
        (:tensor, :i8, :i8, :i8, :i8),
    # (AIR 2.8, without the scales operands)
    (r"^air\.init_strided_private_tensor\.i32\.(global|local)$", 6) =>
        (:tensor, :i8, :i8, :i8),
    (r"^air\.slice_private_tensor_private_tensor\.s\.i32$", 5) =>
        (:tensor, :tensor, :i8, :i8),
    (r"^air\.get_extent_private_tensor\.i32$", 4) => (:tensor,),
    (r"^air\.get_extent_private_tensor\.i32$", 3) => (:tensor,),
    (MATMUL2D_RUN_V2, 20) =>
        (:matmul2d_descriptor, :i8, :i8, :i8),
    # (before macOS 27)
    (r"^__tensorops_impl_matmul2d_op_run(_(dv|tg)_[a-z0-9]+){3}$", 8) =>
        (:matmul2d_descriptor, :i8, :i8, :i8),
    (MATMUL2D_RUN_COOPERATIVE_V2, 17) =>
        (:matmul2d_descriptor, :i8, :i8, :i8),
    # (before macOS 27)
    (r"^__tensorops_impl_matmul2d_op_run_cooperative(_(dv|tg)_[a-z0-9]+){2}_[a-z0-9]+$", 7) =>
        (:matmul2d_descriptor, :i8, :i8, :i8),
    # the storage of a cooperative tensor, and the tensor it is loaded from or stored to
    (Regex("^$(COOPERATIVE_TENSOR)init\$"), 13) => (:i8,),
    (Regex("^$(COOPERATIVE_TENSOR)data_size\$"), 12) => (),
    (Regex("^$(COOPERATIVE_TENSOR)num_elements\$"), 12) => (:i8,),
    (Regex("^$(COOPERATIVE_TENSOR)is_valid_element\$"), 14) => (:i8,),
    (Regex("^$(COOPERATIVE_TENSOR)get_element_pointer\$"), 13) => (:i8,),
    (Regex("^$(COOPERATIVE_TENSOR)load_(dv|tg)_[a-z0-9]+\$"), 16) => (:i8, :i8),
    (Regex("^$(COOPERATIVE_TENSOR)store_(dv|tg)_[a-z0-9]+\$"), 15) => (:i8, :i8),
    # (before macOS 26.2, without the operand index, see `finish_ir!`)
    (r"^__tensorops_impl_matmul2d_op_cooperative_destination_data_size$", 11) => (),
    (Regex("^$(COOPERATIVE_DESTINATION)init\$"), 12) => (:i8,),
    (Regex("^$(COOPERATIVE_DESTINATION)num_elements\$"), 11) => (:i8,),
    (Regex("^$(COOPERATIVE_DESTINATION)is_valid_element\$"), 13) => (:i8,),
    (Regex("^$(COOPERATIVE_DESTINATION)get_element_pointer\$"), 12) => (:i8,),
    (Regex("^$(COOPERATIVE_DESTINATION)load_(dv|tg)_[a-z0-9]+\$"), 14) => (:i8, :i8),
    (Regex("^$(COOPERATIVE_DESTINATION)store_(dv|tg)_[a-z0-9]+\$"), 13) => (:i8, :i8),
]

function tensor_pointees(fn::String, nparams::Int)
    known = false
    for ((re, n), pointees) in TENSOR_POINTEES
        occursin(re, fn) || continue
        n == nparams && return pointees
        known = true
    end
    known && error("unexpected declaration of $fn with $nparams parameters")
    return nothing
end


## Tensor descriptor primitives (`air.*` intrinsics).

# These thin `air.*` wrappers must inline. The constructors and `view` below hand them
# descriptor storage through a `Ref`; that `Ref` only stays a stack `alloca` (rather than a
# heap allocation, which GPUCompiler then rejects) as long as it never crosses a call boundary.

# The element-type code stored in a tensor descriptor, as emitted by Apple's Metal frontend
# for `air.init_strided_private_tensor` (an AIR-internal enum, distinct from both
# `MTLTensorDataType` and `__tensor_ops_datatype`). The descriptor's own strides/extents are
# in elements; this code is what address computations that only see the descriptor (notably
# `air.slice_*` origin folding, as of macOS 27) use to scale to bytes, so passing the wrong
# code misaddresses any non-4-byte element type.
tensor_datatype(::Type{Float32})  = Int8(0)
tensor_datatype(::Type{Float16})  = Int8(1)
tensor_datatype(::Type{BFloat16}) = Int8(2)
tensor_datatype(::Type{Int8})     = Int8(3)
tensor_datatype(::Type{UInt8})    = Int8(4)
tensor_datatype(::Type{Int16})    = Int8(5)
tensor_datatype(::Type{UInt16})   = Int8(6)
tensor_datatype(::Type{Int32})    = Int8(7)
tensor_datatype(::Type{UInt32})   = Int8(8)

# Build an `i32`-indexed strided tensor view over a device-memory buffer. These are emitted
# in the form of AIR 2.9, which appends a pointer into the same address space as the data,
# an index and an `i8`, for which Apple's frontend always passes `null, 0, -1` (presumably
# describing blockwise-quantization scales, which these views don't have); `finish_ir!`
# drops them for AIR 2.8.
@device_function @inline init_strided_tensor_device!(
    handle::TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.Device},
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    datatype::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.global", llvmcall,
          Cvoid,
          (Ref{TensorDescriptor}, Int16, LLVMPtr{UInt8, AS.Device},
           Ref{Int32}, Ref{Int32}, Int8, LLVMPtr{UInt8, AS.Device}, Int32, Int8),
          handle, rank, data, extents, strides, datatype,
          reinterpret(LLVMPtr{UInt8, AS.Device}, C_NULL), Int32(0), Int8(-1))

@device_function @inline init_strided_tensor_threadgroup!(
    handle::TensorDescriptorStorage,
    rank::Int16,
    data::LLVMPtr{UInt8, AS.ThreadGroup},
    extents::NTuple{<:Any, Int32},
    strides::NTuple{<:Any, Int32},
    datatype::Int8,
) = ccall("extern air.init_strided_private_tensor.i32.local", llvmcall,
          Cvoid,
          (Ref{TensorDescriptor}, Int16, LLVMPtr{UInt8, AS.ThreadGroup},
           Ref{Int32}, Ref{Int32}, Int8, LLVMPtr{UInt8, AS.ThreadGroup}, Int32, Int8),
          handle, rank, data, extents, strides, datatype,
          reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, C_NULL), Int32(0), Int8(-1))

# (in the form of AIR 2.9 too, which appends an operand Apple's frontend passes as `i16 0`)
@device_function @inline get_extent_private_tensor(handle::TensorDescriptorStorage,
                                                   rank::Int16, dim::Int16) =
    ccall("extern air.get_extent_private_tensor.i32", llvmcall,
          Int32, (Ref{TensorDescriptor}, Int16, Int16, Int16),
          handle, rank, dim, Int16(0))

@device_function @inline slice_private_tensor!(
    dst::TensorDescriptorStorage,
    src::TensorDescriptorStorage,
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

A tensor view of an `MtlDeviceArray` or `MtlThreadGroupArray`, for the Metal 4 tensor
operations (MSL's `tensor_inline`), which need a GPU in the Metal 4 family and macOS 26. `T`
is the element type, `R` the rank and `AS` the address space of the array.

Extents and strides follow Julia's column-major convention, matching the array: the first
dimension is contiguous. `MtlInlineTensor(A)` views all of `A`, and `MtlInlineTensor(A, dims)`
and `MtlInlineTensor(A, dims, strides)` set an explicit shape (with `strides = (1, ld)` for a
matrix whose columns are `ld` elements apart).

`view(t, origin, dims)` slices a tile, with a 1-based `origin`, and `view(t, origin)` slices
everything from `origin` on. `view(t, origin, Val(dims))` slices a tile of a size known at
compile time (MSL's `slice<dims...>`), which lets operations skip their bounds checks; a `:`
in `dims` leaves that dimension dynamic, taking the rest of it from `origin` on, e.g.
`view(t, (i, 1), Val((16, :)))` for 16 rows and all columns. Such a tile has to lie within
`t`: nothing checks that it does. The static size is the type parameter `E`, e.g.
`(16, :)`, or `nothing` for a tensor without one.

Like MSL's `tensor_inline`, an `MtlInlineTensor` lives on the stack of the kernel, and
compilation fails if Julia cannot keep it there. Only use tensors in code that is inlined
into the kernel, don't choose between tensors at run time (e.g. with `ifelse`), and don't
carry a tensor from one loop iteration to the next. Taking views inside a loop of a tensor
created before it is fine.
"""
struct MtlInlineTensor{T, R, AS, E}
    storage::TensorDescriptorStorage
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
                                e, packed_strides(e), tensor_datatype(T))
    return MtlInlineTensor{T, R, AS.Device, nothing}(storage)
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer}) where {T, R}
    e = unsafe_trunc.(Int32, extents)
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     e, packed_strides(e), tensor_datatype(T))
    return MtlInlineTensor{T, R, AS.ThreadGroup, nothing}(storage)
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
                                unsafe_trunc.(Int32, strides), tensor_datatype(T))
    return MtlInlineTensor{T, R, AS.Device, nothing}(storage)
end

@device_function @inline function MtlInlineTensor{T, R, AS.ThreadGroup}(
        data::MtlDeviceArray{T, <:Any, AS.ThreadGroup},
        extents::NTuple{R, <:Integer},
        strides::NTuple{R, <:Integer}) where {T, R}
    storage = Ref{TensorDescriptor}()
    init_strided_tensor_threadgroup!(storage, Int16(R),
                                     reinterpret(LLVMPtr{UInt8, AS.ThreadGroup}, pointer(data)),
                                     unsafe_trunc.(Int32, extents),
                                     unsafe_trunc.(Int32, strides), tensor_datatype(T))
    return MtlInlineTensor{T, R, AS.ThreadGroup, nothing}(storage)
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
    return MtlInlineTensor{T, R, A, nothing}(storage)
end

# what is left of each dimension from a 0-based origin on
@inline remaining_extents(t::MtlInlineTensor{<:Any, R}, origin0::NTuple{R, Int32}) where {R} =
    ntuple(Val(R)) do d
        get_extent_private_tensor(t.storage, Int16(R), Int16(d - 1)) - origin0[d]
    end

# Everything from `origin` on.
@device_function @inline function Base.view(
        t::MtlInlineTensor{T, R, A},
        origin::NTuple{R, <:Integer}) where {T, R, A}
    origin0 = Int32.(origin) .- Int32(1)
    storage = Ref{TensorDescriptor}()
    slice_private_tensor!(storage, t.storage, Int16(R), origin0, remaining_extents(t, origin0))
    return MtlInlineTensor{T, R, A, nothing}(storage)
end

# A tile of static size; `:` keeps a dimension dynamic. (Generated, so that the static
# extents in the type are a literal.)
@device_function @inline @generated function Base.view(
        t::MtlInlineTensor{T, R, A},
        origin::NTuple{R, <:Integer},
        ::Val{E}) where {T, R, A, E}
    E isa NTuple{R, Union{Integer, Colon}} ||
        return :(throw(ArgumentError("static extents are one size or `:` per dimension")))
    any(e -> e isa Integer && e <= 0, E) &&
        return :(throw(ArgumentError("static extents are positive sizes, or `:` for a dynamic one")))
    static = map(e -> e isa Colon ? e : Int(e), E)
    extents = Expr(:tuple)
    for d in 1:R
        push!(extents.args, static[d] isa Colon ?
            :(get_extent_private_tensor(t.storage, $(Int16(R)), $(Int16(d - 1))) - origin0[$d]) :
            Int32(static[d]))
    end
    quote
        origin0 = Int32.(origin) .- Int32(1)
        storage = Ref{TensorDescriptor}()
        slice_private_tensor!(storage, t.storage, $(Int16(R)), origin0, $extents)
        return MtlInlineTensor{$T, $R, $A, $static}(storage)
    end
end

# static extents as matmul2d takes them, with -1 for a dynamic one
matmul2d_extents(E) = E === nothing ? (Int32(-1), Int32(-1)) :
                      map(e -> e isa Colon ? Int32(-1) : Int32(e), E)


## matmul2d descriptor (mirrors `mpp::tensor_ops::matmul2d_descriptor`).

"""
    Matmul2DMode

Whether a [`TensorOpsMatmul2D`](@ref) operation overwrites its destination
(`matmul2d_multiply`, `C = A*B`) or adds to it (`matmul2d_multiply_accumulate`,
`C += A*B`).
"""
@enum Matmul2DMode::Int32 begin
    matmul2d_multiply            = 0
    matmul2d_multiply_accumulate = 1
end
@public Matmul2DMode

"""
    matmul2d_descriptor(M, N, [K]; transpose_left=false, transpose_right=false,
                        relaxed_precision=false, mode=matmul2d_multiply)

Describe a matrix multiplication `C[M, N] = A[M, K] * B[K, N]` for [`TensorOpsMatmul2D`](@ref),
like MSL's `matmul2d_descriptor`. `K` defaults to `-1`, meaning it is taken from the operands
at run time. `transpose_left` and `transpose_right` transpose `A` and `B`; `mode` is a
[`Matmul2DMode`](@ref).

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

Such a loop sends the partial products through the memory of the destination on every
iteration. Where nothing has to happen between the slices, leave `K` dynamic and call the
operation once over all of it, which measured almost twice as fast for large matrices.
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

A matrix multiplication with Metal 4 tensor operations (MSL's `tensor_ops::matmul2d`), on
[`MtlInlineTensor`](@ref)s. `DESC` is a [`matmul2d_descriptor`](@ref), and `NSIMD` the number
of SIMD-groups that execute the operation together (`execution_simdgroups<N>` in MSL).

Construct it with `TensorOpsMatmul2D(desc, Val(NSIMD))`, and call it to compute `C = A*B` (or
`C += A*B` with `mode = matmul2d_multiply_accumulate`):

```julia
op = TensorOpsMatmul2D(matmul2d_descriptor(64, 32), Val(4))
op(A, B, C)            # C[64, 32] = A[64, K] * B[K, 32]
```

All threads of those SIMD-groups have to make the call. With `NSIMD = 1` each SIMD-group
computes a tile of its own, so a threadgroup can hold any number of them.

The operands may be smaller than the descriptor's tile, as at the edge of a matrix: the
operation then only reads and writes what is there. Passing operands of full size as views of
static size (`view(t, origin, Val(dims))`) lets it skip those bounds checks from macOS 27 on.
"""
struct TensorOpsMatmul2D{DESC, NSIMD} end

# matmul2d produces its (row-major) output as the transpose of the Julia column-major one, so
# `C = A*B` follows from running it with the operands swapped (its left = B, its right = A),
# and the descriptor's m/n and transpose flags swapped to match. This is that descriptor;
# DESC is a compile-time parameter, so the rewrite is constant-folded.
apple_descriptor(d::matmul2d_descriptor) =
    matmul2d_descriptor(d.n, d.m, d.k, d.transpose_right, d.transpose_left,
                        d.relaxed_precision, d.matmul_mode)

TensorOpsMatmul2D(desc::matmul2d_descriptor, ::Val{NSIMD}) where {NSIMD} =
    TensorOpsMatmul2D{desc, Int32(NSIMD)}()

@device_function @inline @generated function (::TensorOpsMatmul2D{DESC, NSIMD})(
        A::MtlInlineTensor{TA, 2, AA, EA},
        B::MtlInlineTensor{TB, 2, AB, EB},
        C::MtlInlineTensor{TC, 2, AC, EC}) where {DESC, NSIMD, TA, TB, TC, AA, AB, AC,
                                                  EA, EB, EC}
    apple = apple_descriptor(DESC)
    # the entry point of macOS 27, which takes per operand the data type and block sizes of
    # quantization scales (here none) and the static extents (-1 where dynamic). `finish_ir!`
    # calls the original one instead when targeting older versions, which takes neither.
    sym = "__tensorops_impl_matmul2d_op_run" *
          "_$(tensorops_AS_prefix(Val(AB)))_$(tensorops_suffix(TB))" *
          "_$(tensorops_AS_prefix(Val(AA)))_$(tensorops_suffix(TA))" *
          "_$(tensorops_AS_prefix(Val(AC)))_$(tensorops_suffix(TC))_v2"
    EA, EB, EC = matmul2d_extents(EA), matmul2d_extents(EB), matmul2d_extents(EC)
    quote
        # matmul2d needs its thread count as a constant, so not `threads_per_simdgroup()`
        threads = Int32(NSIMD) * simdgroup_size()
        ccall($"extern $sym", llvmcall, Cvoid,
              (Ref{matmul2d_descriptor},
               Ref{TensorDescriptor}, Int32, Int32, Int32, Int32, Int32, Int32,
               Ref{TensorDescriptor}, Int32, Int32, Int32, Int32, Int32, Int32,
               Ref{TensorDescriptor}, Int32, Int32, Int32,
               Int32),
              $(QuoteNode(apple)),
              B.storage, $TENSOR_DESC_INLINE, Int32(0), Int32(0), Int32(0), $(EB[1]), $(EB[2]),
              A.storage, $TENSOR_DESC_INLINE, Int32(0), Int32(0), Int32(0), $(EA[1]), $(EA[2]),
              C.storage, $TENSOR_DESC_INLINE, $(EC[1]), $(EC[2]),
              threads)
        return nothing
    end
end


## cooperative tensors (MSL's `cooperative_tensor`).

# The storage of a cooperative tensor is thread-local memory of a size only the back end
# knows, like a tensor descriptor: `finish_ir!` allocates it, from the call to
# `COOPERATIVE_STORAGE` that says what it is for.
primitive type CooperativeStorage 8 end
const CooperativeTensorStorage = Base.RefValue{CooperativeStorage}
const COOPERATIVE_STORAGE = "__tensorops_metaljl_cooperative_storage"

# `__tensor_ops_datatype`, which names the element types to the cooperative tensor functions
tensorops_datatype(::Type{Float32})  = Int32(0x10000020)
tensorops_datatype(::Type{Float16})  = Int32(0x10000010)
tensorops_datatype(::Type{BFloat16}) = reinterpret(Int32, 0x90000010)
tensorops_datatype(::Type{Int8})     = Int32(0x20000008)
tensorops_datatype(::Type{UInt8})    = Int32(0x00000008)
tensorops_datatype(::Type{Int32})    = Int32(0x20000020)

"""
    MtlCooperativeTensor{T}(op::TensorOpsMatmul2D, A::MtlInlineTensor, B::MtlInlineTensor)

A destination for `op(A, B, C)` in thread-local memory (MSL's `cooperative_tensor`), with
element type `T`. Its elements are divided over the threads that execute `op`, in a way
that is up to the implementation, so that a product can be worked on where it was computed,
without a round trip through threadgroup or device memory. Apple calls this postfix fusion.

Each thread sees its own share of the elements: `length(t)` slots, of which those with
`isassigned(t, i)` hold an element, read and written with `t[i]`. Two cooperative tensors
made for the same `op`, operands and element type hold the same elements at the same
indices. Apple's implementation does the same for tensors of different element types, but
doesn't document that. `copyto!(t, src)` loads a tensor from memory and `copyto!(dst, t)`
stores one, which is faster than doing so element by element; both have to be called by all
threads that execute `op`, like `op` itself.

```julia
# C = α * A*B + β * C
op  = TensorOpsMatmul2D(matmul2d_descriptor(32, 32), Val(1))
acc = MtlCooperativeTensor{Float32}(op, A, B)
op(A, B, acc)
old = MtlCooperativeTensor{Float32}(op, A, B)
copyto!(old, C)
for i in 1:length(acc)
    isassigned(acc, i) && (acc[i] = α * acc[i] + β * old[i])
end
copyto!(C, acc)
```

Like an [`MtlInlineTensor`](@ref), a cooperative tensor lives on the stack of the kernel.
"""
struct MtlCooperativeTensor{T, DESC, NSIMD, TA, TB}
    storage::CooperativeTensorStorage
end

Base.eltype(::Type{<:MtlCooperativeTensor{T}}) where {T} = T
Base.eltype(::MtlCooperativeTensor{T}) where {T} = T

# The operands the cooperative tensor functions start with: which operand of the operation
# the tensor is (2: the destination), and the descriptor as the operation gets it (see
# `apple_descriptor`).
const COOPERATIVE_PREFIX = (Int32, Int32, Int32, Int32, Int8, Int8, Int8, Int32)
function cooperative_prefix(DESC::matmul2d_descriptor)
    d = apple_descriptor(DESC)
    return (Int32(2), d.m, d.n, d.k, d.transpose_left, d.transpose_right,
            d.relaxed_precision, Int32(d.matmul_mode))
end
# the element types of the operation's operands, in its order
cooperative_datatypes(T, TA, TB) =
    (tensorops_datatype(TB), tensorops_datatype(TA), tensorops_datatype(T))

@device_function @inline @generated function MtlCooperativeTensor{T}(
        ::TensorOpsMatmul2D{DESC, NSIMD},
        ::MtlInlineTensor{TA, 2}, ::MtlInlineTensor{TB, 2}) where {T, DESC, NSIMD, TA, TB}
    prefix = cooperative_prefix(DESC)
    types = cooperative_datatypes(T, TA, TB)
    quote
        storage = Ref{CooperativeStorage}()
        ccall($"extern $COOPERATIVE_STORAGE", llvmcall, Cvoid,
              (Ref{CooperativeStorage}, $(COOPERATIVE_PREFIX...), Int32, Int32, Int32, Int32),
              storage, $(prefix...), $(types...), $(Int32(NSIMD)))
        ccall($"extern $(COOPERATIVE_TENSOR)init", llvmcall, Cvoid,
              ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, Int32, Int32, Int32, Int32),
              $(prefix...), storage, $(types...), $(Int32(NSIMD)) * simdgroup_size())
        return MtlCooperativeTensor{$T, $DESC, $(Int32(NSIMD)), $TA, $TB}(storage)
    end
end

# the number of slots this thread has
@device_function @inline @generated function Base.length(
        t::MtlCooperativeTensor{T, DESC, NSIMD, TA, TB}) where {T, DESC, NSIMD, TA, TB}
    prefix = cooperative_prefix(DESC)
    left, right, _ = cooperative_datatypes(T, TA, TB)
    quote
        n = ccall($"extern $(COOPERATIVE_TENSOR)num_elements", llvmcall, UInt16,
                  ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, Int32, Int32, Int32),
                  $(prefix...), t.storage, $left, $right, $(Int32(NSIMD)) * simdgroup_size())
        return n % Int32
    end
end

# whether slot `i` of this thread holds an element
@device_function @inline @generated function Base.isassigned(
        t::MtlCooperativeTensor{T, DESC, NSIMD, TA, TB}, i::Integer) where {T, DESC, NSIMD, TA, TB}
    prefix = cooperative_prefix(DESC)
    types = cooperative_datatypes(T, TA, TB)
    quote
        ccall($"extern $(COOPERATIVE_TENSOR)is_valid_element", llvmcall, Bool,
              ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, UInt16, Int32, Int32, Int32, Int32),
              $(prefix...), t.storage, (i - 1) % UInt16, $(types...),
              $(Int32(NSIMD)) * simdgroup_size())
    end
end

# A pointer to slot `index` (0-based) of this thread. Slot 0xffff is what the operation
# takes as its destination.
@device_function @inline @generated function cooperative_pointer(
        t::MtlCooperativeTensor{T, DESC, NSIMD, TA, TB}, index::UInt16) where {T, DESC, NSIMD, TA, TB}
    prefix = cooperative_prefix(DESC)
    types = cooperative_datatypes(T, TA, TB)
    quote
        ccall($"extern $(COOPERATIVE_TENSOR)get_element_pointer", llvmcall,
              LLVMPtr{$T, AS.Generic},
              ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, UInt16, Int32, Int32, Int32),
              $(prefix...), t.storage, index, $(types...))
    end
end

@device_function @inline Base.getindex(t::MtlCooperativeTensor{T}, i::Integer) where {T} =
    unsafe_load(cooperative_pointer(t, (i - 1) % UInt16), 1, Val(element_alignment(T)))
@device_function @inline function Base.setindex!(t::MtlCooperativeTensor{T}, x, i::Integer) where {T}
    unsafe_store!(cooperative_pointer(t, (i - 1) % UInt16), convert(T, x), 1,
                  Val(element_alignment(T)))
    return t
end

# load from and store to a tensor in memory, of the same element type
@device_function @inline @generated function Base.copyto!(
        t::MtlCooperativeTensor{T, DESC, NSIMD, TA, TB},
        src::MtlInlineTensor{T, 2, A}) where {T, DESC, NSIMD, TA, TB, A}
    prefix = cooperative_prefix(DESC)
    types = cooperative_datatypes(T, TA, TB)
    sym = "$(COOPERATIVE_TENSOR)load_$(tensorops_AS_prefix(Val(A)))_$(tensorops_suffix(T))"
    quote
        ccall($"extern $sym", llvmcall, Cvoid,
              ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, Ref{TensorDescriptor},
               Int32, Int32, Int32, Int32, Int32, Int32),
              $(prefix...), t.storage, src.storage, $TENSOR_DESC_INLINE, Int32(2), $(types...),
              $(Int32(NSIMD)) * simdgroup_size())
        return t
    end
end

@device_function @inline @generated function Base.copyto!(
        dst::MtlInlineTensor{T, 2, A},
        t::MtlCooperativeTensor{T, DESC, NSIMD, TA, TB}) where {T, DESC, NSIMD, TA, TB, A}
    prefix = cooperative_prefix(DESC)
    types = cooperative_datatypes(T, TA, TB)
    sym = "$(COOPERATIVE_TENSOR)store_$(tensorops_AS_prefix(Val(A)))_$(tensorops_suffix(T))"
    quote
        ccall($"extern $sym", llvmcall, Cvoid,
              ($(COOPERATIVE_PREFIX...), Ref{CooperativeStorage}, Ref{TensorDescriptor},
               Int32, Int32, Int32, Int32, Int32),
              $(prefix...), t.storage, dst.storage, $TENSOR_DESC_INLINE, $(types...),
              $(Int32(NSIMD)) * simdgroup_size())
        return dst
    end
end

# matmul2d into a cooperative tensor made for this operation and these element types
@device_function @inline @generated function (::TensorOpsMatmul2D{DESC, NSIMD})(
        A::MtlInlineTensor{TA, 2, AA, EA},
        B::MtlInlineTensor{TB, 2, AB, EB},
        C::MtlCooperativeTensor{TC, DESC, NSIMD, TA, TB}) where {DESC, NSIMD, TA, TB, TC, AA, AB,
                                                                 EA, EB}
    apple = apple_descriptor(DESC)
    sym = "__tensorops_impl_matmul2d_op_run_cooperative" *
          "_$(tensorops_AS_prefix(Val(AB)))_$(tensorops_suffix(TB))" *
          "_$(tensorops_AS_prefix(Val(AA)))_$(tensorops_suffix(TA))" *
          "_$(tensorops_suffix(TC))_v2"
    EA, EB = matmul2d_extents(EA), matmul2d_extents(EB)
    quote
        ccall($"extern $sym", llvmcall, Cvoid,
              (Ref{matmul2d_descriptor},
               Ref{TensorDescriptor}, Int32, Int32, Int32, Int32, Int32, Int32,
               Ref{TensorDescriptor}, Int32, Int32, Int32, Int32, Int32, Int32,
               LLVMPtr{$TC, AS.Generic},
               Int32),
              $(QuoteNode(apple)),
              B.storage, $TENSOR_DESC_INLINE, Int32(0), Int32(0), Int32(0), $(EB[1]), $(EB[2]),
              A.storage, $TENSOR_DESC_INLINE, Int32(0), Int32(0), Int32(0), $(EA[1]), $(EA[2]),
              cooperative_pointer(C, 0xffff),
              Int32(NSIMD) * simdgroup_size())
        return nothing
    end
end
