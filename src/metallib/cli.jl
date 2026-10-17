# command-line interface to Metal libraries
#
# `main` implements every command; the Pkg app (see `[apps]` in Project.toml) and the scripts
# in `bin/` are thin wrappers around it, so that it can also be called in-process (e.g. from
# the tests) with its output going to arbitrary streams.

module MetalLibCLI

using ..Metal
using ..Metal: MetalLib, MetalLibFunction, MetalLibFormatError, TagGroup, RawTag
using UUIDs: UUID
using CEnum: CEnum
using LLVM, LLVM.IR
using ..MTL
using ..MTL.ObjectiveC: @objc, id, Out
using ..MTL.ObjectiveC.Foundation: NSError
using SHA: sha256

const program = "metallib"

# version of the JSON output format; bumped on incompatible changes
const schema = "metal.jl/metallib-cli/1"


## errors and diagnostics

# a problem with how the command was invoked
struct UsageError <: Exception
    msg::String
end

# a problem the command ran into; reported as a diagnostic
struct CommandError <: Exception
    msg::String
    offset::Union{Nothing,Int}
end
CommandError(msg) = CommandError(msg, nothing)

struct Diagnostic
    severity::String    # "error", "warning" or "note"
    message::String
    offset::Union{Nothing,Int}
end

# the state of one invocation of `main`
Base.@kwdef mutable struct Context
    io::IO
    err::IO
    input::IO
    json::Bool = false
    diagnostics::Vector{Diagnostic} = Diagnostic[]
end

function diagnose!(ctx::Context, severity, message; offset=nothing)
    push!(ctx.diagnostics, Diagnostic(severity, message, offset))
    ctx.json || println(ctx.err, "$program: $severity: $message",
                        offset === nothing ? "" : " (at offset $offset)")
    return
end


## JSON output
#
# NamedTuples and vectors of pairs become objects (keeping their order), enums become
# `{"name": ..., "value": ...}`, and integers are written as numbers (also 64-bit ones, which
# JavaScript consumers would read as doubles).

json(io::IO, x; indent=0) = json_value(io, x, indent)

function json_value(io::IO, ::Nothing, indent)
    print(io, "null")
end
json_value(io::IO, x::Bool, indent) = print(io, x ? "true" : "false")
json_value(io::IO, x::Integer, indent) = print(io, x)
function json_value(io::IO, x::AbstractFloat, indent)
    isfinite(x) || throw(ArgumentError("cannot represent $x in JSON"))
    print(io, x)
end
json_value(io::IO, x::Union{VersionNumber,Symbol}, indent) =
    json_value(io, string(x), indent)
# (spelled like Apple's tools do)
json_value(io::IO, x::UUID, indent) = json_value(io, uppercase(string(x)), indent)
json_value(io::IO, x::CEnum.Cenum, indent) =
    json_value(io, (; name=string(x), value=Integer(x)), indent)
function json_value(io::IO, x::AbstractString, indent)
    print(io, '"')
    for c in x
        if c == '"'
            print(io, "\\\"")
        elseif c == '\\'
            print(io, "\\\\")
        elseif c == '\n'
            print(io, "\\n")
        elseif c == '\r'
            print(io, "\\r")
        elseif c == '\t'
            print(io, "\\t")
        elseif c < ' ' || !isvalid(c)
            for unit in transcode(UInt16, string(isvalid(c) ? c : '�'))
                print(io, "\\u", string(unit, base=16, pad=4))
            end
        else
            print(io, c)
        end
    end
    print(io, '"')
end
json_value(io::IO, x::NamedTuple, indent) = json_object(io, pairs(x), indent)
json_value(io::IO, x::AbstractVector{<:Pair}, indent) = json_object(io, x, indent)
function json_value(io::IO, x::Union{AbstractVector,Tuple}, indent)
    if isempty(x)
        print(io, "[]")
        return
    end
    println(io, "[")
    for (i, value) in enumerate(x)
        print(io, " "^(indent+2))
        json_value(io, value, indent+2)
        println(io, i == length(x) ? "" : ",")
    end
    print(io, " "^indent, "]")
end
function json_object(io::IO, entries, indent)
    if isempty(entries)
        print(io, "{}")
        return
    end
    println(io, "{")
    for (i, (key, value)) in enumerate(entries)
        print(io, " "^(indent+2))
        json_value(io, string(key), indent+2)
        print(io, ": ")
        json_value(io, value, indent+2)
        println(io, i == length(entries) ? "" : ",")
    end
    print(io, " "^indent, "}")
end


## argument parsing

struct Arguments
    flags::Set{String}
    options::Dict{String,String}
    positionals::Vector{String}
end

# split `args` into flags, options taking a value, and positional arguments. `-` on its own
# is a positional argument (standard input or output), and `--` ends option parsing.
function parse_arguments(args::Vector{String}; flags=String[], options=String[])
    parsed = Arguments(Set{String}(), Dict{String,String}(), String[])
    args = copy(args)
    while !isempty(args)
        arg = popfirst!(args)
        if arg == "--"
            append!(parsed.positionals, args)
            break
        elseif startswith(arg, "-") && arg != "-"
            name, value = if startswith(arg, "--") && contains(arg, '=')
                split(arg, '='; limit=2)
            else
                arg, nothing
            end
            if name in flags && value === nothing
                push!(parsed.flags, name)
            elseif name in options
                if value === nothing
                    isempty(args) && throw(UsageError("option $name needs a value"))
                    value = popfirst!(args)
                end
                parsed.options[name] = value
            else
                throw(UsageError("unknown option $arg"))
            end
        else
            push!(parsed.positionals, arg)
        end
    end
    return parsed
