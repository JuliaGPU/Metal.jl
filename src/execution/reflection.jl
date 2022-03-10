# code reflection entry-points

# forward the rest to GPUCompiler with an appropriate CompilerJob
for method in (:code_typed, :code_warntype, :code_llvm, :code_native)
    # only code_typed doesn't take a io argument
    args = method == :code_typed ? (:job,) : (:io, :job)

    @eval begin
        function $method(io::IO, @nospecialize(func), @nospecialize(types);
                         kernel::Bool=false, minthreads=nothing, maxthreads=nothing,
                         blocks_per_sm=nothing, maxregs=nothing, kwargs...)
            source = FunctionSpec(func, Base.to_tuple_type(types), kernel)
            # target = CUDACompilerTarget(device(); minthreads, maxthreads, blocks_per_sm, maxregs)
            target = MetalCompilerTarget(macos=get_macos_v();)
            params = MetalCompilerParams()
            job = CompilerJob(target, source, params)
            GPUCompiler.$method($(args...); kwargs...)
        end
        $method(@nospecialize(func), @nospecialize(types); kwargs...) =
            $method(stdout, func, types; kwargs...)
    end
end

"""
    Metal.return_type(f, tt) -> r::Type

Return a type `r` such that `f(args...)::r` where `args::tt`.
"""
function return_type(@nospecialize(func), @nospecialize(tt))
    source = FunctionSpec(func, tt, true)
    target = MetalCompilerTarget(macos=get_macos_v();)
    params = MetalCompilerParams()
    job = CompilerJob(target, source, params)
    interp = GPUCompiler.get_interpreter(job)
    if VERSION >= v"1.8-"
        sig = Base.signature_type(job.source.f, job.source.tt)
        Core.Compiler.return_type(interp, sig)
    else
        Core.Compiler.return_type(interp, job.source.f, job.source.tt)
    end
end

"""
    code_metallib([io], f, types)

Writes the Metal library code generated for the method matching the given generic function and type
signature to a file.

The following keyword arguments are supported:

- `kernel`: treat the function as an entry-point kernel
- `filename`: the file to write the metal library to

See also: [`@device_code_metallib`](@ref)
"""
function code_metallib(io::IO, @nospecialize(func), @nospecialize(types), kernel::Bool=true;
                   filename::String="", kwargs...)
    tt = Base.to_tuple_type(types)
    source = FunctionSpec(f, tt, true, name)
    target = MetalCompilerTarget(macos=get_macos_v(); kwargs...)
    params = MetalCompilerParams()
    job = CompilerJob(target, source, params)
    code_metallib(io, job; filename=filename)
end

function code_metallib(io::IO, job::CompilerJob{MetalCompilerTarget}; filename::String="")
    if !job.source.kernel
        error("Can only generate a Metal library for kernel functions")
    end
    
    compiled = mtlfunction_compile(job)
    if filename == ""
       filename = tempname() * ".metallib" 
    end

    open(filename, "w") do file
        write(file, compiled.image)
    end
    println(io, "Metal library saved to $filename")
end

code_metallib(@nospecialize(func), @nospecialize(types); kwargs...) =
    code_metallib(stdout, func, types; kwargs...)

"""
    @device_code_metallib [io::IO=stdout, ...] ex

Evaluates the expression `ex` and writes the result of [`Metal.code_metallib`](@ref) to
a file for every compiled Metal kernel. For other supported keywords, see
[`Metal.code_metallib`](@ref).
"""
macro device_code_metallib(ex...)
    function hook(job::CompilerJob{MetalCompilerTarget}; io::IO=stdout, kwargs...)
        println(io, "// $job")
        println(io)
        code_metallib(io, job; kwargs...)
    end
    GPUCompiler.emit_hooked_compilation(hook, ex...)
end

#
# @device_code_* functions
#

export @device_code_lowered, @device_code_typed, @device_code_warntype,
       @device_code_llvm, @device_code_metallib, @device_code


# forward the rest to GPUCompiler
@eval $(Symbol("@device_code_lowered")) = $(getfield(GPUCompiler, Symbol("@device_code_lowered")))
@eval $(Symbol("@device_code_typed")) = $(getfield(GPUCompiler, Symbol("@device_code_typed")))
@eval $(Symbol("@device_code_warntype")) = $(getfield(GPUCompiler, Symbol("@device_code_warntype")))
@eval $(Symbol("@device_code_llvm")) = $(getfield(GPUCompiler, Symbol("@device_code_llvm")))
@eval $(Symbol("@device_code")) = $(getfield(GPUCompiler, Symbol("@device_code")))
