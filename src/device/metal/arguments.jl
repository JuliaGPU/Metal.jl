# special values normally exposed through input arguments

## kernel functions

const nodim_intr = [
    ("dispatch_quadgroups_per_threadgroup", 0),
    ("dispatch_simdgroups_per_threadgroup", 0),
    ("quadgroup_index_in_threadgroup", 1),
    ("quadgroups_per_threadgroup", 0),
    ("simdgroup_index_in_threadgroup", 1),
    ("simdgroups_per_threadgroup", 0),
    ("thread_index_in_quadgroup", 1),
    ("thread_index_in_simdgroup", 1),
    ("thread_index_in_threadgroup", 1),
    ("thread_execution_width", 0),
    ("threads_per_simdgroup", 0),
]

for (intr, offset) in nodim_intr
    # XXX: these are also available as UInt16 (ushort)
    @eval begin
        export $(Symbol(intr))
    
        $(Symbol(intr))() = ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ()) + UInt32($offset)
    end
end

# ushort vec or uint vec
const dim_intr = [
    ("dispatch_threads_per_threadgroup", 0),
    ("grid_origin", 1),
    ("grid_size", 0),
    ("thread_position_in_grid", 1),
    ("thread_position_in_threadgroup", 1),
    ("threadgroup_position_in_grid", 1),
    ("threadgroups_per_grid", 0),
    ("threads_per_grid", 0),
    ("threads_per_threadgroup", 0),
]

for (intr, offset) in dim_intr
    # XXX: these are also available as UInt16 (ushort)
    @eval begin
        export $(Symbol(intr * "_1d"))
        export $(Symbol(intr * "_2d"))
        export $(Symbol(intr * "_3d"))

        $(Symbol(intr * "_1d"))() =
            ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ()) + UInt32($offset)
        
        $(Symbol(intr * "_2d"))() =
            Base.llvmcall("""%3 = add <2 x i32> %1, %0
                ret <2 x i32> %3""",
                Tuple{VecElement{UInt32},VecElement{UInt32}},
                Tuple{Tuple{VecElement{UInt32},VecElement{UInt32}},
                Tuple{VecElement{UInt32},VecElement{UInt32}}},
                (VecElement{UInt32}(1),VecElement{UInt32}(1)),
                ccall($"extern julia.air.$intr.v2i32", llvmcall, NTuple{2, VecElement{UInt32}}, ()))

        $(Symbol(intr * "_3d"))() =
            Base.llvmcall("""%3 = add <3 x i32> %1, %0
                ret <3 x i32> %3""",
                Tuple{VecElement{UInt32},VecElement{UInt32},VecElement{UInt32}},
                Tuple{Tuple{VecElement{UInt32},VecElement{UInt32},VecElement{UInt32}},
                Tuple{VecElement{UInt32},VecElement{UInt32},VecElement{UInt32}}},
                (VecElement{UInt32}(1),VecElement{UInt32}(1),VecElement{UInt32}(1)),
                ccall($"extern julia.air.$intr.v3i32", llvmcall, NTuple{3, VecElement{UInt32}}, ()))
    end
end
