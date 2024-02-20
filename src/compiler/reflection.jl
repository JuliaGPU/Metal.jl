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
    if macos_version() < v"13"
        error("Native code reflection is only supported on OSX 13 or higher")
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
        binary = joinpath(dir, "kernel.macho")
        write(binary, bin)

        # disassemble the main function
        first = true
        i = 0
        extract_gpu_code(binary) do name, code
            # skip all-zero functions
            all(code .== 0) && return

            i += 1
            file = joinpath(dir, "function$(i).bin")
            write(file, code)

            # disassemble the function
            first || println(io)
            println(io, "$name:")
            print(io, disassemble(file))

            first = false
        end
    end

end

@enum GPUMachineType::UInt32 begin
    AppleGPU = 0x1000013
    AMDGPU   = 0x1000014
    IntelGPU = 0x1000015
    AIR64    = 0x1000017
end

function extract_gpu_code(f, binary)
    fat_handle = readmeta(open(binary))
    fat_handle isa FatMachOHandle || error("Expected a universal binary, got a $(typeof(fat_handle))")

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
    native_handle = only(readmeta(IOBuffer(compute_binary)))

    # the start of the section should also alias with a symbol in the universal binary,
    # which we can use to identify the name of the kernel
    compute_symbol = nothing
    for symbol in Symbols(fat_handle[arch])
        symbol_value(symbol) == section_offset(compute_section) || continue
        endswith(symbol_name(symbol), "_begin") || continue
        compute_symbol = symbol
    end
    compute_symbol === nothing && error("Could not find symbol for __compute section")
    kernel_name = symbol_name(compute_symbol)[1:end-6]

    # within the native GPU binary, isolate the section containing code
    section = findfirst(Sections(native_handle), "__TEXT,__text")
    isnothing(section) && error("Could not find __TEXT,__text section")

    # get all symbols, and sort them by address
    symbols = sort(collect(Symbols(native_handle)), by=symbol_value)

    # extract relevant functions
    code = read(section)
    function extract_function(fn)
        # find the symbol
        symbol = findfirst(isequal(fn) , symbols)
        symbol ===  nothing && return nothing
        offset = symbol_value(symbols[symbol])

        # extract the function
        size = if symbol < length(symbols)
            # up until the next symbol
            symbol_value(symbols[symbol + 1])
        else
            # up until the end of the section
            section_size(section)
        end - offset
        return code[offset + 1 : offset + size]
    end
    for sym in symbols
        f("$kernel_name.$(symbol_name(sym))", extract_function(sym))
    end
    return
end

function disassemble(path)
    io = IOBuffer()
    disassembler = joinpath(only(readdir(artifact"applegpu"; join=true)), "disassemble.py")
    run(pipeline(`$(python()) $disassembler $path`, stdout=io))
    return String(take!(io))
end

code_agx(@nospecialize(func), @nospecialize(types); kwargs...) =
    code_agx(stdout, func, types; kwargs...)

const code_native = code_agx

# forward the rest to GPUCompiler with an appropriate CompilerJob
for method in (:code_typed, :code_warntype, :code_llvm)
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
       @device_code_llvm, @device_code_native, @device_code_agx, @device_code

"""
    @device_code_agx [io::IO=stdout, ...] ex

Evaluates the expression `ex` and prints the result of [`Metal.code_agx`](@ref) to
`io` for every compiled Metal kernel. For other supported keywords, see
[`Metal.code_agx`](@ref).
"""
macro device_code_agx(ex...)
    function hook(job::MetalCompilerJob; io::IO=stdout, kwargs...)
        println(io, "; $job")
        println(io)
        code_agx(io, job; kwargs...)
    end
    GPUCompiler.emit_hooked_compilation(hook, ex...)
end

const var"@device_code_native" = var"@device_code_agx"

# forward to GPUCompiler
@eval $(Symbol("@device_code_lowered")) = $(getfield(GPUCompiler, Symbol("@device_code_lowered")))
@eval $(Symbol("@device_code_typed")) = $(getfield(GPUCompiler, Symbol("@device_code_typed")))
@eval $(Symbol("@device_code_warntype")) = $(getfield(GPUCompiler, Symbol("@device_code_warntype")))
@eval $(Symbol("@device_code_llvm")) = $(getfield(GPUCompiler, Symbol("@device_code_llvm")))
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
    sig = Base.signature_type(func, tt)
    Core.Compiler.return_type(interp, sig)
end
