# Atomic Functions
#
# Atomic operations are emitted as LLVM atomics (through UnsafeAtomics), with an ordering and
# a synchronization scope, which GPUCompiler lowers to AIR's atomic intrinsics for the
# targeted Metal version: from MSL 4.1 with the ordering on the operation, before that as a
# relaxed operation bracketed by fences. Like MSL, they synchronize with the device for device
# memory and with the threadgroup for threadgroup memory. An ordered operation orders both
# device and threadgroup memory; passing memory flags explicitly (MSL 4.1) restricts that, by
# calling the AIR intrinsics directly, as LLVM cannot express it.

const AtomicType = Union{Int32,UInt32,Float32}
const AtomicIntType = Union{Int32,UInt32}

# LLVM synchronization scopes for Metal's address spaces
@inline atomic_scope(::Val{AS.Device}) = UnsafeAtomics.Internal.LLVMSyncScope{:device}()
@inline atomic_scope(::Val{AS.ThreadGroup}) = UnsafeAtomics.Internal.LLVMSyncScope{:workgroup}()

# MSL only makes device memory coherent within a threadgroup by default, so a relaxed load
# of it is only guaranteed to (eventually) see stores from the same threadgroup. Say so with
# the workgroup scope: LLVM's device-scope relaxed loads have to see every thread's stores,
# which GPUCompiler implements with acquire loads.
@inline load_scope(as::Val, order) =
    order === UnsafeAtomics.monotonic ? atomic_scope(Val(AS.ThreadGroup)) : atomic_scope(as)

# Call `f` with the LLVM ordering for an MSL memory order. For an order passed as a value,
# branch on it rather than computing the ordering from it: that folds when the order is a
# constant, and keeps inference precise (and the code correct) when it isn't. Loads cannot
# release and stores cannot acquire (LLVM rejects such atomics, MSL doesn't check), so like
# Clang, they only get the part of an order they can have.
@inline function with_llvm_order(f, order::Val{o}, kind::Symbol=:rmw) where {o}
    @static_assert(o isa memory_order, "Invalid atomic memory ordering.")
    with_llvm_order(f, o, kind)
end
@inline function with_llvm_order(f, order::memory_order, kind::Symbol=:rmw)
    order === memory_order_relaxed ? f(UnsafeAtomics.monotonic) :
    order === memory_order_seq_cst ? f(UnsafeAtomics.seq_cst) :
    kind === :load  ? (order === memory_order_release ? f(UnsafeAtomics.monotonic) :
                                                        f(UnsafeAtomics.acquire)) :
    kind === :store ? (order === memory_order_acquire ? f(UnsafeAtomics.monotonic) :
                                                        f(UnsafeAtomics.release)) :
    order === memory_order_acquire ? f(UnsafeAtomics.acquire) :
    order === memory_order_release ? f(UnsafeAtomics.release) :
                                     f(UnsafeAtomics.acq_rel)
end

# the failure ordering of a compare-exchange, which cannot release
@inline cmpxchg_failure_order(order) =
    order === memory_order_release ? memory_order_relaxed :
    order === memory_order_acq_rel ? memory_order_acquire : order
@inline cmpxchg_failure_order(::Val{order}) where {order} = Val(cmpxchg_failure_order(order))


## low-level functions

@inline atomic_load_explicit(ptr::LLVMPtr{T,AS},
                             order::Union{memory_order,Val}=memory_order_relaxed) where {T<:AtomicType,AS} =
    with_llvm_order(order, :load) do order
        UnsafeAtomics.load(ptr, order, load_scope(Val(AS), order))
    end

@inline atomic_store_explicit(ptr::LLVMPtr{T,AS}, desired::T,
                              order::Union{memory_order,Val}=memory_order_relaxed) where {T<:AtomicType,AS} =
    with_llvm_order(order, :store) do order
        UnsafeAtomics.store!(ptr, desired, order, atomic_scope(Val(AS)))
    end

# NOTE: we deviate slightly from the Metal/C++ API here, not returning the status boolean,
#       but the value that was loaded, which equals `expected` if and only if the exchange
#       succeeded.
@inline atomic_compare_exchange_weak_explicit(
        ptr::LLVMPtr{T,AS}, expected::T, desired::T,
        success_order::Union{memory_order,Val}=memory_order_relaxed,
        failure_order::Union{memory_order,Val}=memory_order_relaxed) where {T<:AtomicType,AS} =
    with_llvm_order(success_order) do success_order
        with_llvm_order(failure_order, :load) do failure_order
            UnsafeAtomics.cas!(ptr, expected, desired, success_order, failure_order,
                               atomic_scope(Val(AS))).old
        end
    end

