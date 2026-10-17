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

    # the entry point of the Pkg app (`julia -m` needs Julia 1.12)
    @static if VERSION >= v"1.12"
        project = Base.active_project()
        cmd = `$(Base.julia_cmd()) --project=$project -m Metal.MetalLibCLI info $(joinpath(metallib_dir, "kernel.13.metallib"))`
        @test contains(read(cmd, String), "foo: METALLIB_COMPUTE_FUNCTION")
        cmd = `$(Base.julia_cmd()) --project=$project -m Metal.MetalLibCLI info nonexistent`
        @test !success(pipeline(cmd; stderr=devnull))
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
            # (IR that parses, but that the verifier rejects)
            write(joinpath(dir, "invalid.ll"), """
                define void @foo() {
                  %a = add i32 %b, 1
                  %b = add i32 %a, 1
                  ret void
                }""")
            r = metallib("as", "-o", joinpath(dir, "invalid.metallib"), joinpath(dir, "invalid.ll"))
            @test r.code == 1 && contains(r.err, "not valid LLVM IR")

            # plain bitcode, as written by LLVM rather than Apple's toolchain
            # (LLVM wraps the bitcode for Darwin targets like AIR)
            @dispose ctx=Context() mod=parse(LLVM.Module, read(joinpath(dir, "foo.ll"), String)) begin
                LLVM.triple!(mod, "")
                write(joinpath(dir, "plain.bc"), mod)
            end
            @test read(joinpath(dir, "plain.bc"))[1:4] == [0x42, 0x43, 0xc0, 0xde]
            @test metallib("as", "-o", joinpath(dir, "plain.metallib"), joinpath(dir, "plain.bc")).code == 0
            r = metallib("dis", "-S", "-o", "-", joinpath(dir, "plain.metallib"))
            @test r.code == 0 && contains(r.out, "define void @foo()")
            r = metallib("validate", "--json", joinpath(dir, "plain.metallib"))
            @test getkey(parse_json(r.out), "status") == "ok"

            # failing to write the output
            r = metallib("dis", "--json", "-o", joinpath(dir, "nonexistent", "foo.bc"), path, "foo")
            @test r.code == 1
            @test getkey(parse_json(r.out), "status") == "error"
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

    @testset "reflect" begin
        # the reflection data in the library isn't decoded yet
        r = metallib("reflect", "--json", joinpath(metallib_dir, "kernel.13.metallib"))
        @test r.code == 1
        doc = parse_json(r.out)
        @test getkey(doc, "status") == "unsupported"
        @test getkey(only(getkey(getkey(doc, "result"), "functions")), "name") == "foo"

        # ... but Metal can reflect the kernels
        r = metallib("reflect", "--runtime", "--json", joinpath(metallib_dir, "visible.13.metallib"))
        @test r.code == 0
        doc = parse_json(r.out)
        functions = getkey(getkey(doc, "result"), "functions")
        @test [getkey(f, "name") for f in functions] == ["foo", "twice"]
        # (visible functions can't be reflected on their own)
        @test getkey(functions[2], "bindings") === nothing
        @test getkey(only(getkey(doc, "diagnostics")), "severity") == "note"
        binding = only(getkey(functions[1], "bindings"))
        @test getkey(binding, "name") == "a"
        @test getkey(getkey(binding, "type"), "name") == "MTLBindingTypeBuffer"
        @test getkey(getkey(binding, "data_type"), "name") == "MTLDataTypeFloat"
        @test getkey(binding, "data_size") == 4

        r = metallib("reflect", "--runtime", "--json", joinpath(metallib_dir, "constants.13.metallib"))
        @test r.code == 0
        doc = parse_json(r.out)
        @test getkey(doc, "status") == "partial"
        @test getkey(only(getkey(getkey(doc, "result"), "functions")), "bindings") === nothing
        r = metallib("reflect", "--runtime", "--json", joinpath(metallib_dir, "optional.13.metallib"))
        @test r.code == 0
        doc = parse_json(r.out)
        @test getkey(doc, "status") == "ok"
        @test getkey(only(getkey(getkey(getkey(doc, "result"), "functions")[1], "bindings")),
                     "name") == "a"

        r = metallib("reflect", "--runtime", joinpath(metallib_dir, "visible.13.metallib"), "foo")
        @test r.code == 0 && contains(r.out, "[0] a: MTLBindingTypeBuffer")
        r = metallib("reflect", "--runtime", joinpath(metallib_dir, "visible.13.metallib"), "bar")
        @test r.code == 1 && contains(r.err, "no function named bar")
    end

    @testset "validate" begin
        path = joinpath(metallib_dir, "kernels.13.metallib")
        r = metallib("validate", "--runtime", "--json", path)
        @test r.code == 0
        result = getkey(parse_json(r.out), "result")
        @test getkey(result, "valid") == true
        @test getkey(result, "checked") == ["structure", "modules", "runtime"]

        # a HASH that doesn't match the module
        lib = parse(Metal.MetalLib, path)
        bytes = read(path)
        offset = lib.functions[2].layout.function_tags.offsets["HASH"]
        bytes[offset+1] ⊻= 0xff
        r = metallib("validate", "--json", "-"; input=IOBuffer(bytes))
        @test r.code == 0
        doc = parse_json(r.out)
        diagnostic = only(getkey(doc, "diagnostics"))
        @test getkey(diagnostic, "severity") == "warning"
        @test getkey(diagnostic, "offset") == offset
        @test contains(getkey(diagnostic, "message"), "HASH of bar")

        # a module that isn't bitcode can't be checked
        functions = copy(lib.functions)
        functions[2] = Metal.MetalLibFunction(functions[2]; air_module=[0x00, 0x01, 0x02, 0x03])
        broken = sprint(write, Metal.MetalLib(lib; functions))
        r = metallib("validate", "--json", "-"; input=IOBuffer(broken))
        @test r.code == 0
        doc = parse_json(r.out)
        @test getkey(doc, "status") == "partial"
        @test getkey(getkey(doc, "result"), "unchecked_modules") == ["bar"]

        # a module that is broken bitcode, or doesn't define the function
        for (air_module, message) in ([0xde, 0xc0, 0x17, 0x0b, 0x00] => "not valid LLVM bitcode",
                                      lib.functions[1].air_module => "does not define it")
            functions = copy(lib.functions)
            functions[2] = Metal.MetalLibFunction(functions[2]; air_module)
            broken = sprint(write, Metal.MetalLib(lib; functions))
            r = metallib("validate", "-"; input=IOBuffer(broken))
            @test r.code == 1 && contains(r.err, message)
        end

        # a truncated library
        r = metallib("validate", "--json", "-"; input=IOBuffer(read(path)[1:200]))
        @test r.code == 1
        @test getkey(parse_json(r.out), "status") == "error"
    end
end
