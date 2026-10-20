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
    intr_i16 = Symbol(intr, :_i16)
    intr = Symbol(intr)
    @eval begin
        # UInt32
        export $(intr)
        @device_function $(intr)() = ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ()) + $(UInt32(offset))

        # UInt16
        export $(intr_i16)
        @device_function $(intr_i16)() = ccall($"extern julia.air.$intr.i16", llvmcall, UInt16, ()) + $(UInt16(offset))
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
    intr_i16 = Symbol(intr, :_i16)
    intr = Symbol(intr)
    @eval begin
        # UInt32
        export $(intr)
        @device_function function $(intr)()
            vec = ccall($"extern julia.air.$intr.v3i32", llvmcall,
                        NTuple{3, VecElement{UInt32}}, ())
            (x = vec[1].value + $(UInt32(offset)),
             y = vec[2].value + $(UInt32(offset)),
             z = vec[3].value + $(UInt32(offset)))
        end

        # UInt16
        export $(intr_i16)
        @device_function function $(intr_i16)()
            vec = ccall($"extern julia.air.$intr.v3i16", llvmcall,
                        NTuple{3, VecElement{UInt16}}, ())
            (x = vec[1].value + $(UInt16(offset)),
             y = vec[2].value + $(UInt16(offset)),
             z = vec[3].value + $(UInt16(offset)))
        end
    end

    # deprecated aliases
    @eval begin
        export $(Symbol(intr, "_1d"))
        export $(Symbol(intr, "_2d"))
        export $(Symbol(intr, "_3d"))

        function $(Symbol(intr, "_1d"))()
            $(intr)().x
        end

        function $(Symbol(intr, "_2d"))()
            vec = $(intr)()
            (x = vec.x,
             y = vec.y)
        end

        $(Symbol(intr, "_3d"))() = $(intr)()
    end
end

## Documentation

const xyz = "@NamedTuple{x::UInt32, y::UInt32, z::UInt32}"

for (intr, ret, desc) in (
        # dimensionless
        ("thread_index_in_threadgroup", "UInt32",
         "Return the 1-based linear index of the current thread in its threadgroup."),
        ("simdgroup_index_in_threadgroup", "UInt32",
         "Return the 1-based index of the current SIMD-group in its threadgroup."),
        ("thread_index_in_simdgroup", "UInt32",
         "Return the 1-based index of the current thread in its SIMD-group (its lane)."),
        ("quadgroup_index_in_threadgroup", "UInt32",
         "Return the 1-based index of the current quad-group in its threadgroup."),
        ("thread_index_in_quadgroup", "UInt32",
         "Return the 1-based index of the current thread in its quad-group (1 to 4)."),
        ("simdgroups_per_threadgroup", "UInt32",
         "Return the number of SIMD-groups in the current threadgroup."),
        ("dispatch_simdgroups_per_threadgroup", "UInt32",
         """Return the number of SIMD-groups in a threadgroup of the size specified at dispatch.
         As [`@metal`](@ref) only launches whole threadgroups, this equals
         [`simdgroups_per_threadgroup`](@ref)."""),
        ("quadgroups_per_threadgroup", "UInt32",
         "Return the number of quad-groups in the current threadgroup."),
        ("dispatch_quadgroups_per_threadgroup", "UInt32",
         """Return the number of quad-groups in a threadgroup of the size specified at dispatch.
         As [`@metal`](@ref) only launches whole threadgroups, this equals
         [`quadgroups_per_threadgroup`](@ref)."""),
        ("threads_per_simdgroup", "UInt32",
         """Return the number of threads in a SIMD-group, i.e., the thread execution width
         (32 on current Apple GPUs)."""),
        ("thread_execution_width", "UInt32",
         """Return the thread execution width, i.e., the number of threads in a SIMD-group.
         Deprecated in MSL; use [`threads_per_simdgroup`](@ref) instead."""),
        # dimensioned
        ("thread_position_in_grid", xyz,
         """Return the 1-based position of the current thread in the grid, per dimension. For
         a one-dimensional launch, `thread_position_in_grid().x` is the global index of the
         thread."""),
        ("thread_position_in_threadgroup", xyz,
         "Return the 1-based position of the current thread in its threadgroup, per dimension."),
        ("threadgroup_position_in_grid", xyz,
         "Return the 1-based position of the current threadgroup in the grid, per dimension."),
        ("threads_per_grid", xyz,
         """Return the size of the grid in threads, per dimension: the product of the `groups`
         and `threads` arguments of [`@metal`](@ref)."""),
        ("threads_per_threadgroup", xyz,
         """Return the number of threads in the current threadgroup, per dimension: the
         `threads` argument of [`@metal`](@ref)."""),
        ("dispatch_threads_per_threadgroup", xyz,
         """Return the threadgroup size specified at dispatch, per dimension. As
         [`@metal`](@ref) only launches whole threadgroups, this equals
         [`threads_per_threadgroup`](@ref)."""),
        ("threadgroups_per_grid", xyz,
         """Return the number of threadgroups in the grid, per dimension: the `groups`
         argument of [`@metal`](@ref)."""),
        ("grid_origin", xyz,
         "Return the 1-based origin of the grid, for kernels that read per-thread stage-in data."),
        ("grid_size", xyz,
         "Return the size of the grid, for kernels that read per-thread stage-in data."),
    )
    ret16 = replace(ret, "UInt32" => "UInt16")
    doc = """
        $intr()::$ret

    $desc

    See also `$(intr)_i16`, which returns `UInt16` values.
    """
    @eval @doc $doc $(Symbol(intr))

    doc16 = """
        $(intr)_i16()::$ret16

    Like [`$intr`](@ref), but returns `UInt16` values.
    """
    @eval @doc $doc16 $(Symbol(intr, "_i16"))
end