end


## commands

struct Command
    summary::String     # one line, for the overview
    help::String        # usage, description, options and an example
    flags::Vector{String}
    options::Vector{String}
    run::Function       # (ctx, args::Arguments) -> result; throws CommandError
    text::Function      # (io, result) -> nothing; the human-readable output
end

const commands = Dict{String,Command}()
const command_order = String[]

function register!(name, cmd)
    commands[name] = cmd
    push!(command_order, name)
    return
end

# options every command accepts
const common_flags = ["--json", "-h", "--help"]

const common_options_help = """
    Common options:
      --json        Write the result to standard output as JSON (see `metallib --help`).
      -h, --help    Show this help."""

function overview()
    io = IOBuffer()
    println(io, """
        $program: inspect, edit, assemble and load Metal libraries (.metallib files).

        Usage: $program <command> [options] [arguments]

        Commands:""")
    width = maximum(length, command_order)
    for name in command_order
        println(io, "  ", rpad(name, width + 2), commands[name].summary)
    end
    print(io, """

        Run `$program <command> --help` for the options and an example of each command.

        Every command accepts `--json`, which writes one JSON document to standard output
        and nothing else, also when the command fails or is invoked incorrectly
        (diagnostics are part of the document instead of being written to standard
        error). The document is an object with these keys, in this order:
          "schema"       always "$schema"
          "command"      the command that ran
          "status"       "ok", "partial" (the command did not handle everything; see the
                         diagnostics), "unsupported" or "error"
          "result"       the command's result, or null on error
          "diagnostics"  a list of {"severity", "message", "offset"} objects, where offset
                         is a position in the input library, or null
        Enumerations are written as {"name", "value"} objects, byte strings as hexadecimal
        strings, and 64-bit integers as plain numbers.

        Exit codes: 0 on success (status ok or partial), 1 when the command failed or is
        unsupported, 2 when it was invoked incorrectly.
        """)
    return String(take!(io))
end

"""
    MetalLibCLI.main(args::Vector{String}; io=stdout, err=stderr, input=stdin)::Int

Run the `metallib` command-line tool with arguments `args`, writing results to `io` and
diagnostics to `err`, and reading standard input (`-`) from `input`. Returns the exit code.
"""
function main(args::Vector{String}; io::IO=stdout, err::IO=stderr, input::IO=stdin)
    if isempty(args) || args[1] in ("-h", "--help", "help") && length(args) == 1
        print(isempty(args) ? err : io, overview())
        return isempty(args) ? 2 : 0
    end
    if args[1] == "help" && length(args) == 2 && haskey(commands, args[2])
        print(io, commands[args[2]].help, "\n\n", common_options_help, "\n")
        return 0
    end

    name = args[1]
    options = haskey(commands, name) ? commands[name].options : String[]
    ctx = Context(; io, err, input, json = wants_json(args[2:end], options))
    if !haskey(commands, name)
        return usage_error(ctx, name, nothing,
                           "unknown command '$name'; run `$program --help` for a list")
    end
    cmd = commands[name]

    parsed = try
        parse_arguments(args[2:end]; flags=[common_flags; cmd.flags], options=cmd.options)
    catch e
        e isa UsageError || rethrow()
        return usage_error(ctx, name, cmd, e.msg)
    end
    ctx.json = "--json" in parsed.flags
    if "-h" in parsed.flags || "--help" in parsed.flags
        print(io, cmd.help, "\n\n", common_options_help, "\n")
        return 0
    end

    status, result = try
        result = cmd.run(ctx, parsed)
        status = if any(d -> d.severity == "error", ctx.diagnostics)
            "error"
        elseif result isa Tuple{Symbol,Any}
            # commands can qualify their result as (:partial, result) etc.
            string(result[1])
        else
            "ok"
        end
        status, result isa Tuple{Symbol,Any} ? result[2] : result
    catch e
        if e isa UsageError
            return usage_error(ctx, name, cmd, e.msg)
        elseif e isa CommandError
            diagnose!(ctx, "error", e.msg; e.offset)
        elseif e isa MetalLibFormatError
            diagnose!(ctx, "error", "invalid Metal library: $(e.msg)"; e.offset)
        elseif e isa LLVM.LLVMException
            diagnose!(ctx, "error", "LLVM error: $(e.info)")
        elseif e isa SystemError || e isa Base.IOError && e.code != Base.UV_EPIPE
            diagnose!(ctx, "error", sprint(showerror, e))
        else
            rethrow()
        end
        "error", nothing
    end

    if ctx.json
        write_document(ctx, name, status, result)
    elseif result !== nothing
        cmd.text(io, result)
    end
    return status in ("ok", "partial") ? 0 : 1
end

# whether the arguments include --json, for reporting errors before (or while) they are
# parsed: skips the values of options, and stops where option parsing ends
function wants_json(args, options)
    i = 1
    while i <= length(args)
        args[i] == "--" && return false
        args[i] == "--json" && return true
        i += args[i] in options ? 2 : 1
    end
    return false
end

function write_document(ctx::Context, command, status, result)
    json(ctx.io, (; schema, command, status, result,
                    diagnostics=[(; d.severity, d.message, d.offset)
                                 for d in ctx.diagnostics]))
    println(ctx.io)