for (op, impl, types) in ((:exchange,  :xchg!, AtomicType),
                          (:fetch_add, :add!,  AtomicType),
                          (:fetch_sub, :sub!,  AtomicType),
                          (:fetch_min, :min!,  AtomicIntType),
                          (:fetch_max, :max!,  AtomicIntType),
                          (:fetch_and, :and!,  AtomicIntType),
                          (:fetch_or,  :or!,   AtomicIntType),
                          (:fetch_xor, :xor!,  AtomicIntType))
    f = Symbol("atomic_$(op)_explicit")
    @eval @inline $f(ptr::LLVMPtr{T,AS}, desired::T,
                     order::Union{memory_order,Val}=memory_order_relaxed) where {T<:$types,AS} =
        with_llvm_order(order) do order
            UnsafeAtomics.$impl(ptr, desired, order, atomic_scope(Val(AS)))
        end
end

# atomic_ulong only supports non-fetching min/max, on device memory of Apple8+ GPUs
for (op, impl) in ((:min, :min!), (:max, :max!))
    f = Symbol("atomic_$(op)_explicit")
    @eval @inline function $f(ptr::LLVMPtr{UInt64,AS.Device}, desired::UInt64,
                              order::Union{memory_order,Val}=memory_order_relaxed)
        @static_assert(apple_family() >= 8, "64-bit atomic min/max requires Apple8 or newer.")
        with_llvm_order(order) do order
            UnsafeAtomics.$impl(ptr, desired, order, atomic_scope(Val(AS.Device)))
        end
        return
    end
end


## low-level functions with explicit memory flags (MSL 4.1)

# These call the AIR intrinsics directly: memory flags restrict which memory an ordered
# operation orders, which LLVM atomics cannot express (an LLVM ordering orders all memory;
# the synchronization scope only selects the threads). LLVM 19 added Memory Model Relaxation
# Annotations for this, which AMDGPU uses to restrict fences to address spaces
# (`!mmra !{!"amdgpu-synchronize-as", !"local"}`). Once we require Julia 1.13 (LLVM 20),
# these can emit LLVM atomics too, tagged with e.g. `!{!"metal-synchronize-as",
# !"threadgroup"}` (through `llvmcall`, as UnsafeAtomics can't attach metadata), which
# GPUCompiler's atomic lowering would then turn into the flags operand. Dropping a tag is
# safe, only ordering more memory than asked for.

# MSL only allows ordered atomics and memory flags on the intrinsics from 4.1
@inline atomic_order_and_flags_available(order, flags) =
    (order === memory_order_relaxed && flags == MemoryFlagNone) ||
    metal_version() >= sv"4.1"

@inline function validate_atomic_arguments(::Val{order}, ::Val{flags}) where {order, flags}
    @static_assert(order isa memory_order, "Invalid atomic memory ordering.")
    @static_assert(atomic_order_and_flags_available(order, flags),
                   "Ordered atomics and memory flags require Metal 4.1 or newer.")
end

# (name, AIR operation, types, arguments after the pointer, orders)
const atomic_intrinsics = (
    (:load,                  "load",        (:Int32, :UInt32, :Float32), (),                  1),
    (:compare_exchange_weak, "cmpxchg.weak", (:Int32, :UInt32, :Float32), (:expected, :desired), 2),
    (:store,                 "store",       (:Int32, :UInt32, :Float32), (:desired,),         1),
    (:exchange,              "xchg",        (:Int32, :UInt32, :Float32), (:desired,),         1),
    (:fetch_add,             "add",         (:Int32, :UInt32, :Float32), (:desired,),         1),
    (:fetch_sub,             "sub",         (:Int32, :UInt32, :Float32), (:desired,),         1),
    (:fetch_min,             "min",         (:Int32, :UInt32),           (:desired,),         1),
    (:fetch_max,             "max",         (:Int32, :UInt32),           (:desired,),         1),
    (:fetch_and,             "and",         (:Int32, :UInt32),           (:desired,),         1),
    (:fetch_or,              "or",          (:Int32, :UInt32),           (:desired,),         1),
    (:fetch_xor,             "xor",         (:Int32, :UInt32),           (:desired,),         1),
    (:min,                   "min",         (:UInt64,),                  (:desired,),         1),
    (:max,                   "max",         (:UInt64,),                  (:desired,),         1),
)

