using LLVM, LLVM.IR

mktempdir() do dir
    metallib_as = joinpath(dirname(@__DIR__), "bin", "metallib-as")
    metallib_dis = joinpath(dirname(@__DIR__), "bin", "metallib-dis")
    metallib_load = joinpath(dirname(@__DIR__), "bin", "metallib-load")

    # make sure we can load the dummy metallib
    dummy = joinpath(@__DIR__, "dummy.metallib")
    @test success(`$metallib_load $dummy`)

    # only kernels can be instantiated as a compute pipeline
    visible = joinpath(@__DIR__, "metallib", "visible.13.metallib")
    @test success(`$metallib_load $visible`)

    # disassemble to bitcode
    run(`$metallib_dis -o $dir/dummy.bc $dummy kernel_1`)
    @test isfile(joinpath(dir, "dummy.bc"))
    @dispose ctx=Context() mod=parse(LLVM.Module, read(joinpath(dir, "dummy.bc"))) begin
        @test mod isa LLVM.Module
    end

    # disassemble to IR
    run(`$metallib_dis -o $dir/dummy.ll $dummy kernel_1`)
    @test isfile(joinpath(dir, "dummy.ll"))
    @test contains(read(joinpath(dir, "dummy.ll"), String), "define void @kernel_1()")

    # assemble and load bitcode (without downgrading)
    run(`$metallib_as -f -o $dir/dummy.metallib $dir/dummy.bc`)
    @test success(`$metallib_load $dir/dummy.metallib`)

    # assemble and load IR
    run(`$metallib_as -f -o $dir/dummy.metallib $dir/dummy.ll`)
    @test success(`$metallib_load $dir/dummy.metallib`)

    # the function type comes from the module
    visible = joinpath(@__DIR__, "metallib", "visible.26.metallib")
    run(`$metallib_dis -o $dir/twice.bc $visible twice`)
    run(`$metallib_as -f -o $dir/twice.metallib $dir/twice.bc`)
    fun = only(read(joinpath(dir, "twice.metallib"), Metal.MetalLib).functions)
    @test fun.type == Metal.METALLIB_VISIBLE_FUNCTION

    # test pipelines
    @test success(pipeline(`$metallib_dis -o - $dummy kernel_1`,
                           `$metallib_as -o - -`,
                           `$metallib_load -`))
    @test success(pipeline(`$metallib_dis -S -o - $dummy kernel_1`,
                           `$metallib_as -o - -`,
                           `$metallib_load -`))
end

## the command-line tool, in process

using Metal: MetalLibCLI

# run the tool, returning its exit code, output and diagnostics
function metallib(args...; input=IOBuffer())
    io, err = IOBuffer(), IOBuffer()
    code = MetalLibCLI.main(collect(String, args); io, err, input)
    return (; code, out=String(take!(io)), err=String(take!(err)))
end

# a minimal JSON parser, to check the structure of the tool's output
function parse_json(str::AbstractString)
    pos = Ref(1)
    peek() = (skip_ws(); str[pos[]])
    skip_ws() = while pos[] <= ncodeunits(str) && isspace(str[pos[]]); pos[] = nextind(str, pos[]); end
    function expect(s)
        skip_ws()
        startswith(SubString(str, pos[]), s) || error("expected $s at $(pos[])")
        pos[] += ncodeunits(s)
    end
    function value()
        c = peek()
        if c == '{'
            expect("{"); obj = Pair{String,Any}[]
            peek() == '}' && (expect("}"); return obj)
            while true
                key = value(); expect(":"); push!(obj, key => value())
                peek() == ',' ? expect(",") : (expect("}"); return obj)
            end
        elseif c == '['
            expect("["); arr = Any[]
            peek() == ']' && (expect("]"); return arr)
            while true
                push!(arr, value())
                peek() == ',' ? expect(",") : (expect("]"); return arr)
            end
        elseif c == '"'
            expect("\""); buf = IOBuffer()
            while (c = str[pos[]]) != '"'
                if c == '\\'
                    e = str[pos[] += 1]
                    if e == 'u'
                        write(buf, Char(parse(UInt16, str[pos[]+1:pos[]+4]; base=16)))
                        pos[] += 4
                    else
                        write(buf, get(Dict('n' => '\n', 't' => '\t', 'r' => '\r'), e, e))
                    end
                    pos[] += 1
                else
                    write(buf, c); pos[] = nextind(str, pos[])
                end
            end
            pos[] += 1
            return String(take!(buf))
        elseif startswith(SubString(str, pos[]), "true"); expect("true"); return true
        elseif startswith(SubString(str, pos[]), "false"); expect("false"); return false
        elseif startswith(SubString(str, pos[]), "null"); expect("null"); return nothing
        else
            m = match(r"-?\d+(\.\d+)?([eE][-+]?\d+)?", str, pos[])
            pos[] += ncodeunits(m.match)
            return m[1] === nothing && m[2] === nothing ? parse(Int, m.match) : parse(Float64, m.match)
        end
    end
    v = value(); skip_ws()
    pos[] > ncodeunits(str) || error("trailing data at $(pos[])")
    return v