end

# report that the tool was invoked incorrectly; with --json also as a document, so that
# programs reading the output can rely on getting one
function usage_error(ctx::Context, name, cmd, msg)
    if ctx.json
        diagnose!(ctx, "error", msg)
        write_document(ctx, name, "error", nothing)
    else
        println(ctx.err, "$program $name: $msg")
        cmd === nothing || println(ctx.err, "\n", cmd.help)
    end
    return 2
end


## helpers

# read the input, a path or `-` for standard input, as bytes
function read_input(ctx::Context, path::AbstractString)
    if path == "-"
        return read(ctx.input)
    else
        isfile(path) || throw(CommandError("no such file: $path"))
        return read(path)
    end
end

read_library(ctx::Context, path::AbstractString) =
    read(IOBuffer(read_input(ctx, path)), MetalLib)

function only_positional(args::Arguments, what)
    length(args.positionals) == 1 || throw(UsageError("expected one $what"))
    return args.positionals[1]
end

# the tags of a library that we kept as raw bytes, as they appear in its tag groups
function raw_tags(lib::MetalLib)
    groups = TagGroup[]
    if lib.layout !== nothing
        for tg in (lib.layout.header_extension, lib.layout.dynamic_header)
            tg === nothing || push!(groups, tg)
        end
        append!(groups, lib.layout.script_tags, lib.layout.source_tags)
    end
    for fun in lib.functions
        layout = fun.layout
        layout === nothing && continue
        append!(groups, [layout.function_tags, layout.public_tags, layout.private_tags])
        layout.reflection_tags === nothing || push!(groups, layout.reflection_tags)
    end
    tags = String[]
    for tg in groups, (tag, value) in tg.data
        value isa RawTag && !(tag in tags) && push!(tags, tag)
    end
    sort!(tags)
end


## info

function function_info(fun::MetalLibFunction)
    return (; fun.name, fun.type,
              air_version = fun.air_version, metal_version = fun.metal_version,
              module_size = sizeof(fun.air_module),
              constants = [(; c.name, type=c.datatype, c.index, c.required)
                           for c in fun.constants],
              debug_info = fun.debug_info === nothing ? nothing :
                           (; fun.debug_info.line, fun.debug_info.path),
              dependencies = fun.dependencies,
              source = fun.source_id,
              reflection_size = fun.reflection_data === nothing ? nothing :
                                sizeof(fun.reflection_data))
end

function info(ctx::Context, args::Arguments)
    path = only_positional(args, "input file")
    bytes = read_input(ctx, path)
    lib = read(IOBuffer(bytes), MetalLib)
    undecoded = raw_tags(lib)
    if !isempty(undecoded)
        diagnose!(ctx, "note", "tags that are kept but not decoded: $(join(undecoded, ", "))")
    end
    source = lib.embedded_source
    return (; file = path, size = sizeof(bytes),
              version = lib.file_version, type = lib.file_type,
              macos = lib.is_macos, stub = lib.is_stub,
              platform = lib.platform_type, platform_version = lib.platform_version,
              is_64bit = lib.is_64bit, uuid = lib.uuid, install_name = lib.library_name,
              functions = map(function_info, lib.functions),
              embedded_source = source === nothing ? nothing :
                  (; source.link_options, source.working_directory,
                     archives = [(; id, size=sizeof(archive))
                                 for (id, archive) in source.archives]),
              scripts = length(lib.scripts),
              undecoded_tags = undecoded)
end

function info_text(io::IO, r)
    println(io, "$(r.file): Metal library v$(r.version), $(r.type)",
            r.macos ? ", macOS" : "", r.stub ? ", stub" : "")
    println(io, "  platform:  $(r.platform) v$(r.platform_version)",
            r.is_64bit ? ", 64-bit" : "")
    r.uuid === nothing || println(io, "  UUID:      ", uppercase(string(r.uuid)))
    r.install_name === nothing || println(io, "  name:      ", r.install_name)
    r.embedded_source === nothing ||
        println(io, "  sources:   $(length(r.embedded_source.archives)) embedded archive(s)")
    r.scripts == 0 || println(io, "  scripts:   $(r.scripts) pipeline script(s)")
    println(io, "  functions: $(length(r.functions))")
    for fun in r.functions
        features = String[]
        isempty(fun.constants) || push!(features, "$(length(fun.constants)) constants")
        fun.debug_info === nothing ||
            push!(features, "debug info $(fun.debug_info.path):$(fun.debug_info.line)")
        fun.reflection_size === nothing || push!(features, "reflection")
        fun.source === nothing || push!(features, "source $(fun.source)")
        println(io, "    $(fun.name): $(fun.type), AIR v$(fun.air_version), ",
                "Metal v$(fun.metal_version), $(fun.module_size)-byte module",
                isempty(features) ? "" : " [$(join(features, ", "))]")
    end
end

register!("info", Command(
    "Summarize a library: versions, platform and functions.",
    """
    Usage: $program info [--json] FILE

    Summarize the library in FILE (`-` for standard input): its file format version and
    type, target platform, UUID, embedded sources and scripts, and for every function its
    type, AIR and Metal versions, module size, function constants, debug info and whether
    it has reflection data.

    Example:
      $program info --json shaders.metallib""",
    String[], String[], info, info_text))


## dis

