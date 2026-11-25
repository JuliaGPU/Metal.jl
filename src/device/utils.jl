# local method table for device functions
Base.Experimental.@MethodTable(method_table)

# throw a device-side exception of type `name`, reported with `reason`
using GPUCompiler: @gputhrow

const HAS_CONSISTENT_OVERLAY = VERSION >= v"1.12.0-DEV.745" || v"1.11-rc1" <= VERSION < v"1.12-"

@public var"@device_override", var"@device_function"

"""
    Metal.@device_override function f(...) ... end

Define a method that replaces a method of `f` in code that Metal.jl compiles, without
changing it on the host, e.g. to implement a function of Base for the GPU.

The method must be consistent with the one it replaces: for the same arguments, it returns
an identical value, or throws when that method throws. Other replacements belong in a method
table of their own (`Base.Experimental.@overlay`), which compiler jobs with parameters of
their own (see [`AbstractMetalCompilerParams`](@ref)) can search before Metal.jl's.
"""
macro device_override(ex)
    esc(GPUToolbox.Overlays.device_override(__module__, GlobalRef(Metal, :method_table), ex))
end

"""
    Metal.@device_function function f(...) ... end

Define a function, or every function in a `begin` block, that is only available in code
that Metal.jl compiles, e.g. because it calls intrinsics. Calling it on the host throws an
error.
"""
macro device_function(ex)
    esc(GPUToolbox.Overlays.device_function(__module__, GlobalRef(Metal, :method_table), ex))
end
