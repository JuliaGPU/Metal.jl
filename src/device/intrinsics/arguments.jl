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

        @device_function $(Symbol(intr))() = ccall($"extern julia.air.$intr.i32", llvmcall, UInt32, ()) + UInt32($offset)
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
        export $(Symbol(intr))

        @device_function function $(Symbol(intr))()
            vec = ccall($"extern julia.air.$intr.v3i32", llvmcall,
                        NTuple{3, VecElement{UInt32}}, ())
            (x = vec[1].value + UInt32($offset),
             y = vec[2].value + UInt32($offset),
             z = vec[3].value + UInt32($offset))
        end
    end

    # deprecated aliases
    @eval begin
        export $(Symbol(intr * "_1d"))
        export $(Symbol(intr * "_2d"))
        export $(Symbol(intr * "_3d"))

        function $(Symbol(intr * "_1d"))()
            $(Symbol(intr))().x
        end

        function $(Symbol(intr * "_2d"))()
            vec = $(Symbol(intr))()
            (x = vec.x,
             y = vec.y)
        end

        $(Symbol(intr * "_3d"))() = $(Symbol(intr))()
    end
end

## Documentation

# Dimensionless intrinsics

@doc """
    dispatch_quadgroups_per_threadgroup()::UInt32

Return the quadgroup execution width of a threadgroup specified at dispatch.
""" dispatch_quadgroups_per_threadgroup

@doc """
    dispatch_simdgroups_per_threadgroup()::UInt32

Return the simdgroup execution width of a threadgroup specified at dispatch.
""" dispatch_simdgroups_per_threadgroup

@doc """
    quadgroup_index_in_threadgroup()::UInt32

Return the index of a quadgroup within a threadgroup.
""" quadgroup_index_in_threadgroup

@doc """
    quadgroups_per_threadgroup()::UInt32

Return the quadgroup execution width of a threadgroup.
""" quadgroups_per_threadgroup

@doc """
    simdgroup_index_in_threadgroup()::UInt32

Return the index of a simdgroup within a threadgroup.
""" simdgroup_index_in_threadgroup

@doc """
    simdgroups_per_threadgroup()::UInt32

Return the simdgroup execution width of a threadgroup.
""" simdgroups_per_threadgroup

@doc """
    thread_index_in_quadgroup()::UInt32

Return the index of the current thread in its quadgroup.
""" thread_index_in_quadgroup

@doc """
    thread_index_in_simdgroup()::UInt32

Return the index of the current thread in its simdgroup.
""" thread_index_in_simdgroup

@doc """
    thread_index_in_threadgroup()::UInt32

Return the index of the current thread in its threadgroup.
""" thread_index_in_threadgroup

@doc """
    thread_execution_width()::UInt32

Return the execution width of the compute unit.

This function has been deprecated as of Metal 3.

Use [`threads_per_simdgroup`](@ref) instead.
""" thread_execution_width

@doc """
    threads_per_simdgroup()::UInt32

Return the thread execution width of a simdgroup.
""" threads_per_simdgroup


# Dimensioned intrinsics

@doc """
    dispatch_threads_per_threadgroup()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the thread execution width specified at dispatch for a threadgroup.
""" dispatch_threads_per_threadgroup

@doc """
    grid_origin()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the origin offset of the grid for threads that read per-thread stage-in data.
""" grid_origin

@doc """
    grid_size()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return maximum size of the grid for threads that read per-thread stage-in data.
""" grid_size

@doc """
    thread_position_in_threadgroup()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the current thread's unique position within a threadgroup.
""" thread_position_in_threadgroup

@doc """
    thread_position_in_grid()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the current thread's position in an N-dimensional grid of threads.
""" thread_position_in_grid

@doc """
    threadgroup_position_in_grid()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the current threadgroup's unique position within the grid.
""" threadgroup_position_in_grid

@doc """
    threadgroups_per_grid()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the number of threadgroups per grid.
""" threadgroups_per_grid

@doc """
    threads_per_grid()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the grid size.
""" threads_per_grid

@doc """
    threads_per_threadgroup()::@NamedTuple{x::UInt32, y::UInt32, z::UInt32}

Return the thread execution width of a threadgroup.
""" threads_per_threadgroup