# LLVM bitcode, plain or in the wrapper Apple's toolchain uses
is_bitcode(data) = length(data) >= 4 && (data[1:4] == [0x42, 0x43, 0xc0, 0xde] ||
                                         data[1:4] == [0xde, 0xc0, 0x17, 0x0b])

# open an output file, refusing to overwrite one unless forced
function write_output(ctx::Context, path::AbstractString, data; force::Bool)
    if path == "-"
        ctx.json && throw(UsageError("cannot write the output to standard output with --json"))
        write(ctx.io, data)
    else
        !force && ispath(path) &&
            throw(CommandError("$path already exists; use -f to overwrite it"))
        write(path, data)
    end
    return
end

function dis(ctx::Context, args::Arguments)
    1 <= length(args.positionals) <= 2 || throw(UsageError("expected FILE [FUNCTION]"))
    input = args.positionals[1]
    lib = read_library(ctx, input)
    output = get(args.options, "-o", nothing)
    text = "-S" in args.flags ||
           output !== nothing && (endswith(output, ".ll") ||
                                  output == "-" && ctx.io isa Base.TTY)

    isempty(lib.functions) && throw(CommandError("the library has no functions"))
    fun = if length(args.positionals) == 2
        name = args.positionals[2]
        i = findfirst(fun -> fun.name == name, lib.functions)
        i === nothing && throw(CommandError("no function named $name; the library has " *
                                            join([f.name for f in lib.functions], ", ")))
        lib.functions[i]
    elseif length(lib.functions) == 1
        only(lib.functions)
    else
        throw(CommandError("the library has several functions; name one of " *
                           join([f.name for f in lib.functions], ", ")))
    end

    if output === nothing
        input == "-" && throw(UsageError("reading standard input requires -o"))
        output = splitext(input)[1] * (text ? ".ll" : ".bc")
    end
    data = if text
        is_bitcode(fun.air_module) ||
            throw(CommandError("the module of $(fun.name) is not plain LLVM bitcode " *
                               "(it may be compressed); disassemble it without -S"))
        @dispose llvm=LLVM.Context() mod=parse(LLVM.Module, fun.air_module) begin
            string(mod)
        end
    else
        fun.air_module
    end
    write_output(ctx, output, data; force = "-f" in args.flags)

    return (; function_name = fun.name, output, format = text ? "text" : "bitcode",
              size = sizeof(data))
end

dis_text(io::IO, r) = r.output == "-" ||
    println(io, "wrote the $(r.format == "text" ? "IR" : "bitcode") of $(r.function_name) ",
            "to $(r.output)")

register!("dis", Command(
    "Extract a function's AIR module as LLVM bitcode or IR.",
    """
    Usage: $program dis [-S] [-f] [-o OUTPUT] FILE [FUNCTION]

    Extract the AIR module (LLVM bitcode) of a function from the library in FILE (`-` for
    standard input). FUNCTION can be left out when the library has only one function.

    Options:
      -S            Disassemble the module into textual LLVM IR. This is the default when
                    OUTPUT ends in `.ll`, or is `-` and standard output is a terminal.
      -o OUTPUT     Write to OUTPUT (`-` for standard output) instead of to FILE with its
                    extension replaced by `.bc` or `.ll`.
      -f            Overwrite OUTPUT if it exists.

    Example:
      $program dis -S -o kernel.ll shaders.metallib my_kernel""",
    ["-S", "-f"], ["-o"], dis, dis_text))


## as

function as(ctx::Context, args::Arguments)
    inputs = args.positionals
    isempty(inputs) && throw(UsageError("expected at least one input"))
    count(==("-"), inputs) <= 1 || throw(UsageError("can only read standard input once"))
    output = get(args.options, "-o", nothing)
    if output === nothing
        length(inputs) == 1 && inputs[1] != "-" ||
            throw(UsageError("specify the output with -o"))
        output = replace(basename(inputs[1]), r"\..*$" => "") * ".metallib"
    end
    output == "-" && ctx.io isa Base.TTY &&
        throw(CommandError("refusing to write a binary library to a terminal"))

    lib_functions = MetalLibFunction[]
    @dispose llvm=LLVM.Context() begin
        for input in inputs
            data = read_input(ctx, input)
            bitcode = is_bitcode(data)
            try
                @dispose mod=parse(LLVM.Module, bitcode ? data : String(data)) begin
                    entries = filter(collect(mod.functions)) do f
                        !isdeclaration(f) && f.linkage == LLVM.Linkage.External
                    end
                    isempty(entries) && throw(CommandError("no external function in $input"))
                    length(entries) == 1 ||
                        throw(CommandError("several external functions in $input: " *
                                           join([f.name for f in entries], ", ")))
                    try
                        verify(mod)
                    catch e
                        e isa LLVM.LLVMException || rethrow()
                        throw(CommandError("$input is not valid LLVM IR: $(e.info)"))
                    end
                    name = LLVM.name(entries[1])

                    # Metal reads bitcode of the LLVM version it is based on; downgrade the
                    # rest (the downgrader consumes bitcode, so re-emit the module as such)
                    air_module = if bitcode && !("-d" in args.flags)
                        data
                    else
                        Metal.GPUCompiler.downgrade(sprint(write, mod) |> codeunits |> collect,
                                                    v"14.0")
                    end

                    # describe the function from the module's metadata, like Apple's linker
                    versions = Pair{Symbol,VersionNumber}[]
                    for (md, field, default) in (("air.version", :air_version, Metal.air_support()),
                                                 ("air.language_version", :metal_version,
                                                  Metal.metal_support()))
                        haskey(mod.metadata, md) && continue
                        diagnose!(ctx, "warning", "$input has no $md metadata; assuming " *
                                  "v$default, what this system supports")
                        push!(versions, field => default)
                    end
                    fun = MetalLibFunction(mod, name; air_module, versions...)
                    fun.type == Metal.METALLIB_UNQUALIFIED_FUNCTION &&
                        diagnose!(ctx, "note", "$name is not listed as an entry point (e.g. " *
                                  "in air.kernel), so the library describes it as a plain function")
                    push!(lib_functions, fun)
                end
            catch e
                e isa LLVM.LLVMException || rethrow()
                throw(CommandError("could not parse $input as LLVM IR: $(e.info)"))
            end
        end
    end

    lib = MetalLib(; functions = lib_functions)
    data = sprint(write, lib) |> codeunits |> collect
    write_output(ctx, output, data; force = "-f" in args.flags)
    return (; output, size = sizeof(data),
              functions = [(; f.name, input, module_size = sizeof(f.air_module))
                           for (f, input) in zip(lib_functions, inputs)])