end
getkey(obj, key) = only(v for (k, v) in obj if k == key)

metallib_dir = joinpath(@__DIR__, "metallib")

@testset "metallib CLI" begin
    @testset "help" begin
        r = metallib()
        @test r.code == 2 && contains(r.err, "Commands:")
        r = metallib("--help")
        @test r.code == 0 && contains(r.out, "info") && contains(r.out, "\"schema\"")
        for args in (("help", "info"), ("info", "--help"))
            r = metallib(args...)
            @test r.code == 0 && contains(r.out, "Example")
        end
        @test metallib("frobnicate").code == 2
        @test metallib("info", "--frobnicate", "x").code == 2
        @test metallib("info").code == 2

        # with --json, usage errors are reported as a document too
        for args in (("info", "--json"), ("info", "--json", "--bogus"), ("frobnicate", "--json"))
            r = metallib(args...)
            @test r.code == 2 && isempty(r.err)
            doc = parse_json(r.out)
            @test getkey(doc, "status") == "error"
            @test getkey(only(getkey(doc, "diagnostics")), "severity") == "error"
        end
        # ... but only when it is an option
        r = metallib("info", "--", "--json")
        @test r.code == 1 && isempty(r.out) && contains(r.err, "no such file: --json")
    end

    @testset "info" begin
        path = joinpath(metallib_dir, "kernels.26.metallib")
        r = metallib("info", path)
        @test r.code == 0
        @test contains(r.out, "foo: METALLIB_COMPUTE_FUNCTION, AIR v2.8.0")

        # JSON output, also from standard input
        r = metallib("info", "--json", "-"; input=IOBuffer(read(path)))
        @test r.code == 0 && isempty(r.err)
        doc = parse_json(r.out)
        @test first.(doc) == ["schema", "command", "status", "result", "diagnostics"]
        @test getkey(doc, "schema") == "metal.jl/metallib-cli/1"
        @test getkey(doc, "status") == "ok"
        result = getkey(doc, "result")
        @test getkey(result, "uuid") == "83CD5BA0-7375-3B78-B57A-75B99D98BC4B"
        functions = getkey(result, "functions")
        @test [getkey(f, "name") for f in functions] == ["foo", "bar", "baz"]
        @test getkey(functions[1], "type") ==
              ["name" => "METALLIB_COMPUTE_FUNCTION", "value" => 2]

        # undecoded tags are reported as a note, in the document only
        r = metallib("info", "--json", joinpath(metallib_dir, "render.26.metallib"))
        @test r.code == 0 && isempty(r.err)
        doc = parse_json(r.out)
        @test getkey(getkey(doc, "result"), "undecoded_tags") == ["LAYR", "TESS", "VATT", "VATY"]
        @test getkey(only(getkey(doc, "diagnostics")), "severity") == "note"

        # errors
        r = metallib("info", "--json", "-"; input=IOBuffer(read(path)[1:100]))
        @test r.code == 1
        doc = parse_json(r.out)
        @test getkey(doc, "status") == "error" && getkey(doc, "result") === nothing
        @test getkey(only(getkey(doc, "diagnostics")), "offset") isa Int
        r = metallib("info", joinpath(metallib_dir, "nonexistent.metallib"))
        @test r.code == 1 && contains(r.err, "no such file")
    end
end
