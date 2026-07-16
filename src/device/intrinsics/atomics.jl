# Atomic Functions

# XXX: the integers should come from some enum
const atomic_memory_names = Dict(
    AS.Device      => ("global", Int32(2)),
    AS.ThreadGroup => ("local",  Int32(1))
)

const atomic_type_names = Dict(
    :Int32   => "i32",
    :UInt32  => "i32",
    :Int64   => "i64",
    :UInt64  => "i64",
    :Float32 => "f32"
)

# Keep availability checks in device code so target constants can propagate and
# enclosing `metal_version()` guards can eliminate unavailable operations.
@inline function check_atomic_memory_order(::Val{order}) where {order}
    if order === memory_order_relaxed
        return
    elseif order === memory_order_acquire
        @static_assert(metal_version() >= sv"4.1",
                       "Atomic memory_order_acquire requires Metal 4.1 or newer.")
    elseif order === memory_order_release
        @static_assert(metal_version() >= sv"4.1",
                       "Atomic memory_order_release requires Metal 4.1 or newer.")
    elseif order === memory_order_acq_rel
        @static_assert(metal_version() >= sv"4.1",
                       "Atomic memory_order_acq_rel requires Metal 4.1 or newer.")
    elseif order === memory_order_seq_cst
        @static_assert(metal_version() >= sv"4.1",
                       "Atomic memory_order_seq_cst requires Metal 4.1 or newer.")
    else
        @static_assert(false, "Invalid atomic memory ordering.")
    end
    return
end

@inline function check_atomic_flags()
    @static_assert(metal_version() >= sv"4.1",
                   "Atomic memory flags require Metal 4.1 or newer.")
    return
end


@inline function default_atomic_flags(order::memory_order, ::Val{A}) where {A}
    order === memory_order_relaxed && return MemoryFlagNone
    A === AS.Device ? MemoryFlagDevice : MemoryFlagThreadGroup
end

@inline valid_atomic_order(order) =
    order === memory_order_relaxed || order === memory_order_acquire ||
    order === memory_order_release || order === memory_order_acq_rel ||
    order === memory_order_seq_cst

# MSL 4.1 requires callers to spell out flags for ordered atomics. We instead default
# to the memory region addressed by the pointer, while retaining mem_none for relaxed
# operations to match the no-flags MSL overload.
@inline atomic_order_and_flags_available(order, flags) =
    (order === memory_order_relaxed && flags == MemoryFlagNone) ||
    metal_version() >= sv"4.1"

# MSL specification section 6.15: failure ordering is restricted to relaxed, acquire,
# or sequentially consistent, and may not be stronger than the success ordering.
@inline function valid_atomic_compare_exchange_failure_order(success, failure)
    (failure === memory_order_relaxed || failure === memory_order_acquire ||
     failure === memory_order_seq_cst) ||
        return false
    success === memory_order_relaxed && return failure === memory_order_relaxed
    success === memory_order_acquire && return failure !== memory_order_seq_cst
    success === memory_order_release && return failure === memory_order_relaxed
    success === memory_order_acq_rel && return failure !== memory_order_seq_cst
    success === memory_order_seq_cst
end