end

as_text(io::IO, r) = r.output == "-" ||
    println(io, "wrote $(r.output) with ", join([f.name for f in r.functions], ", "))

register!("as", Command(
    "Package LLVM IR or bitcode into a library.",
    """
    Usage: $program as [-d] [-f] [-o OUTPUT] INPUT...

    Create a library with one function per INPUT, an LLVM module in textual IR or bitcode
    (`-` for standard input) with exactly one external function, which becomes the
    function's name. Inputs are checked with the LLVM verifier. Textual IR is downgraded to the bitcode format Metal reads (that of
    LLVM 14), so IR from a newer LLVM works too; bitcode is used as is unless -d is given.
    Like Apple's linker, the tool derives each function's type, AIR and Metal versions,
    function constants and debug info from the module's metadata (`air.kernel`,
    `air.version`, ...); without version metadata, it assumes what this system supports.

    Options:
      -o OUTPUT     Write the library to OUTPUT (`-` for standard output). Defaults to the
                    name of the only INPUT, with its extension replaced by `.metallib`.
      -d            Downgrade bitcode inputs too.
      -f            Overwrite OUTPUT if it exists.

    Example:
      $program as -o kernel.metallib kernel.ll""",
    ["-d", "-f"], ["-o"], as, as_text))


## load

# view an object as one of its subclasses, to access their properties
downcast(T, obj::MTL.ObjectiveC.Object) = downcast(T, obj.ptr)
downcast(T, ptr::id) = T(reinterpret(id{T}, ptr))

# the function named `name` in `lib`, ready to create a pipeline for, or the function
# constants it needs values for. Metal aborts the process, rather than failing with an error,
# when creating a pipeline for a function with constants that was not specialized, so
# specialize functions whose constants are all optional, leaving the constants undefined.
function pipeline_function(lib::MTLLibrary, name::String)
    fun = MTL.MTLFunction(lib, name)
    dict = fun.functionConstantsDictionary
    (dict === nothing || isempty(dict)) && return fun, String[]
    constants = [downcast(MTL.MTLFunctionConstant, c) for c in values(dict)]
    required = sort!([String(c.name) for c in constants if c.required])
    isempty(required) || return nothing, required
    return MTL.MTLFunction(lib, name, MTL.MTLFunctionConstantValues()), String[]
end

function load(ctx::Context, args::Arguments)
    isempty(args.positionals) && throw(UsageError("expected FILE [FUNCTION...]"))
    input = args.positionals[1]
    data = read_input(ctx, input)
    isempty(data) && throw(CommandError("the input is empty"))
    verbose = "-v" in args.flags && !ctx.json

    dev = Metal.device()
    verbose && println(ctx.io, "using device: ", dev.name)
    lib = try
        MTL.MTLLibraryFromData(dev, data)
    catch e
        throw(CommandError("Metal failed to load the library: " * sprint(showerror, e)))
    end
    verbose && println(ctx.io, "loaded the library")

    names = length(args.positionals) > 1 ? args.positionals[2:end] :
                                           String.(lib.functionNames)
    functions = map(names) do name
        fun = try
            MTL.MTLFunction(lib, name)
        catch e
            diagnose!(ctx, "error", "the library has no function $name")
            return (; name, type = nothing, pipeline = nothing)
        end
        type = fun.functionType
        pipeline = if !("--pipeline" in args.flags)
            nothing
        elseif type != MTL.MTLFunctionTypeKernel
            # other functions, e.g. visible ones, cannot be instantiated on their own
            verbose && println(ctx.io, "skipping $type function $name")
            "skipped"
        elseif (pf = pipeline_function(lib, name); pf[1] === nothing)
            diagnose!(ctx, "note", "skipping $name, which needs values for its function " *
                      "constants $(join(pf[2], ", "))")
            "skipped"
        else
            verbose && println(ctx.io, "creating a compute pipeline for $name")
            try
                MTL.MTLComputePipelineState(dev, pf[1])
                "ok"
            catch e
                diagnose!(ctx, "error", "creating a compute pipeline for $name failed, so " *
                          "Metal could not compile it: " * sprint(showerror, e))
                "failed"
            end
        end
        (; name, type, pipeline)
    end
    return (; device = String(dev.name), functions)
