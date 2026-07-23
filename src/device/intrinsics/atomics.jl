# Atomic Functions

const atomic_memory_spaces = (
    (AS.Device,      "global", thread_scope_device),
    (AS.ThreadGroup, "local",  thread_scope_threadgroup),
)


@inline function default_atomic_flags(order::memory_order, ::Val{A}) where {A}
    order === memory_order_relaxed && return MemoryFlagNone
    A === AS.Device ? MemoryFlagDevice : MemoryFlagThreadGroup
end

# MSL 4.1 requires callers to spell out flags for ordered atomics. We instead default
# to the memory region addressed by the pointer, while retaining mem_none for relaxed
# operations to match the no-flags MSL overload.
@inline atomic_order_and_flags_available(order, flags) =
    (order === memory_order_relaxed && flags == MemoryFlagNone) ||
    metal_version() >= sv"4.1"

@inline function validate_atomic_arguments(::Val{order}, ::Val{flags}) where {order, flags}
    @static_assert(order isa memory_order, "Invalid atomic memory ordering.")
    @static_assert(atomic_order_and_flags_available(order, flags),
                   "Ordered atomics and memory flags require Metal 4.1 or newer.")
end

## low-level functions
for (typ, typnam) in ((:Int32, "i32"), (:UInt32, "i32")),
    (as, memnam, scope) in atomic_memory_spaces

    @eval begin
        @inline function atomic_load_explicit(
            ptr::LLVMPtr{$typ,$as}, order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            atomic_load_explicit(ptr, Val(order), Val(flags))
        end

        function atomic_load_explicit(ptr::LLVMPtr{$typ,$as}, ::Val{order},
                                      ::Val{flags}) where {order, flags}
            validate_atomic_arguments(Val(order), Val(flags))
            @typed_ccall($"air.atomic.$memnam.load.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Int32, Int32, Int32, Bool),
                         ptr, Val(order), Val($scope), Val(flags), Val(false))
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
                                                       ::Val{success_order}, ::Val{failure_order},
                                                       ::Val{flags}) where {success_order, failure_order, flags}
            validate_atomic_arguments(Val(success_order), Val(flags))
            @static_assert(failure_order isa memory_order, "Invalid atomic memory ordering.")
            # NOTE: we deviate slightly from the Metal/C++ API here, not returning the
            #       status boolean, but the contents of the expected value box, which will
            #       have been changed to the current value if the exchange failed.
            expected_box = Ref(expected)
            @typed_ccall($"air.atomic.$memnam.cmpxchg.weak.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Ptr{$typ}, $typ, Int32, Int32, Int32, Int32, Bool),
                         ptr, expected_box, desired, Val(success_order),
                         Val(failure_order), Val($scope), Val(flags), Val(false))
            expected_box[]
        end
    end
end

const atomic_value_intrinsics = (
    (:store,     "store", (:Int32, :UInt32),           false),
    (:exchange,  "xchg",  (:Int32, :UInt32),           true),
    (:fetch_add, "add",   (:Int32, :UInt32, :Float32), true),
    (:fetch_sub, "sub",   (:Int32, :UInt32, :Float32), true),
    (:fetch_min, "min",   (:Int32, :UInt32),           true),
    (:fetch_max, "max",   (:Int32, :UInt32),           true),
    (:fetch_and, "and",   (:Int32, :UInt32),           true),
    (:fetch_or,  "or",    (:Int32, :UInt32),           true),
    (:fetch_xor, "xor",   (:Int32, :UInt32),           true),
)

for (op, air_op, types, returns) in atomic_value_intrinsics, typ in types,
    (as, memnam, scope) in atomic_memory_spaces
    typnam = typ === :Float32 ? "f32" : "i32"
    if op ∉ (:store, :exchange) && typ !== :Float32
        typnam = "$(typ === :Int32 ? "s" : "u").$typnam"
    end
    f = Symbol("atomic_$(op)_explicit")
    return_type = returns ? typ : :Nothing
    availability = op ∈ (:fetch_add, :fetch_sub) && typ === :Float32 && as === AS.ThreadGroup ?
        :(@static_assert(metal_version() >= sv"4.1",
                          "Float32 threadgroup atomic operations require Metal 4.1 or newer.")) :
        nothing

    @eval begin
        @inline function $f(
            ptr::LLVMPtr{$typ,$as}, desired::$typ,
            order::memory_order=memory_order_relaxed,
            flags::Union{MemoryFlags,UInt32}=default_atomic_flags(order, Val($as)))
            $f(ptr, desired, Val(order), Val(flags))
        end

        function $f(ptr::LLVMPtr{$typ,$as}, desired::$typ, ::Val{order}, ::Val{flags}) where {order, flags}
            validate_atomic_arguments(Val(order), Val(flags))
            $availability
            @typed_ccall($"air.atomic.$memnam.$air_op.$typnam", llvmcall, $return_type,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Int32, Bool),
                         ptr, desired, Val(order), Val($scope), Val(flags), Val(false))
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