## low-level functions
for typ in (:Int32, :UInt32), as in (AS.Device, AS.ThreadGroup)
    typnam = atomic_type_names[typ]
    memnam, memid = atomic_memory_names[as]

    @eval begin
        @inline function atomic_store_explicit(
            ptr::LLVMPtr{$typ,$as}, desired::$typ,
            order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            atomic_store_explicit(ptr, desired, Val(order), Val(flags))
        end

        function atomic_store_explicit(ptr::LLVMPtr{$typ,$as}, desired::$typ,
                                       ::Val{O}, ::Val{F}) where {O,F}
            @static_assert(O === memory_order_relaxed || O === memory_order_release ||
                           O === memory_order_seq_cst,
                           "atomic_store_explicit only supports relaxed, release, or sequentially consistent ordering.")
            @static_assert(atomic_order_and_flags_available(O, F),
                           "Ordered atomics and memory flags require Metal 4.1 or newer.")
            @typed_ccall($"air.atomic.$memnam.store.$typnam", llvmcall, Nothing,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Int32, Bool),
                         ptr, desired, Val(O), Val($memid), Val(F), Val(false))
        end

        @inline function atomic_load_explicit(
            ptr::LLVMPtr{$typ,$as}, order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            atomic_load_explicit(ptr, Val(order), Val(flags))
        end

        function atomic_load_explicit(ptr::LLVMPtr{$typ,$as}, ::Val{O},
                                      ::Val{F}) where {O,F}
            @static_assert(O === memory_order_relaxed || O === memory_order_acquire ||
                           O === memory_order_seq_cst,
                           "atomic_load_explicit only supports relaxed, acquire, or sequentially consistent ordering.")
            @static_assert(atomic_order_and_flags_available(O, F),
                           "Ordered atomics and memory flags require Metal 4.1 or newer.")
            @typed_ccall($"air.atomic.$memnam.load.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Int32, Int32, Int32, Bool),
                         ptr, Val(O), Val($memid), Val(F), Val(false))
        end

        @inline function atomic_exchange_explicit(
            ptr::LLVMPtr{$typ,$as}, desired::$typ,
            order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            atomic_exchange_explicit(ptr, desired, Val(order), Val(flags))
        end

        function atomic_exchange_explicit(ptr::LLVMPtr{$typ,$as}, desired::$typ,
                                          ::Val{O}, ::Val{F}) where {O,F}
            @static_assert(valid_atomic_order(O), "Invalid atomic memory ordering.")
            @static_assert(atomic_order_and_flags_available(O, F),
                           "Ordered atomics and memory flags require Metal 4.1 or newer.")
            @typed_ccall($"air.atomic.$memnam.xchg.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Int32, Bool),
                         ptr, desired, Val(O), Val($memid), Val(F), Val(false))
        end

        @inline function atomic_compare_exchange_weak_explicit(
            ptr::LLVMPtr{$typ,$as}, expected::$typ, desired::$typ,
            success_order::memory_order=memory_order_relaxed,
            failure_order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(success_order, Val($as)))
            atomic_compare_exchange_weak_explicit(ptr, expected, desired, Val(success_order),
                                                  Val(failure_order), Val(flags))
        end

        function atomic_compare_exchange_weak_explicit(ptr::LLVMPtr{$typ,$as},
                                                       expected::$typ, desired::$typ,
                                                       ::Val{S}, ::Val{F},
                                                       ::Val{G}) where {S,F,G}
            @static_assert(valid_atomic_order(S), "Invalid atomic memory ordering.")
            @static_assert(valid_atomic_compare_exchange_failure_order(S, F),
                           "atomic_compare_exchange_weak_explicit failure ordering must be relaxed, acquire, or sequentially consistent and no stronger than the success ordering.")
            @static_assert(atomic_order_and_flags_available(S, G),
                           "Ordered atomics and memory flags require Metal 4.1 or newer.")
            # NOTE: we deviate slightly from the Metal/C++ API here, not returning the
            #       status boolean, but the contents of the expected value box, which will
            #       have been changed to the current value if the exchange failed.
            expected_box = Ref(expected)
            @typed_ccall($"air.atomic.$memnam.cmpxchg.weak.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Ptr{$typ}, $typ, Int32, Int32, Int32, Int32, Bool),
                         ptr, expected_box, desired, Val(S),
                         Val(F), Val($memid), Val(G), Val(false))
            expected_box[]
        end
    end
end

# Float32 atomics are implemented by reinterpreting through UInt32.
for op in (:store, :exchange)
    f = Symbol("atomic_$(op)_explicit")
    @eval begin
        @inline function $f(
            ptr::LLVMPtr{Float32,AS}, desired::Float32,
            order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val(AS))) where {AS}
            $f(ptr, desired, Val(order), Val(flags))
        end
        @inline function $f(ptr::LLVMPtr{Float32,AS}, desired::Float32,
                            order::Val, flags::Val) where {AS}
            result = $f(reinterpret(LLVMPtr{UInt32,AS}, ptr),
                        reinterpret(UInt32, desired), order, flags)
            $(op === :store ? :(return result) : :(return reinterpret(Float32, result)))
        end
    end
end

@inline function atomic_load_explicit(
    ptr::LLVMPtr{Float32,AS}, order::memory_order=memory_order_relaxed,
    flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val(AS))) where {AS}
    atomic_load_explicit(ptr, Val(order), Val(flags))
end
@inline atomic_load_explicit(ptr::LLVMPtr{Float32,AS}, order::Val, flags::Val) where {AS} =
    reinterpret(Float32,
                atomic_load_explicit(reinterpret(LLVMPtr{UInt32,AS}, ptr), order, flags))

@inline function atomic_compare_exchange_weak_explicit(
    ptr::LLVMPtr{Float32,AS}, expected::Float32, desired::Float32,
    success_order::memory_order=memory_order_relaxed,
    failure_order::memory_order=memory_order_relaxed,
    flags::Union{MemoryFlags,UInt32}=default_atomic_flags(success_order, Val(AS))) where {AS}
    atomic_compare_exchange_weak_explicit(ptr, expected, desired, Val(success_order),
                                          Val(failure_order), Val(flags))