end

function load_text(io::IO, r)
    for fun in r.functions
        fun.type === nothing && continue
        println(io, "$(fun.name): $(fun.type)",
                fun.pipeline === nothing ? "" : ", pipeline $(fun.pipeline)")
    end
end

register!("load", Command(
    "Load a library on the GPU, optionally compiling its kernels.",
    """
    Usage: $program load [--pipeline] [-v] FILE [FUNCTION...]

    Load the library in FILE (`-` for standard input) on the default Metal device and look up
    its functions (all of them, or the ones named). Loading only validates the container;
    with --pipeline, a compute pipeline is created for every kernel that does not need
    values for function constants, which makes Metal
    compile it to machine code, so this is where back-end compiler crashes show up. Failing
    to load the library and failing to create a pipeline are reported separately.

    Options:
      --pipeline    Create a compute pipeline for every kernel.
      -v            Report progress.

    Example:
      $program load --pipeline shaders.metallib""",
    ["--pipeline", "-v"], String[], load, load_text))


## dump

bytes2hex(data) = join(string(b, base=16, pad=2) for b in data)

# a JSON-friendly rendering of a decoded tag value; byte strings longer than 32 bytes are
# left out (their size is reported anyway, and `--raw` adds the bytes of every tag)
dump_value(x) = x
dump_value(x::Vector{UInt8}) = sizeof(x) <= 32 ? bytes2hex(x) : nothing
dump_value(x::NamedTuple) = map(dump_value, x)
dump_value(x::Vector{Metal.FunctionConstant}) =
    [(; c.name, type=c.datatype, c.index, c.required) for c in x]
dump_value(x::Metal.DebugInfo) = (; x.line, x.path)

# the tags of a group, at their positions in the library (`base` for groups that were read
# from a section on its own)
function dump_group(tg::TagGroup, label, bytes, raw::Bool; base=0)
    tags = map(enumerate(tg.data)) do (i, (tag, value))
        extent = tg.value_extents[i] .+ base
        (; tag, offset = first(extent), size = length(extent),
           decoded = !(value isa RawTag),
           value = value isa RawTag ? nothing : dump_value(value),
           raw = raw ? bytes2hex(view(bytes, extent .+ 1)) : nothing)
    end
    return (; label, offset = first(tg.extent) + base, size = length(tg.extent),
              size_includes_size_field = tg.has_size ? tg.counts_size : nothing, tags)
end

function dump(ctx::Context, args::Arguments)
    path = only_positional(args, "input file")
    bytes = read_input(ctx, path)
    lib = read(IOBuffer(bytes), MetalLib)
    raw = "--raw" in args.flags
    layout = lib.layout

    # the section table, which follows the 16 bytes of magic, versions and platform
    header = let io = IOBuffer(bytes)
        seek(io, 16)
        fields = (:file_size, :function_list_offset, :function_list_size, :public_md_offset,
                  :public_md_size, :private_md_offset, :private_md_size,
                  :module_list_offset, :module_list_size)
        NamedTuple{fields}(ntuple(_ -> Int(read(io, UInt64)), length(fields)))
    end
    funs = lib.functions
    group(f, label) = f === nothing ? nothing : dump_group(f, label, bytes, raw)

    sections = Any[]
    push!(sections, (; name = "FUNCTION_LIST", offset = header.function_list_offset,
                       size = header.function_list_size + 4,
                       groups = [group(f.layout.function_tags, "function $(i-1) ($(f.name))")
                                 for (i, f) in enumerate(funs)]))
    if layout.header_extension !== nothing
        tg = layout.header_extension
        push!(sections, (; name = "HEADER_EXTENSION", offset = first(tg.extent),
                           size = length(tg.extent), groups = [group(tg, "header extension")]))
    end
    push!(sections, (; name = "PUBLIC_METADATA", offset = header.public_md_offset,
                       size = header.public_md_size,
                       groups = [group(f.layout.public_tags, "function $(i-1) ($(f.name))")
                                 for (i, f) in enumerate(funs)]))
    push!(sections, (; name = "PRIVATE_METADATA", offset = header.private_md_offset,
                       size = header.private_md_size,
                       groups = [group(f.layout.private_tags, "function $(i-1) ($(f.name))")
                                 for (i, f) in enumerate(funs)]))
    modules = Dict{UInt64,Any}()
    for f in funs
        offset = Metal.decoded(f.layout.function_tags, "OFFT").air_module
        entry = get!(modules, offset) do
            (; offset = header.module_list_offset + offset, size = sizeof(f.air_module),
               format = is_bitcode(f.air_module) ? "bitcode" : "other",
               functions = String[])
        end
        push!(entry.functions, f.name)
    end
    push!(sections, (; name = "MODULE_LIST", offset = header.module_list_offset,
                       size = header.module_list_size,
                       modules = sort!(collect(values(modules)); by = m -> m.offset)))

    ext(tag) = Metal.decoded(layout.header_extension, tag)
    for tag in ("HSRC", "HSRD")
        section = ext(tag)
        section === nothing && continue
        push!(sections, (; name = "EMBEDDED_SOURCE", section.offset, section.size,
                           groups = [dump_group(tg, "archive $(i-1)", bytes, raw;
                                                base = section.offset)
                                     for (i, tg) in enumerate(layout.source_tags)]))
    end
    if (section = ext("HDYN")) !== nothing
        push!(sections, (; name = "DYNAMIC_HEADER", section.offset, section.size,
                           groups = [group(layout.dynamic_header, "dynamic header")]))
    end
    for (tag, name) in ("VLST" => "VARIABLE_LIST", "ILST" => "IMPORTED_SYMBOL_LIST")
        section = ext(tag)
        section === nothing && continue
        push!(sections, (; name, section.offset, section.size, decoded = false,
                           raw = raw ? bytes2hex(view(bytes, section.offset .+ (1:section.size)))
                                     : nothing))
    end
    if (section = ext("RLST")) !== nothing
        entries = unique(f.layout.reflection_tags for f in funs
                         if f.layout.reflection_tags !== nothing)
        sort!(entries; by = tg -> first(tg.extent))
        push!(sections, (; name = "REFLECTION_LIST", section.offset, section.size,
                           groups = [group(tg, "entry for " * join([f.name for f in funs
                                        if f.layout.reflection_tags === tg], ", "))
                                     for tg in entries]))
    end
    if (section = ext("SLST")) !== nothing
        push!(sections, (; name = "SCRIPT_LIST", section.offset, section.size,
                           groups = [group(tg, "script $(i-1)")
                                     for (i, tg) in enumerate(layout.script_tags)]))
    end
    sort!(sections; by = s -> s.offset)

    return (; file = path,
              header = (; offset = 0, size = 88, version = lib.file_version,
                          type = lib.file_type, macos = lib.is_macos, stub = lib.is_stub,
                          platform = lib.platform_type,
                          platform_version = lib.platform_version,
                          is_64bit = lib.is_64bit, header.file_size),
              sections)
