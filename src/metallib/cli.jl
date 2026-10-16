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

end # module MetalLibCLI
