# code reflection entry-points

#
# code_* replacements
#

# function to split off certain kwargs for selective forwarding, at run time.
# `@oneapi` does something similar at parse time, using `GPUCompiler.split_kwargs`.
function split_kwargs_runtime(kwargs, wanted::Vector{Symbol})
    remaining = Dict{Symbol, Any}()
    extracted = Dict{Symbol, Any}()
    for (key, value) in kwargs
        if key in wanted
            extracted[key] = value
        else
            remaining[key] = value
        end
    end
    return extracted, remaining
end

@public code_typed, code_warntype, code_llvm, code_air, code_native

# forward the rest to GPUCompiler with an appropriate CompilerJob.
# `code_air` shows the module as downgraded to AIR (and disassembled again), which maps
# onto GPUCompiler's `code_native`; `code_llvm` shows the IR before that lowering, still
# containing generic LLVM intrinsics. `code_native` is kept as an alias for `code_air`,
# as AIR is the closest thing to native code we can generate.
for (method, fwd) in [:code_typed    => :code_typed,
                      :code_warntype => :code_warntype,
                      :code_llvm     => :code_llvm,
                      :code_air      => :code_native,
                      :code_native   => :code_native]
    # only code_typed doesn't take a io argument
    args = method === :code_typed ? (:job,) : (:io, :job)

    @eval begin
        function $method(io::IO, @nospecialize(func), @nospecialize(types);
                         kernel::Bool=false, kwargs...)
            compiler_kwargs, kwargs = split_kwargs_runtime(kwargs, COMPILER_KWARGS)
            source = methodinstance(typeof(func), Base.to_tuple_type(types))
            config = compiler_config(device(); kernel, compiler_kwargs...)
            job = CompilerJob(source, config)
            GPUCompiler.$fwd($(args...); kwargs...)
        end
        $method(@nospecialize(func), @nospecialize(types); kwargs...) =
            $method(stdout, func, types; kwargs...)
    end
end

"""
    Metal.code_air([io=stdout], f, types; kernel=false, kwargs...)

Print the AIR that Metal.jl generates for calling `f` with arguments of `types` on the GPU:
the LLVM IR after lowering to AIR intrinsics and downgrading to the bitcode format Metal
reads, disassembled again. This is the code that Metal compiles for the GPU.

The types are those of the arguments inside the kernel, e.g., `MtlDeviceVector{Float32,1}`
rather than `MtlVector{Float32}`, so the [`@device_code_air`](@ref) macro is usually easier
to use. Pass `kernel=true` to compile `f` as a kernel, like [`@metal`](@ref) does, and
compiler keywords of `@metal` such as `metal` to change the target. Other keywords are
passed to GPUCompiler.jl.
"""
code_air

"""
    Metal.code_native([io=stdout], f, types; kwargs...)

An alias for [`Metal.code_air`](@ref): AIR is the closest to native code that Metal.jl
generates.
"""
code_native

"""
    Metal.code_llvm([io=stdout], f, types; kernel=false, kwargs...)

Like `InteractiveUtils.code_llvm`, print the LLVM IR that Julia generates for calling `f`
with arguments of `types` on the GPU, before it is lowered to AIR. See
[`Metal.code_air`](@ref) for the arguments.
"""
code_llvm

"""
    Metal.code_typed(f, types; kernel=false, kwargs...)

Like `InteractiveUtils.code_typed`, return the typed Julia IR for calling `f` with arguments
of `types` on the GPU. See [`Metal.code_air`](@ref) for the arguments.
"""
code_typed

"""
    Metal.code_warntype([io=stdout], f, types; kernel=false, kwargs...)

Like `InteractiveUtils.code_warntype`, print the typed Julia IR for calling `f` with
arguments of `types` on the GPU, highlighting values whose type could not be inferred. See
[`Metal.code_air`](@ref) for the arguments.
"""
code_warntype

#
# @device_code_* functions
#

export @device_code_lowered, @device_code_typed, @device_code_warntype,
       @device_code_llvm, @device_code_air, @device_code_metal, @device_code

# forward to GPUCompiler
@eval $(Symbol("@device_code_lowered")) = $(getfield(GPUCompiler, Symbol("@device_code_lowered")))
@eval $(Symbol("@device_code_typed")) = $(getfield(GPUCompiler, Symbol("@device_code_typed")))
@eval $(Symbol("@device_code_warntype")) = $(getfield(GPUCompiler, Symbol("@device_code_warntype")))
@eval $(Symbol("@device_code_llvm")) = $(getfield(GPUCompiler, Symbol("@device_code_llvm")))
@eval $(Symbol("@device_code_air")) = $(getfield(GPUCompiler, Symbol("@device_code_native")))
@eval $(Symbol("@device_code_metal")) = $(getfield(GPUCompiler, Symbol("@device_code_native")))
@eval $(Symbol("@device_code")) = $(getfield(GPUCompiler, Symbol("@device_code")))

"""
    @device_code_lowered ex

Evaluate `ex`, and return the lowered Julia IR of every kernel it compiles, like
`InteractiveUtils.@code_lowered`.
"""
var"@device_code_lowered"

"""
    @device_code_typed [kwargs...] ex

Evaluate `ex`, and return the typed Julia IR of every kernel it compiles, like
`InteractiveUtils.@code_typed`. To debug a kernel that fails to compile, pass
`only_failed=true interactive=true`, which inspects that kernel with Cthulhu.jl.
"""
var"@device_code_typed"

"""
    @device_code_warntype [io::IO=stdout] [kwargs...] ex

Evaluate `ex`, and print the typed Julia IR of every kernel it compiles, highlighting values
whose type could not be inferred, like `InteractiveUtils.@code_warntype`.
"""
var"@device_code_warntype"

"""
    @device_code_llvm [io::IO=stdout] [kwargs...] ex

Evaluate `ex`, and print the LLVM IR that Julia generates for every kernel it compiles,
before it is lowered to AIR (see [`@device_code_air`](@ref)). See [`Metal.code_llvm`](@ref)
for the keyword arguments.
"""
var"@device_code_llvm"

"""
    @device_code dir::AbstractString=... ex

Evaluate `ex`, and write all intermediate forms of the code of every kernel it compiles to
files in the directory `dir`.
"""
var"@device_code"

"""
    @device_code_air [io::IO=stdout] [kwargs...] ex

Evaluate `ex`, and print the AIR of every kernel it compiles: the LLVM IR after lowering to
AIR intrinsics and downgrading to the bitcode format Metal reads, disassembled again. This
is the code that Metal compiles for the GPU.

See [`Metal.code_air`](@ref) for the keyword arguments.
"""
var"@device_code_air"

"""
    @device_code_metal [io::IO=stdout] [kwargs...] ex

An alias for [`@device_code_air`](@ref).
"""
var"@device_code_metal"


#
# other
#

"""
    Metal.return_type(f, tt) -> r::Type

Return a type `r` such that `f(args...)::r` where `args::tt`.
"""
function return_type(@nospecialize(func), @nospecialize(tt))
    source = methodinstance(typeof(func), tt)
    config = compiler_config(device())
    job = CompilerJob(source, config)
    interp = GPUCompiler.get_interpreter(job)
    @static if VERSION >= v"1.11"
        return Base.infer_return_type(func, tt; interp)
    else
        sig = Base.signature_type(func, tt)
        return Core.Compiler._return_type(interp, sig)
    end
end