end

hex(x) = "0x" * string(x, base=16)

# a plain rendering of a `dump_value` for the text output
text_value(x) = string(x)
text_value(x::AbstractString) = repr(x)
text_value(x::Unsigned) = string(Int(x))
text_value(x::UUID) = uppercase(string(x))
text_value(x::AbstractVector) =
    "[" * join([v isa NamedTuple ? "{$(text_value(v))}" : text_value(v) for v in x], ", ") * "]"
text_value(x::NamedTuple) =
    join(["$k=$(v === nothing ? "(not shown)" : text_value(v))" for (k, v) in pairs(x)], ", ")

function dump_text(io::IO, r)
    h = r.header
    println(io, "$(r.file): header at 0x0, $(h.size) bytes")
    println(io, "  MTLB v$(h.version), $(h.type)", h.macos ? ", macOS" : "",
            h.stub ? ", stub" : "", ", $(h.platform) v$(h.platform_version)",
            h.is_64bit ? ", 64-bit" : "", ", file size $(h.file_size)")
    for section in r.sections
        println(io, "$(section.name) at $(hex(section.offset)), $(section.size) bytes")
        if haskey(section, :groups)
            for g in section.groups
                print(io, "  $(g.label): group at $(hex(g.offset)), $(g.size) bytes")
                g.size_includes_size_field === false && print(io, " (size excludes its field)")
                println(io)
                for t in g.tags
                    value = if !t.decoded
                        "(not decoded)"
                    elseif t.value === nothing
                        "($(t.size) bytes)"
                    else
                        text_value(t.value)
                    end
                    println(io, "    ", rpad(hex(t.offset), 9), t.tag, " ", value)
                    t.raw === nothing || println(io, "             ", t.raw)
                end
            end
        elseif haskey(section, :modules)
            for m in section.modules
                println(io, "  $(m.format) module at $(hex(m.offset)), $(m.size) bytes: ",
                        join(m.functions, ", "))
            end
        else
            println(io, "  (not decoded)")
            section.raw === nothing || println(io, "  ", section.raw)
        end
    end
end

register!("dump", Command(
    "List every section and tag of a library, with offsets and values.",
    """
    Usage: $program dump [--raw] FILE

    List the header, sections, tag groups and tags of the library in FILE (`-` for standard
    input), with the offset and size of each, and the decoded value of the tags Metal.jl
    understands. Byte strings longer than 32 bytes (modules, reflection data) are not
    printed, and neither are sections and tags that are not decoded, unless --raw is given.

    Options:
      --raw         Also print the bytes of every tag value and undecoded section, in hex.

    Example:
      $program dump --json shaders.metallib""",
    ["--raw"], String[], dump, dump_text))


## reflect


# create a compute pipeline, asking Metal for the reflection of its arguments
function reflected_pipeline(dev::MTLDevice, fun::MTLFunction)
    err = Out{NSError}()
    reflection = Out{MTL.MTLComputePipelineReflection}()
    options = MTL.MTLPipelineOption(Integer(MTL.MTLPipelineOptionBindingInfo) |
                                    Integer(MTL.MTLPipelineOptionBufferTypeInfo))
    pipeline = @objc [dev::id{MTLDevice} newComputePipelineStateWithFunction:fun::id{MTLFunction}
                      options:options::MTL.MTLPipelineOption
                      reflection:reflection::Out{MTL.MTLComputePipelineReflection}
                      error:err::Out{NSError}]::Union{Nothing,MTL.MTLComputePipelineState}
    pipeline === nothing && throw(CommandError(string(err[])))
    return pipeline, reflection[]
end