for (op, air_op, types, args, norders) in atomic_intrinsics, typ in types,
    (as, memnam, scope) in ((AS.Device, "global", thread_scope_device),
                            (AS.ThreadGroup, "local", thread_scope_threadgroup))
    typ === :UInt64 && as !== AS.Device && continue
    typnam = typ === :Float32 ? "f32" : typ === :UInt64 ? "i64" : "i32"
    if op ∉ (:load, :compare_exchange_weak, :store, :exchange) && typ !== :Float32
        typnam = "$(typ === :Int32 ? "s" : "u").$typnam"
    end
    f = Symbol("atomic_$(op)_explicit")
    return_type = op in (:store, :min, :max) ? :Nothing : typ
    orders = norders == 1 ? (:order,) : (:success_order, :failure_order)
    requirements = if typ === :Float32 && as === AS.ThreadGroup
        :(@static_assert(metal_version() >= sv"4.1",
                         "Float32 threadgroup atomic operations require Metal 4.1 or newer."))
    elseif typ === :UInt64
        :(@static_assert(apple_family() >= 8, "64-bit atomic min/max requires Apple8 or newer."))
    end
    # compare-exchange passes the expected value by reference
    ccall_types = [:(LLVMPtr{$typ,$as}); [a === :expected ? :(Ptr{$typ}) : typ for a in args];
                   fill(:Int32, norders + 2); :Bool]
    ccall_args = [:ptr; [a === :expected ? :expected_box : a for a in args];
                  [:(Val($o)) for o in orders]; :(Val($scope)); :(Val(flags)); :(Val(false))]

    @eval begin
        @inline $f(ptr::LLVMPtr{$typ,$as}, $((:($a::$typ) for a in args)...),
                   $((:($o::memory_order) for o in orders)...),
                   flags::Union{MemoryFlags,UInt32}) =
            $f(ptr, $(args...), $((:(Val($o)) for o in orders)...), Val(flags))

        function $f(ptr::LLVMPtr{$typ,$as}, $((:($a::$typ) for a in args)...),
                    $((:(::Val{$o}) for o in orders)...), ::Val{flags}) where {$(orders...), flags}
            $requirements
            validate_atomic_arguments(Val($(orders[1])), Val(flags))
            $(norders == 2 ? :(@static_assert(failure_order isa memory_order,
                                              "Invalid atomic memory ordering.")) : nothing)
            $(:expected in args ? :(expected_box = Ref(expected)) : nothing)
            @typed_ccall($"air.atomic.$memnam.$air_op.$typnam", llvmcall, $return_type,
                         ($(ccall_types...),), $(ccall_args...))
        end
    end
end


# generic atomic support using compare-and-swap

@inline function atomic_fetch_op_explicit(ptr::LLVMPtr{T}, op::Function, val,
                                          order::Union{memory_order,Val}=memory_order_relaxed,
                                          flags...) where {T}
    failure_order = cmpxchg_failure_order(order)
    old = atomic_load_explicit(ptr, failure_order, flags...)
    while true
        cmp = old
        new = convert(T, op(old, val))
        old = atomic_compare_exchange_weak_explicit(ptr, cmp, new, order, failure_order,
                                                    flags...)
        old === cmp && return old
    end
end

# documentation

const atomic_semantics = """
The `order` is a `memory_order` (or a `Val` of one), `memory_order_relaxed` by
default. As in MSL, the operation synchronizes with the other threads on the device for
device memory, and with those in the threadgroup for threadgroup memory. An ordered
operation orders accesses to both device and threadgroup memory. Ordered operations need
Metal 3.2; before Metal 4.1, they are implemented with fences. A load only uses the
acquire part of an order, and a store only its release part.

The variants that take `flags` ([`MemoryFlags`](@ref)) as an additional argument restrict
the memory an ordered operation orders. Except for relaxed operations without flags, they
need Metal 4.1.
"""

@doc """
    atomic_load_explicit(ptr::LLVMPtr{T}, [order]) -> T

Atomically load the value at `ptr`, which can be an `Int32`, `UInt32` or `Float32` in device
or threadgroup memory.

$atomic_semantics

As in MSL, a relaxed load of device memory is only guaranteed to eventually observe stores
from threads in the same threadgroup: repeating it, e.g., in a loop waiting for a flag, may
never observe a store from another threadgroup. To wait for another threadgroup, use an
acquire load (`memory_order_acquire`), or a relaxed load at device scope through
UnsafeAtomics (`UnsafeAtomics.load(ptr, UnsafeAtomics.monotonic)`).
""" atomic_load_explicit

