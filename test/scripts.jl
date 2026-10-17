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
        r = metallib("dis", "-o", "--json", "--bogus")
        @test r.code == 2 && isempty(r.out)
        r = metallib("dis", "-o", "--", "--json", "--bogus")
        @test r.code == 2 && getkey(parse_json(r.out), "status") == "error"
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

    @testset "dump" begin
        r = metallib("dump", joinpath(metallib_dir, "visible.26.metallib"))
        @test r.code == 0
        @test contains(r.out, "TYPE METALLIB_VISIBLE_FUNCTION")
        @test contains(r.out, "UUID BC93EDA2-6985-3FA6-84A2-A4877AA6E6FB")

        # the sections cover the library, and tags are where we say they are
        for file in readdir(metallib_dir)
            endswith(file, ".metallib") || continue
            bytes = read(joinpath(metallib_dir, file))
            r = metallib("dump", "--json", "--raw", joinpath(metallib_dir, file))
            @test r.code == 0
            result = getkey(parse_json(r.out), "result")
            position = 88
            for section in getkey(result, "sections")
                @test getkey(section, "offset") == position
                position += getkey(section, "size")
                any(k == "groups" for (k, _) in section) || continue
                for group in getkey(section, "groups"), tag in getkey(group, "tags")
                    offset, size = getkey(tag, "offset"), getkey(tag, "size")
                    @test getkey(tag, "raw") == bytes2hex(bytes[offset+1:offset+size])
                end
            end
            @test position == length(bytes)
        end

        # tags that are not decoded
        r = metallib("dump", "--json", joinpath(metallib_dir, "render.26.metallib"))
        sections = getkey(getkey(parse_json(r.out), "result"), "sections")
        public = only(s for s in sections if getkey(s, "name") == "PUBLIC_METADATA")
        tags = [tag for g in getkey(public, "groups") for tag in getkey(g, "tags")]
        @test any(t -> getkey(t, "tag") == "VATT" && getkey(t, "decoded") == false, tags)
    end

    @testset "dis, as and load" begin
        mktempdir() do dir
            # (a library that loads on every supported macOS)
            path = joinpath(metallib_dir, "kernels.13.metallib")
            lib = parse(Metal.MetalLib, path)

            # functions must be named when there are several
            r = metallib("dis", path)
            @test r.code == 1 && contains(r.err, "foo, bar, baz")

            # bitcode, as is
            r = metallib("dis", "--json", "-o", joinpath(dir, "bar.bc"), path, "bar")
            @test r.code == 0
            @test read(joinpath(dir, "bar.bc")) == lib.functions[2].air_module
            result = getkey(parse_json(r.out), "result")
            @test getkey(result, "format") == "bitcode"
            @test metallib("dis", "-o", joinpath(dir, "bar.bc"), path, "bar").code == 1
            @test metallib("dis", "-f", "-o", joinpath(dir, "bar.bc"), path, "bar").code == 0

            # textual IR, to standard output
            r = metallib("dis", "-S", "-o", "-", path, "foo")
            @test r.code == 0 && contains(r.out, "define void @foo()")
            @test metallib("dis", "--json", "-o", "-", path, "foo").code == 2

            # and back into a library, which loads
            write(joinpath(dir, "foo.ll"), r.out)
            # (functions are described from their module's metadata)
            visible = joinpath(metallib_dir, "visible.26.metallib")
            @test metallib("dis", "-o", joinpath(dir, "twice.bc"), visible, "twice").code == 0
            @test metallib("as", "-o", joinpath(dir, "twice.metallib"), joinpath(dir, "twice.bc")).code == 0
            twice = only(parse(Metal.MetalLib, joinpath(dir, "twice.metallib")).functions)
            @test twice.type == Metal.METALLIB_VISIBLE_FUNCTION
            @test twice.air_version == only(f for f in parse(Metal.MetalLib, visible).functions
                                            if f.name == "twice").air_version

            r = metallib("as", "--json", "-o", joinpath(dir, "foo.metallib"),
                         joinpath(dir, "foo.ll"))
            @test r.code == 0
            @test getkey(only(getkey(getkey(parse_json(r.out), "result"), "functions")),
                         "name") == "foo"
            r = metallib("load", "--pipeline", "--json", joinpath(dir, "foo.metallib"))
            @test r.code == 0
            @test getkey(only(getkey(getkey(parse_json(r.out), "result"), "functions")),
                         "pipeline") == "ok"
            @test metallib("as", joinpath(dir, "foo.ll"), joinpath(dir, "bar.bc")).code == 2
            write(joinpath(dir, "broken.ll"), "this is not LLVM IR")
            r = metallib("as", "-o", joinpath(dir, "broken.metallib"), joinpath(dir, "broken.ll"))
            @test r.code == 1 && contains(r.err, "could not parse")
        end

        # pipelines are only created for kernels
        r = metallib("load", "--pipeline", "--json", joinpath(metallib_dir, "visible.13.metallib"))
        @test r.code == 0
        functions = getkey(getkey(parse_json(r.out), "result"), "functions")
        @test Dict(getkey(f, "name") => getkey(f, "pipeline") for f in functions) ==
              Dict("foo" => "ok", "twice" => "skipped")
        @test only(getkey(getkey(f, "type"), "name") for f in functions
                   if getkey(f, "name") == "foo") == "MTLFunctionTypeKernel"

        # ... that don't need values for function constants (Metal would abort)
        r = metallib("load", "--pipeline", "--json", joinpath(metallib_dir, "constants.13.metallib"))
        @test r.code == 0
        doc = parse_json(r.out)
        @test getkey(only(getkey(getkey(doc, "result"), "functions")), "pipeline") == "skipped"
        @test contains(getkey(only(getkey(doc, "diagnostics")), "message"), "constants")
        # (optional constants are left undefined)
        r = metallib("load", "--pipeline", "--json", joinpath(metallib_dir, "optional.13.metallib"))
        @test r.code == 0
        doc = parse_json(r.out)
        @test getkey(only(getkey(getkey(doc, "result"), "functions")), "pipeline") == "ok"

        # failing to load a library is reported as such
        r = metallib("load", "-"; input=IOBuffer(rand(UInt8, 100)))
        @test r.code == 1 && contains(r.err, "failed to load the library")
        r = metallib("load", joinpath(metallib_dir, "kernel.13.metallib"), "nonexistent")
        @test r.code == 1 && contains(r.err, "no function nonexistent")
    end
end
