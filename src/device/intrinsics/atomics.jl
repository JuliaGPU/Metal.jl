# Atomic Functions

@enum memory_order::Int32 begin
    memory_order_relaxed = 0
end

# XXX: the integers should come from some enum
const memory_names = Dict(
    AS.Device => ("global", Int32(2)),
    AS.ThreadGroup => ("local", Int32(1))
)

const type_names = Dict(
    :Int32 => "i32",
    :UInt32 => "i32",
    :Int64 => "i64",
    :UInt64 => "i64",
    :Float32 => "f32"
)


## low-level functions

# NOTE: Float32 atomics are only available on Metal 3.0, but we can't check that at runtime

for typ in (:Int32, :Float32), as in (AS.Device, AS.ThreadGroup)
    typnam = type_names[typ]
    memnam, memid = memory_names[as]
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
            # NOTE: we deviate slightly from the Metal/C++ API here
            #       (why do they pass the expected value by reference?)
            expected_box = Ref(expected)
            @typed_ccall($"air.atomic.$memnam.cmpxchg.weak.$typnam", llvmcall, $typ,
                         (LLVMPtr{$typ,$as}, Ptr{$typ}, $typ, Int32, Int32, Int32, Bool),
                         ptr, expected_box, desired, Val(memory_order_relaxed),
                         Val(memory_order_relaxed), Val($memid), Val(true))
        end
    end
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
    typnam = type_names[typ]
    if typ in [:Int32, :Int64]
        typnam = "s.$typnam"
    elseif typ in [:UInt32, :UInt64]
        typnam = "u.$typnam"
    end
    memnam, memid = memory_names[as]
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