function binding_info(b::MTL.MTLBinding)
    info = Pair{Symbol,Any}[:name => String(b.name), :type => b.type, :index => Int(b.index),
                            :access => b.access, :used => b.used]
    if b.type == MTL.MTLBindingTypeBuffer
        bb = downcast(MTL.MTLBufferBinding, b)
        st = bb.bufferStructType
        push!(info, :data_type => bb.bufferDataType, :data_size => Int(bb.bufferDataSize),
                    :alignment => Int(bb.bufferAlignment),
                    :struct_members => st === nothing ? nothing :
                        [(; name = String(m.name), offset = Int(m.offset), type = m.dataType)
                         for m in st.members])
    elseif b.type == MTL.MTLBindingTypeThreadgroupMemory
        tb = downcast(MTL.MTLThreadgroupBinding, b)
        push!(info, :data_size => Int(tb.threadgroupMemoryDataSize),
                    :alignment => Int(tb.threadgroupMemoryAlignment))
    end
    return info
end

function reflect(ctx::Context, args::Arguments)
    1 <= length(args.positionals) <= 2 || throw(UsageError("expected FILE [FUNCTION]"))
    input = args.positionals[1]
    data = read_input(ctx, input)
    lib = read(IOBuffer(data), MetalLib)
    funs = if length(args.positionals) == 2
        name = args.positionals[2]
        any(f -> f.name == name, lib.functions) ||
            throw(CommandError("no function named $name"))
        filter(f -> f.name == name, lib.functions)
    else
        lib.functions
    end

    if !("--runtime" in args.flags)
        # TODO: decode the AIRR reflection data
        diagnose!(ctx, "warning", "decoding the reflection data in the library is not " *
                  "supported yet; use --runtime to ask Metal for the reflection of the " *
                  "library's kernels")
        return (:unsupported, (; file = input, functions = [
            (; f.name, f.type, reflection_size = f.reflection_data === nothing ? nothing :
                                                 sizeof(f.reflection_data))
            for f in funs]))
    end

    dev = Metal.device()
    mtl_lib = try
        MTL.MTLLibraryFromData(dev, data)
    catch e
        throw(CommandError("Metal failed to load the library: " * sprint(showerror, e)))
    end
    functions = map(funs) do f
        if f.type != Metal.METALLIB_COMPUTE_FUNCTION
            diagnose!(ctx, "note", "skipping $(f.name): Metal only reflects kernels")
            return (; f.name, f.type, bindings = nothing)
        end
        fun, required = pipeline_function(mtl_lib, f.name)
        if fun === nothing
            diagnose!(ctx, "note", "skipping $(f.name), which needs values for its function " *
                      "constants $(join(required, ", "))")
            return (; f.name, f.type, bindings = nothing)
        end
        pipeline, reflection = try
            reflected_pipeline(dev, fun)
        catch e
            e isa CommandError || rethrow()
            diagnose!(ctx, "error", "creating a compute pipeline for $(f.name) failed: $(e.msg)")
            return (; f.name, f.type, bindings = nothing)
        end
        (; f.name, f.type,
           max_total_threads_per_threadgroup = Int(pipeline.maxTotalThreadsPerThreadgroup),
           static_threadgroup_memory = Int(pipeline.staticThreadgroupMemoryLength),
           bindings = reflection === nothing ? nothing : map(binding_info, reflection.bindings))
    end
    # partial results when some functions could not be reflected
    status = all(f -> f.bindings !== nothing, functions) ? :ok : :partial
    return (status, (; file = input, device = String(dev.name), functions))
end

function reflect_text(io::IO, r)
    for f in r.functions
        if !haskey(f, :bindings)
            println(io, "$(f.name): $(f.type)",
                    f.reflection_size === nothing ? ", no reflection data" :
                                                    ", $(f.reflection_size) bytes of reflection data")
            continue
        end
        f.bindings === nothing && continue
        println(io, "$(f.name): at most $(f.max_total_threads_per_threadgroup) threads ",
                "per threadgroup, $(f.static_threadgroup_memory) bytes of static threadgroup memory")
        for b in f.bindings
            b = Dict(b)
            line = "  [$(b[:index])] $(b[:name]): $(b[:type]), $(b[:access])"
            b[:used] || (line *= ", unused")
            haskey(b, :data_type) && (line *= ", $(b[:data_type])")
            haskey(b, :data_size) && (line *= ", $(b[:data_size]) bytes aligned to $(b[:alignment])")
            println(io, line)
            members = get(b, :struct_members, nothing)
            members === nothing && continue
            for m in members
                println(io, "      +$(m.offset) $(m.name): $(m.type)")
            end
        end
    end
end

register!("reflect", Command(
    "Show the arguments of a library's functions.",
    """
    Usage: $program reflect --runtime FILE [FUNCTION]

    Describe the arguments of the kernels in the library in FILE (`-` for standard input),
    or only of FUNCTION: for every binding its index, name, kind, access, whether the kernel
    uses it, and for buffers the data type, size, alignment and struct members.

    Metal builds this reflection from the metadata in a function's AIR module, not from the
    reflection data Apple's toolchain stores in the library, which this tool cannot decode
    yet. --runtime, which is required for now, loads the library on the default Metal
    device and creates a compute pipeline for every kernel to ask Metal for it. Functions
    other than kernels, and kernels that need values for function constants, are skipped.

    Options:
      --runtime     Ask Metal for the reflection of the kernels.

    Example:
      $program reflect --runtime --json shaders.metallib my_kernel""",
    ["--runtime"], String[], reflect, reflect_text))


end # module MetalLibCLI
