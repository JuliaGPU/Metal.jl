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

"""
    code_agx([io], f, types, cap::VersionNumber)

Prints the AGX code generated for the method matching the given generic function and type
signature to `io` which defaults to `stdout`.

See also: [`@device_code_agx`](@ref)
"""
function code_agx(io::IO, @nospecialize(func), @nospecialize(types),
                  kernel::Bool=true; kwargs...)
    compiler_kwargs, kwargs = split_kwargs_runtime(kwargs, COMPILER_KWARGS)
    source = methodinstance(typeof(func), Base.to_tuple_type(types))
    config = compiler_config(current_device(); kernel, compiler_kwargs...)
    job = CompilerJob(source, config)
    code_agx(io, job)
end

function code_agx(io::IO, job::MetalCompilerJob)
    if !job.config.kernel
        error("Can only generate AGX code for kernel functions")
    end

    # compile the kernel
    compiled = compile(job)
    pipeline, fun = link(job, compiled; return_function=true)
    # XXX: can we re-use this pipeline?

    # register it with a pipeline descriptor
    pipeline_desc = MTLComputePipelineDescriptor()
    pipeline_desc.computeFunction = fun

    # create a binary archive
    bin_desc = MTLBinaryArchiveDescriptor()
    bin = MTLBinaryArchive(current_device(), bin_desc)
    add_functions!(bin, pipeline_desc)

    code = mktempdir() do dir
        # serialize the archive to a file
        binary = joinpath(dir, "kernel")
        write(binary, bin)

        # disassemble the main function
        main = joinpath(dir, "main.bin")
        write(main, extract_gpu_code(binary))
        disassemble(io, main)
    end

end

@enum GPUMachineType::UInt32 begin
    AppleGPU = 0x1000013
    AMDGPU   = 0x1000014
    IntelGPU = 0x1000015
    AIR64    = 0x1000017
end

function extract_gpu_code(binary)
    fat_handle = readmeta(open(binary))
    fat_handle isa FatMachOHandle || error("Expected a universal binary")

    # the universal binary contains several architectures; extract the GPU one
    arch = findfirst(fat_handle) do arch
        arch.header isa MachO.MachOHeader64 && GPUMachineType(arch.header.cputype) == AppleGPU
    end
    arch == nothing && error("Could not find GPU architecture in universal binary")

    # the GPU binary contains several sections (metallib, descriptor, reflection, compute?,
    # fragment?, vertex?); extract the compute section, which is another Mach-O binary
    compute_section = findfirst(Sections(fat_handle[arch]), "__TEXT,__compute")
    compute_section === nothing && error("Could not find __compute section in GPU binary")
    compute_binary = read(compute_section)
    native_handle = readmeta(IOBuffer(compute_binary))

    # within the native GPU binary, isolate the section containing code
    section = findfirst(Sections(native_handle), "__TEXT,__text")
    isnothing(section) && error("Could not find __TEXT,__text section")

    function extract_function(handle, section, code, fn)
        # find the symbol
        symbol = findfirst(Symbols(handle), fn)
        symbol ===  nothing && return nothing

        # read the section
        code = read(section)

        # extract the function
        size = if symbol_number(symbol) < length(Symbols(handle))
            # up until the next symbol
            symbol_value(Symbols(handle)[symbol_number(symbol) + 1])
        else
            # up until the end of the section
            section_size(section)
        end - symbol_value(symbol)
        return code[symbol_value(symbol) + 1 : symbol_value(symbol) + size]
    end

    # extract relevant functions
    code = read(section)
    prolog_code = extract_function(native_handle, section, code, "_agc.main.constant_program")
    if prolog_code !== nothing
        # XXX: what to do with the kernel prologue?
    end
    main_code = extract_function(native_handle, section, code, "_agc.main")
    main_code === nothing && error("Could not find main function")
    return main_code
end

function disassemble(io::IO, path)
    disassembler = joinpath(only(readdir(artifact"applegpu"; join=true)), "disassemble.py")
    python() do python_path
        run(pipeline(`$python_path $disassembler $path`, stdout=io))
    end
    return
end

code_agx(@nospecialize(func), @nospecialize(types); kwargs...) =
    code_agx(stdout, func, types; kwargs...)

# forward the rest to GPUCompiler with an appropriate CompilerJob
for method in (:code_typed, :code_warntype, :code_llvm, :code_native)
    # only code_typed doesn't take a io argument
    args = method === :code_typed ? (:job,) : (:io, :job)

    @eval begin
        function $method(io::IO, @nospecialize(func), @nospecialize(types);
                         kernel::Bool=false, kwargs...)
            compiler_kwargs, kwargs = split_kwargs_runtime(kwargs, COMPILER_KWARGS)
            source = methodinstance(typeof(func), Base.to_tuple_type(types))
            config = compiler_config(current_device(); kernel, compiler_kwargs...)
            job = CompilerJob(source, config)
            GPUCompiler.$method($(args...); kwargs...)
        end
        $method(@nospecialize(func), @nospecialize(types); kwargs...) =
            $method(stdout, func, types; kwargs...)
    end
end


#
# @device_code_* functions
#

export @device_code_lowered, @device_code_typed, @device_code_warntype,
       @device_code_llvm, @device_code_air, @device_code_agx, @device_code

"""
    @device_code_agx [io::IO=stdout, ...] ex

Evaluates the expression `ex` and prints the result of [`CUDA.code_agx`](@ref) to
`io` for every compiled Metal kernel. For other supported keywords, see
[`CUDA.code_agx`](@ref).
"""
macro device_code_agx(ex...)
    function hook(job::MetalCompilerJob; io::IO=stdout, kwargs...)
        println(io, "; $job")
        println(io)
        code_agx(io, job; kwargs...)
    end
    GPUCompiler.emit_hooked_compilation(hook, ex...)
end

# forward to GPUCompiler
@eval $(Symbol("@device_code_lowered")) = $(getfield(GPUCompiler, Symbol("@device_code_lowered")))
@eval $(Symbol("@device_code_typed")) = $(getfield(GPUCompiler, Symbol("@device_code_typed")))
@eval $(Symbol("@device_code_warntype")) = $(getfield(GPUCompiler, Symbol("@device_code_warntype")))
@eval $(Symbol("@device_code_llvm")) = $(getfield(GPUCompiler, Symbol("@device_code_llvm")))
@eval $(Symbol("@device_code_air")) = $(getfield(GPUCompiler, Symbol("@device_code_native")))
@eval $(Symbol("@device_code")) = $(getfield(GPUCompiler, Symbol("@device_code")))


#
# other
#

"""
    Metal.return_type(f, tt) -> r::Type

Return a type `r` such that `f(args...)::r` where `args::tt`.
"""
function return_type(@nospecialize(func), @nospecialize(tt))
    source = methodinstance(typeof(func), tt)
    config = compiler_config(current_device())
    job = CompilerJob(source, config)
    interp = GPUCompiler.get_interpreter(job)
    if VERSION >= v"1.8-"
        sig = Base.signature_type(func, tt)
        Core.Compiler.return_type(interp, sig)
    else
        Core.Compiler.return_type(interp, func, tt)
    end
end