end
function atomic_compare_exchange_weak_explicit(ptr::LLVMPtr{Float32,AS}, expected::Float32,
                                               desired::Float32, success_order::Val,
                                               failure_order::Val, flags::Val) where {AS}
    ptr′ = reinterpret(LLVMPtr{UInt32,AS}, ptr)
    expected′ = reinterpret(UInt32, expected)
    desired′ = reinterpret(UInt32, desired)
    return reinterpret(Float32, atomic_compare_exchange_weak_explicit(ptr′, expected′, desired′,
                                                                     success_order, failure_order,
                                                                     flags))
end

const atomic_fetch_and_modify = [
    :add => [:Int32, :UInt32, :Float32],
    :sub => [:Int32, :UInt32, :Float32],
    :min => [:Int32, :UInt32],
    :max => [:Int32, :UInt32],
    :and => [:Int32, :UInt32],
    :or  => [:Int32, :UInt32],
    :xor => [:Int32, :UInt32]
]

for (op, types) in atomic_fetch_and_modify, typ in types, as in (AS.Device, AS.ThreadGroup)
    typnam = atomic_type_names[typ]
    if typ in [:Int32, :Int64]
        typnam = "s.$typnam"
    elseif typ in [:UInt32, :UInt64]
        typnam = "u.$typnam"
    end
    memnam, memid = atomic_memory_names[as]
    f = Symbol("atomic_fetch_$(op)_explicit")
    @eval begin
        @inline function $f(
            ptr::LLVMPtr{$typ,$as}, desired::$typ,
            order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            $f(ptr, desired, Val(order), Val(flags))
        end

        function $f(ptr::LLVMPtr{$typ,$as}, desired::$typ, ::Val{O}, ::Val{F}) where {O,F}
            @static_assert(valid_atomic_order(O), "Invalid atomic memory ordering.")
            @static_assert(atomic_order_and_flags_available(O, F),
                           "Ordered atomics and memory flags require Metal 4.1 or newer.")
            @typed_ccall($"air.atomic.$memnam.$op.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Int32, Bool),
                         ptr, desired, Val(O), Val($memid), Val(F), Val(false))
        end
    end
end

# TODO: non-fetch 64-bit min/max atomics (hardware support?)

# generic atomic support using compare-and-swap
@inline atomic_fetch_op_failure_order(order::Val) = order
@inline atomic_fetch_op_failure_order(::Val{memory_order_release}) = Val(memory_order_relaxed)
@inline atomic_fetch_op_failure_order(::Val{memory_order_acq_rel}) = Val(memory_order_acquire)

@inline function atomic_fetch_op_explicit(
    ptr::LLVMPtr{T,AS}, op::Function, val,
    order::memory_order=memory_order_relaxed,
    flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val(AS))) where {T,AS}
    atomic_fetch_op_explicit(ptr, op, val, Val(order), Val(flags))
end

@inline function atomic_fetch_op_explicit(ptr::LLVMPtr{T}, op::Function, val,
                                          order::Val, flags::Val) where {T}
    failure_order = atomic_fetch_op_failure_order(order)
    old = atomic_load_explicit(ptr, failure_order, flags)
    while true
        cmp = old
        new = convert(T, op(old, val))
        old = atomic_compare_exchange_weak_explicit(ptr, cmp, new, order, failure_order,
                                                    flags)
        isequal(old, cmp) && return old
    end
end


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
                      (:min, :(atomic_fetch_min_explicit), [:UInt32,:Int32])]
    @eval @inline atomic_arrayset(A::AbstractArray{T}, I::Integer, ::typeof($op),
                                  val::T) where {T<:Union{$(typ...)}} =
        $impl(pointer(A, I), val)
end

# native atomics that are not supported on all devices
@inline function atomic_arrayset(A::AbstractArray{T}, I::Integer, op::typeof(+),
                                 val::T) where {T <: AbstractFloat}
    ptr = pointer(A, I)
    # XXX: consider falling back to fetch_op here to support Metal < 3.0 (this also requires
    #      cmpxchg support for Float32, but we should be able to do that using bitcast)
    atomic_fetch_add_explicit(ptr, val)
end
@inline function atomic_arrayset(A::AbstractArray{T}, I::Integer, op::typeof(-),
                                 val::T) where {T <: AbstractFloat}
    ptr = pointer(A, I)
    # XXX: see above
    atomic_fetch_sub_explicit(ptr, val)
end

# fallback using compare-and-swap
@inline atomic_arrayset(A::AbstractArray{T}, I::Integer, op::Function, val) where {T} =
    atomic_fetch_op_explicit(pointer(A, I), op, val)