@doc """
    atomic_store_explicit(ptr::LLVMPtr{T}, val::T, [order])

Atomically store `val` at `ptr`, which can be an `Int32`, `UInt32` or `Float32` in device
or threadgroup memory.

$atomic_semantics
""" atomic_store_explicit

@doc """
    atomic_exchange_explicit(ptr::LLVMPtr{T}, val::T, [order]) -> T

Atomically replace the value at `ptr` by `val`, and return the old value. `T` can be
`Int32`, `UInt32` or `Float32`, in device or threadgroup memory.

$atomic_semantics
""" atomic_exchange_explicit

@doc """
    atomic_compare_exchange_weak_explicit(ptr::LLVMPtr{T}, expected::T, desired::T,
                                          [success_order, failure_order]) -> T

Atomically replace the value at `ptr` by `desired` if it equals `expected`, and return the
value that was loaded. Unlike in MSL, this function doesn't return whether the exchange
succeeded: it did if the returned value equals `expected`. As a weak compare-exchange, it can
fail spuriously. `T` can be `Int32`, `UInt32` or `Float32`, in device or threadgroup memory.

The `success_order` applies when the exchange succeeds, the `failure_order` (which cannot
release) when it fails.

$atomic_semantics
""" atomic_compare_exchange_weak_explicit

for (op, desc, types) in (
        (:add, "add `val` to the value at `ptr`", "`Int32`, `UInt32` or `Float32`"),
        (:sub, "subtract `val` from the value at `ptr`", "`Int32`, `UInt32` or `Float32`"),
        (:min, "replace the value at `ptr` by its minimum with `val`", "`Int32` or `UInt32`"),
        (:max, "replace the value at `ptr` by its maximum with `val`", "`Int32` or `UInt32`"),
        (:and, "replace the value at `ptr` by its bitwise and with `val`", "`Int32` or `UInt32`"),
        (:or,  "replace the value at `ptr` by its bitwise or with `val`", "`Int32` or `UInt32`"),
        (:xor, "replace the value at `ptr` by its bitwise xor with `val`", "`Int32` or `UInt32`"))
    f = Symbol("atomic_fetch_$(op)_explicit")
    doc = """
        $f(ptr::LLVMPtr{T}, val::T, [order]) -> T

    Atomically $desc, and return the old value. `T` can be $types, in device or
    threadgroup memory.

    $atomic_semantics
    """
    @eval @doc $doc $f
end

for op in (:min, :max)
    f = Symbol("atomic_$(op)_explicit")
    doc = """
        $f(ptr::LLVMPtr{UInt64,AS.Device}, val::UInt64, [order])

    Atomically replace the `UInt64` in device memory at `ptr` by its $(op)imum with `val`.
    Unlike the 32-bit operations, this doesn't return the old value, as Metal only supports
    the non-fetching form. It needs an Apple8 GPU or newer.
    """
    @eval @doc $doc $f
end

@doc """
    atomic_fetch_op_explicit(ptr::LLVMPtr{T}, op, val, [order]) -> T

Atomically replace the value at `ptr` by `op(old, val)`, and return the old value `old`.
Implemented with a compare-exchange loop, this supports any operation, but only the types
and address spaces [`Metal.atomic_compare_exchange_weak_explicit`](@ref) does.

$atomic_semantics
""" atomic_fetch_op_explicit


## high-level interface

# copied from CUDA.jl -- should be generalized or integrated with Base

const inplace_ops = Dict(
    :(+=)   => :(+),
    :(-=)   => :(-),
    :(*=)   => :(*),
    :(/=)   => :(/),
    :(\=)   => :(\),
    :(%=)   => :(%),
    :(^=)   => :(^),
    :(&=)   => :(&),
    :(|=)   => :(|),
    :(⊻=)   => :(⊻),
    :(>>>=) => :(>>>),
    :(>>=)  => :(>>),
    :(<<=)  => :(<<),
)

struct AtomicError <: Exception
    msg::AbstractString
end

Base.showerror(io::IO, err::AtomicError) =
    print(io, "AtomicError: ", err.msg)

