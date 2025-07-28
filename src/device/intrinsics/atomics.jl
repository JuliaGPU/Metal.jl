# Atomic Functions

@enum memory_order::Int32 begin
    memory_order_relaxed = 0
end

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


## low-level functions
for typ in (:Int32, :UInt32), as in (AS.Device, AS.ThreadGroup)
    typnam = atomic_type_names[typ]
    memnam, memid = atomic_memory_names[as]

    @eval begin
        function atomic_store_explicit(ptr::LLVMPtr{$typ,$as}, desired::$typ)
            @typed_ccall($"air.atomic.$memnam.store.$typnam", llvmcall, Nothing,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Bool),
                         ptr, desired, Val(memory_order_relaxed), Val($memid), Val(true))
        end

        function atomic_load_explicit(ptr::LLVMPtr{$typ,$as})
            @typed_ccall($"air.atomic.$memnam.load.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Int32, Int32, Bool),
                         ptr, Val(memory_order_relaxed), Val($memid), Val(true))
        end

        function atomic_exchange_explicit(ptr::LLVMPtr{$typ,$as}, desired::$typ)
            @typed_ccall($"air.atomic.$memnam.xchg.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Bool),
                         ptr, desired, Val(memory_order_relaxed), Val($memid), Val(true))
        end

        function atomic_compare_exchange_weak_explicit(ptr::LLVMPtr{$typ,$as},
                                                       expected::$typ, desired::$typ)
            # NOTE: we deviate slightly from the Metal/C++ API here, not returning the
            #       status boolean, but the contents of the expected value box, which will
            #       have been changed to the current value if the exchange failed.
            expected_box = Ref(expected)
            @typed_ccall($"air.atomic.$memnam.cmpxchg.weak.$typnam", llvmcall, Bool,
                         (LLVMPtr{$typ,$as}, Ptr{$typ}, $typ, Int32, Int32, Int32, Bool),
                         ptr, expected_box, desired, Val(memory_order_relaxed),
                         Val(memory_order_relaxed), Val($memid), Val(true))
            expected_box[]
        end
    end
end

# Float32 atomics are only available on Metal 3.0, and additionally only for
# device memory, so we just skip them and reinterpret. That should be safe?
atomic_store_explicit(ptr::LLVMPtr{Float32,AS}, desired::Float32) where {AS} =
    atomic_store_explicit(reinterpret(LLVMPtr{UInt32,AS}, ptr), reinterpret(UInt32, desired))
atomic_load_explicit(ptr::LLVMPtr{Float32,AS}) where {AS} =
    reinterpret(Float32, atomic_load_explicit(reinterpret(LLVMPtr{UInt32,AS}, ptr)))
atomic_exchange_explicit(ptr::LLVMPtr{Float32,AS}, desired::Float32) where {AS} =
    reinterpret(Float32, atomic_exchange_explicit(reinterpret(LLVMPtr{UInt32,AS}, ptr),
                                                  reinterpret(UInt32, desired)))
function atomic_compare_exchange_weak_explicit(ptr::LLVMPtr{Float32,AS}, expected::Float32,
                                               desired::Float32) where {AS}
    ptr′ = reinterpret(LLVMPtr{UInt32,AS}, ptr)
    expected′ = reinterpret(UInt32, expected)
    desired′ = reinterpret(UInt32, desired)
    return reinterpret(Float32, atomic_compare_exchange_weak_explicit(ptr′, expected′, desired′))
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
        function $f(ptr::LLVMPtr{$typ,$as}, desired::$typ)
            @typed_ccall($"air.atomic.$memnam.$op.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, $typ, Int32, Int32, Bool),
                         ptr, desired, Val(memory_order_relaxed), Val($memid), Val(true))
        end
    end
end

# TODO: non-fetch 64-bit min/max atomics (hardware support?)

# generic atomic support using compare-and-swap
@inline function atomic_fetch_op_explicit(ptr::LLVMPtr{T}, op::Function, val) where {T}
    old = Base.unsafe_load(ptr)
    while true
        cmp = old
        new = convert(T, op(old, val))
        old = atomic_compare_exchange_weak_explicit(ptr, cmp, new)
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