"""
    @atomic a[I] = op(a[I], val)
    @atomic a[I] ...= val

Atomically perform a sequence of operations that loads an array element `a[I]`, performs the
operation `op` on that value and a second value `val`, and writes the result back to the
array. This sequence can be written out as a regular assignment, in which case the same
array element should be used in the left and right hand side of the assignment, or as an
in-place application of a known operator. In both cases, the array reference should be pure
and not induce any side-effects.

!!! warn
    This interface is experimental, and might change without warning.  Use the lower-level
    `atomic_...!` functions for a stable API, albeit one limited to natively-supported ops.
"""
macro atomic(ex)
    # decode assignment and call
    if ex.head == :(ref)
        # @atomic b[i]
        ref = ex
        op = nothing
        val = nothing
    elseif ex.head == :(=)
        # @atomic b[i] = ...
        ref = ex.args[1]
        rhs = ex.args[2]
        if !isa(rhs, Expr)
            # @atomic b[i] = val
            op = nothing
            val = rhs
        elseif Meta.isexpr(rhs, :call)
            # @atomic b[i] = b[i] + val
            # TODO: matching on a call is ambiguous (`@atomicm b[i] = Int32(0)` is a call)
            #       so we should probably only support in-place assignment?
            op = rhs.args[1]
            if rhs.args[2] != ref
                throw(AtomicError("right-hand side of a non-inplace @atomic assignment should reference the left-hand side"))
            end
            val = rhs.args[3]
        else
            throw(AtomicError("right-hand side of an @atomic assignment should be a value or a call"))
        end
    elseif haskey(inplace_ops, ex.head)
        # @atomic b[i] += val
        op = inplace_ops[ex.head]
        ref = ex.args[1]
        val = ex.args[2]
    else
        throw(AtomicError("unknown @atomic expression"))
    end

    # decode array expression
    Meta.isexpr(ref, :ref) || throw(AtomicError("@atomic should be applied to an array reference expression"))
    array = ref.args[1]
    indices = Expr(:tuple, ref.args[2:end]...)

    if val === nothing
        esc(quote
            $atomic_arrayref($array, $indices)
        end)
    else
        esc(quote
            $atomic_arrayset($array, $indices, $op, $val)
        end)
    end
end

# FIXME: make this respect the indexing style
@inline atomic_arrayref(A::AbstractArray{T}, Is::Tuple) where {T} =
    atomic_arrayref(A, Base._to_linear_index(A, Is...))
@inline atomic_arrayset(A::AbstractArray{T}, Is::Tuple, op, val) where {T} =
    atomic_arrayset(A, Base._to_linear_index(A, Is...), op, convert(T, val))

# native atomics
@inline atomic_arrayref(A::AbstractArray, I::Integer) = atomic_load_explicit(pointer(A, I))
@inline atomic_arrayset(A::AbstractArray{T}, I::Integer, ::Nothing, val) where T =
    atomic_store_explicit(pointer(A, I), convert(T, val))
for (op,impl,typ) in [(:(+), :(atomic_fetch_add_explicit), [:UInt32,:Int32,:Float32]),
                      (:(-), :(atomic_fetch_sub_explicit), [:UInt32,:Int32,:Float32]),
                      (:(&), :(atomic_fetch_and_explicit), [:UInt32,:Int32]),
                      (:(|), :(atomic_fetch_or_explicit),  [:UInt32,:Int32]),
                      (:(⊻), :(atomic_fetch_xor_explicit), [:UInt32,:Int32]),
                      (:max, :(atomic_fetch_max_explicit), [:UInt32,:Int32]),
                      (:min, :(atomic_fetch_min_explicit), [:UInt32,:Int32]),
                      (:max, :(atomic_max_explicit),       [:UInt64]),
                      (:min, :(atomic_min_explicit),       [:UInt64])]
    @eval @inline atomic_arrayset(A::AbstractArray{T}, I::Integer, ::typeof($op),
                                  val::T) where {T<:Union{$(typ...)}} =
        $impl(pointer(A, I), val)
end

# native atomics that are not supported on all devices
@inline function atomic_arrayset(A::AbstractArray{T}, I::Integer, op::typeof(+),
                                 val::T) where {T <: AbstractFloat}
    ptr = pointer(A, I)
    # Float32 add/sub are native for device memory since Metal 3.0, and for threadgroup
    # memory since Metal 4.1. Earlier threadgroup targets fail in the intrinsic itself.
    atomic_fetch_add_explicit(ptr, val)
end
@inline function atomic_arrayset(A::AbstractArray{T}, I::Integer, op::typeof(-),
                                 val::T) where {T <: AbstractFloat}
    ptr = pointer(A, I)
    atomic_fetch_sub_explicit(ptr, val)
end

# fallback using compare-and-swap
@inline atomic_arrayset(A::AbstractArray{T}, I::Integer, op::Function, val) where {T} =
    atomic_fetch_op_explicit(pointer(A, I), op, val)
