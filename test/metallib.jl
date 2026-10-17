# test that we can parse and regenerate Metal libraries accurately

using Metal: MetalLibFunction, MetalLib, MetalLibFormatError, content_uuid
using LLVM: LLVM, @dispose
using UUIDs: UUID, uuid_version

using Printf: @printf

# display the contents of a file in hexadecimal
hexdump(obj) = hexdump(stdout, obj)
hexdump(io, obj) = GC.@preserve obj hexdump(io, pointer(obj), sizeof(obj))
hexdump(io, mem::Ptr, len::Integer) = hexdump(io, mem, len)
function hexdump(io::IO, mem::Ptr, len::Integer; per_line::Integer=16, split_per::Integer=2)
    mem = convert(Ptr{UInt8}, mem)
    off = 1
    while off <= len
        @printf io "%08x: " off-1

        # bytes
        str = ""
        for i in 1:per_line
            if off <= len
                val = unsafe_load(mem, off)
                @printf io "%02x" val

                str *= if 0x20 <= val <= 0x7e
                    # more strict than isascii to prevent control characters, etc
                    Char(val)
                else
                    '.'
                end
            else
                @printf io "  "
            end

            if i%split_per == 0
                print(io, " ")
            end
            off += 1
        end

        print(io, " ", str)

        if off <= len
            println(io)
        end
    end
end

# diff two objects, highlighting using `colordiff`
hexdiff(obj1, obj2) = hexdiff(stdout, obj1, obj2)
function hexdiff(io, obj1, obj2)
    dump1 = sprint(io -> hexdump(io, obj1))
    dump2 = sprint(io -> hexdump(io, obj2))
    colordiff(io ,IOBuffer(dump1), IOBuffer(dump2))
end

# diff two streams, highlighting different lines and additionally different characters.
colordiff(in1, in2) = colordiff(stdout, in1, in2)
function colordiff(io, in1, in2; context=2)
    lines1 = collect(eachline(in1))
    lines2 = collect(eachline(in2))
    lines = max(length(lines1), length(lines2))

    # find relevant line numbers
    line_status = fill(0, lines)
    ## print those that differ
    for i in 1:lines
        if get(lines1, i, "") != get(lines2, i, "")
            line_status[i] = 1
        end
    end
    ## if any differ, also include the start and end
    if any(line_status .== 1)
        line_status[1] = 1
        line_status[end] = 1
    end
    ## include context
    for i in 1:lines
        if line_status[i] == 1
            for j in max(1, i-context):min(lines, i+context)
                if line_status[j] == 0
                    line_status[j] = 2
                end
            end
        end
    end

    if !any(line_status .== 1)
        return
    end

    # print relevant lines
    was_printing = true
    linelen = max(maximum(length, lines1), maximum(length, lines2))
    for i in 1:lines
        if line_status[i] == 0
            if was_printing
                println(io, "...")
                was_printing = false
            end
            continue
        end
        was_printing = true

        line1 = get(lines1, i, "")
        if length(line1) < linelen
            line1 *= " "^(linelen - length(line1))
        end
        line2 = get(lines2, i, "")
        if length(line2) < linelen
            line2 *= " "^(linelen - length(line2))
        end
        line = "$(line1)     $(line2)"

        if line1 != line2
            for j in 1:linelen
                color = line1[j] != line2[j] ? :red : :cyan
                printstyled(io, line1[j]; color)
            end
            print(io, "  |  ")
            for j in 1:linelen
                color = line1[j] != line2[j] ? :red : :cyan
                printstyled(io, line2[j]; color)
            end
        else
            print(io, line)
        end

        if i != lines
            println(io)
        end
    end
end

function compare(ref_path)
    # parse the reference version
    ref_bytes = read(ref_path)
    ref_library = open(ref_path) do io
        read(io, MetalLib)
    end

    # generate new data, and parse it again
    new_bytes = let IO=IOBuffer()
        write(IO, ref_library)
        take!(IO)
    end

    # compare
    if ref_bytes == new_bytes
        return true
    else
        println("Encountered differences while comparing $(basename(ref_path))")

        display(ref_library)
        println()

        hexdiff(ref_bytes, new_bytes)

        return false
    end
end

# Apple's Metal toolchain, used as an oracle when available (see the Makefile)
const metal_toolchain = get(ENV, "METAL_TOOLCHAIN",
    "/Volumes/MetalToolchainCryptex/Metal.xctoolchain/usr/metal/current/bin")
metal_tool(name) = (path = joinpath(metal_toolchain, name); isfile(path) ? path : nothing)

# the library UUID as reported by Apple's `metal-readobj`
function readobj_uuid(path)
    readobj = metal_tool("metal-readobj")
    readobj === nothing && return nothing
    m = match(r"UUID: ([0-9A-F-]+)", read(`$readobj --all $path`, String))
    return m === nothing ? nothing : UUID(m[1])
end

## tests begin
metallib_dir = joinpath(@__DIR__, "metallib")
metallibs = String[]
for file in readdir(metallib_dir)
    if endswith(file, ".metallib")
        push!(metallibs, file)
    end
end

@testset for metallib in metallibs
    @test compare(joinpath(metallib_dir, metallib))
end

@testset "function types" begin
    for metallib in filter(startswith("visible."), metallibs)
        lib = parse(MetalLib, joinpath(metallib_dir, metallib))
        types = Dict(fun.name => fun.type for fun in lib.functions)
        @test types == Dict("foo" => Metal.METALLIB_COMPUTE_FUNCTION, "twice" => Metal.METALLIB_VISIBLE_FUNCTION)

        # the runtime takes the function type from the TYPE tag
        lib.platform_version <= Metal.macos_version() || continue
        mtllib = MTL.MTLLibraryFromData(device(), sprint(write, lib))
        @test MTL.MTLFunction(mtllib, "twice").functionType == MTL.MTLFunctionTypeVisible
    end
end

@testset "content-derived UUID" begin
    u = content_uuid(UInt8[1, 2, 3])
    @test u == content_uuid(UInt8[1, 2, 3])
    @test u != content_uuid(UInt8[1, 2, 4])
    # multiple buffers hash like their concatenation
    @test u == content_uuid(UInt8[1, 2], UInt8[3])
    # well-formed version 4, variant 1 UUID
    str = string(u)
    @test str[15] == '4'
    @test str[20] in ('8', '9', 'a', 'b')
end

@testset "UUID byte order" begin
    # reference value from `metal-readobj --all kernel.26.metallib`
    lib = parse(MetalLib, joinpath(metallib_dir, "kernel.26.metallib"))
    @test lib.uuid == UUID("602B95E8-464B-3967-9B41-A4CD7F83F583")
    @test uuid_version(lib.uuid) == 3

    if metal_tool("metal-readobj") === nothing
        @test_skip "Apple's metal-readobj not available"
    else
        for metallib in metallibs
            path = joinpath(metallib_dir, metallib)
            @test parse(MetalLib, path).uuid == readobj_uuid(path)
        end
    end

    # the UUIDs we generate are stored in RFC 4122 byte order, i.e. Apple's tools see a
    # version 4, variant 1 UUID
    fun = only(lib.functions)
    uuid = content_uuid(fun.air_module)
    new_lib = MetalLib(; lib.file_version, lib.platform_version, functions=[fun], uuid)
    bytes = sprint(write, new_lib)
    uuid_offset = findfirst("UUID", bytes)[end] + 3     # skip the 16-bit size field
    @test codeunits(bytes)[uuid_offset:uuid_offset+15] == reinterpret(UInt8, [hton(uuid.value)])
    if metal_tool("metal-readobj") === nothing
        @test_skip "Apple's metal-readobj not available"
    else
        mktemp() do path, io
            write(io, bytes)
            close(io)
            @test readobj_uuid(path) == uuid
        end
    end
end

@testset "function constants" begin
    readobj = metal_tool("metal-readobj")
    if readobj === nothing
        @test_skip "Apple's metal-readobj not available"
    else
        for metallib in filter(startswith("constants."), metallibs)
            path = joinpath(metallib_dir, metallib)
            lib = parse(MetalLib, path)
            output = read(`$readobj --all $path`, String)
            expected = [(m[1], m[2] == "Yes") for m in
                        eachmatch(r"Name: (\w+)\n\s+Type: \w+ \(\w+\)\n\s+Index: \d+\n\s+Required: (\w+)", output)]
            @test !isempty(expected)
            @test [(c.name, c.required) for fun in lib.functions for c in fun.constants] == expected
        end
    end
end

@testset "function dependencies" begin
    path = joinpath(metallib_dir, "dependencies.standalone.metallib")
    lib = parse(MetalLib, path)
    dependencies = Dict(fun.name => fun.dependencies for fun in lib.functions)
    @test dependencies == Dict("foo" => ["dependencies.air", "dependencies_helper.air"],
                               "bar" => ["dependencies.air"])
end

@testset "enum names" begin
    # our enums are named like Apple's metal-readobj prints them
    readobj = metal_tool("metal-readobj")
    if readobj === nothing
        @test_skip "Apple's metal-readobj not available"
    else
        for metallib in metallibs
            path = joinpath(metallib_dir, metallib)
            lib = parse(MetalLib, path)
            output = read(`$readobj --all $path`, String)
            @test match(r"FileType: (\w+) ", output)[1] == string(lib.file_type)
            if lib.file_version >= v"1.2.6"
                @test match(r"Platform: (\w+) ", output)[1] == string(lib.platform_type)
            end
            function_types = [m[1] for m in eachmatch(r"Type: (METALLIB_\w+_FUNCTION) ", output)]
            @test function_types == [string(fun.type) for fun in lib.functions]
        end
    end
end

@testset "tag group size conventions" begin
    for (group_size, counts_size) in ((8, true), (4, false))
        bytes = [reinterpret(UInt8, [UInt32(group_size)]); codeunits("ENDT")]
        tg = read!(IOBuffer(bytes), Metal.TagGroup())
        @test tg.counts_size == counts_size
        @test take!(write(IOBuffer(), tg)) == bytes
    end
    bytes = [reinterpret(UInt8, [UInt32(6)]); codeunits("ENDT")]
    @test_throws MetalLibFormatError read!(IOBuffer(bytes), Metal.TagGroup())
end

@testset "standalone metallib tool" begin
    # Apple's standalone `metallib` tool does not count the size field in the size of
    # metadata groups, unlike the compiler driver
    path = joinpath(metallib_dir, "kernel.standalone.metallib")
    lib = parse(MetalLib, path)
    @test only(lib.functions).name == "foo"

    bytes = sprint(write, lib)
    @test bytes == String(read(path))
    mtllib = MTL.MTLLibraryFromData(device(), bytes)
    @test MTL.MTLComputePipelineState(device(), MTL.MTLFunction(mtllib, "foo")) isa MTL.MTLComputePipelineState
end

@testset "reflection alignment" begin
    # reflection data is the flatbuffer itself, without the padding in front of it
    for metallib in metallibs
        lib = parse(MetalLib, joinpath(metallib_dir, metallib))
        for fun in lib.functions
            fun.reflection_data === nothing && continue
            @test fun.reflection_data[5:8] == codeunits("AIRR")
        end
    end

    # when an edit moves the reflection list, the flatbuffers stay 16-byte aligned
    lib = parse(MetalLib, joinpath(metallib_dir, "kernels.26.metallib"))
    renamed(fun) = MetalLibFunction(fun; name = fun.name * "_x")
    new_lib = MetalLib(lib; functions = map(renamed, lib.functions))
    bytes = collect(codeunits(sprint(write, new_lib)))
    flatbuffers = findall(codeunits("AIRR"), bytes)
    @test length(flatbuffers) == length(lib.functions)
    @test all(range -> mod(first(range) - 1 - 4, 16) == 0, flatbuffers)
    reread = read(IOBuffer(bytes), MetalLib)
    @test [fun.reflection_data for fun in reread.functions] ==
          [fun.reflection_data for fun in lib.functions]
end

@testset "script lists" begin
    # none of the tools we have produce pipeline scripts, so attach some ourselves
    lib = parse(MetalLib, joinpath(metallib_dir, "kernels.26.metallib"))
    scripts = [rand(UInt8, 100), rand(UInt8, 3)]
    new_lib = MetalLib(lib; scripts)
    bytes = sprint(write, new_lib)
    reread = read(IOBuffer(bytes), MetalLib)
    @test reread.scripts == scripts
    @test sprint(write, reread) == bytes
    readobj = metal_tool("metal-readobj")
    if readobj === nothing
        @test_skip "Apple's metal-readobj not available"
    else
        mktemp() do path, io
            write(io, bytes)
            close(io)
            # (it rejects our scripts, which are not valid flatbuffers, after the header)
            cmd = pipeline(ignorestatus(`$readobj --all $path`), stderr=devnull)
            @test contains(read(cmd, String), "ScriptListSize: 0x")
        end
    end
end

@testset "editing libraries" begin
    # (a library that loads on every supported macOS)
    lib = parse(MetalLib, joinpath(metallib_dir, "kernels.13.metallib"))
    @test MetalLib(lib) == lib
    @test sprint(write, MetalLib(lib)) == String(read(joinpath(metallib_dir, "kernels.13.metallib")))

    # an edited library gets a new UUID, and loads
    lib2 = MetalLib(lib; functions = lib.functions[1:2])
    bytes = sprint(write, lib2)
    reread = read(IOBuffer(bytes), MetalLib)
    @test [fun.name for fun in reread.functions] == ["foo", "bar"]
    @test reread.uuid != lib.uuid
    @test uuid_version(reread.uuid) == 4
    @test sprint(write, reread) == bytes
    mtllib = MTL.MTLLibraryFromData(device(), bytes)
    @test sort(String.(mtllib.functionNames)) == ["bar", "foo"]
    for name in mtllib.functionNames
        @test MTL.MTLComputePipelineState(device(), MTL.MTLFunction(mtllib, name)) isa
              MTL.MTLComputePipelineState
    end

    # ... unless we pick one
    uuid = UUID("12345678-1234-4234-8234-123456789abc")
    @test read(IOBuffer(sprint(write, MetalLib(lib2; uuid))), MetalLib).uuid == uuid

    # replacing a module recomputes its hash, while the other functions keep theirs
    other = parse(MetalLib, joinpath(metallib_dir, "kernel.13.metallib"))
    foo = MetalLibFunction(lib.functions[1]; air_module = only(other.functions).air_module)
    lib3 = MetalLib(lib; functions = [foo; lib.functions[2:end]])
    reread = read(IOBuffer(sprint(write, lib3)), MetalLib)
    hashes = [Metal.decoded(fun.layout.function_tags, "HASH") for fun in reread.functions]
    @test hashes[1] == Metal.sha256(foo.air_module)
    @test hashes[2:end] == [Metal.decoded(fun.layout.function_tags, "HASH")
                            for fun in lib.functions[2:end]]
    mtllib = MTL.MTLLibraryFromData(device(), sprint(write, lib3))
    @test MTL.MTLComputePipelineState(device(), MTL.MTLFunction(mtllib, "foo")) isa
          MTL.MTLComputePipelineState

    # writing to a stream that already holds data
    io = IOBuffer()
    write(io, "prefix")
    @test write(io, lib) == sizeof(sprint(write, lib))
    @test String(take!(io)) == "prefix" * sprint(write, lib)
end

@testset "repeated and empty tags" begin
    # libraries can contain tags we decode more than once, or with an empty value; both are
    # written back as they were
    lib = parse(MetalLib, joinpath(metallib_dir, "kernel.26.metallib"))
    fun = only(lib.functions)
    push!(fun.layout.private_tags.data, "DEPF" => Metal.RawTag(Metal.encode_tag("DEPF", ["a.air"])),
                                        "DEPF" => Metal.RawTag(Metal.encode_tag("DEPF", ["b.air"])))
    push!(fun.layout.public_tags.data, "CNST" => Metal.RawTag(Metal.encode_tag("CNST", Metal.FunctionConstant[])))
    bytes = sprint(write, lib)
    @test contains(bytes, "b.air")
    reread = read(IOBuffer(bytes), MetalLib)
    @test only(reread.functions).dependencies == ["a.air"]
    unchanged = sprint(write, reread) == bytes
    @test unchanged

    # offsets and the UUID are patched into the first occurrence of a tag, which is the one
    # we decode
    lib = parse(MetalLib, joinpath(metallib_dir, "kernels.26.metallib"))
    push!(lib.layout.header_extension.data, "RLST" => Metal.RawTag(zeros(UInt8, 16)),
                                            "UUID" => Metal.RawTag(zeros(UInt8, 16)))
    bytes = sprint(write, lib)
    reread = read(IOBuffer(bytes), MetalLib)
    @test [fun.reflection_data for fun in reread.functions] ==
          [fun.reflection_data for fun in lib.functions]
    unchanged = sprint(write, reread) == bytes
    @test unchanged
    edited = read(IOBuffer(sprint(write, MetalLib(reread; functions=reread.functions[1:2]))),
                  MetalLib)
    @test edited.uuid != reread.uuid
end

@testset "embedded source layout" begin
    # tags we don't know in the groups of the embedded source section are preserved too
    lib = parse(MetalLib, joinpath(metallib_dir, "sources.26.metallib"))
    for tg in lib.layout.source_tags
        push!(tg.data, "ZZZZ" => Metal.RawTag(UInt8[1, 2, 3]))
    end
    bytes = sprint(write, lib)
    reread = read(IOBuffer(bytes), MetalLib)
    @test all(tg -> get(tg, "ZZZZ", nothing).data == UInt8[1, 2, 3],
              reread.layout.source_tags)
    unchanged = sprint(write, reread) == bytes
    @test unchanged
end

@testset "malformed libraries" begin
    # reading a malformed library either works or throws a `MetalLibFormatError`
    function check_parse(bytes)
        try
            read(IOBuffer(bytes), MetalLib)
            return true
        catch err
            err isa MetalLibFormatError && return true
            @error "Unexpected error reading a malformed library" exception=(err, catch_backtrace())
            return false
        end
    end

    # every truncation, and every byte set to a few values, of libraries with modules,
    # metadata and reflection, shared modules and a dynamic header
    for metallib in ["constants.26.metallib", "dylib.metallib"]
        bytes = read(joinpath(metallib_dir, metallib))
        @test all(n -> check_parse(bytes[1:n]), 0:length(bytes)-1)
        @test_throws MetalLibFormatError read(IOBuffer(bytes[1:end-1]), MetalLib)
        for value in (0x00, 0xff)
            @test all(1:length(bytes)) do i
                corrupted = copy(bytes)
                corrupted[i] = value
                check_parse(corrupted)
            end
        end
    end

    @test_throws MetalLibFormatError read(IOBuffer(codeunits("MTLX")), MetalLib)

    # sections are parsed within their bounds
    bytes = read(joinpath(metallib_dir, "sources.26.metallib"))
    hsrd = last(findfirst(codeunits("HSRD"), bytes))
    bytes[hsrd+2+8+1:hsrd+2+16] .= 0      # the section's size
    @test_throws MetalLibFormatError read(IOBuffer(bytes), MetalLib)

    # every reference to a reflection entry must resolve
    bytes = read(joinpath(metallib_dir, "dylib.metallib"))
    rflt = last(findlast(codeunits("RFLT"), bytes))
    bytes[rflt+2+1:rflt+2+8] .= 0xff
    @test_throws MetalLibFormatError read(IOBuffer(bytes), MetalLib)

    # stub libraries, which only describe their functions, are not supported
    bytes = read(joinpath(metallib_dir, "kernel.26.metallib"))
    mdsz = findfirst(codeunits("MDSZ"), bytes)
    bytes[mdsz] .= codeunits("XDSZ")
    err = try read(IOBuffer(bytes), MetalLib) catch err; err end
    @test err isa MetalLibFormatError
    @test contains(sprint(showerror, err), "stub")
end

# the modules of a library, parsed for the functions whose module is plain bitcode (not
# compressed), as `name => module` pairs
function each_module(f, lib::MetalLib)
    for fun in lib.functions
        fun.air_module[1:4] in (UInt8[0x42, 0x43, 0xc0, 0xde], UInt8[0xde, 0xc0, 0x17, 0x0b]) ||
            continue
        @dispose ctx=LLVM.Context() mod=parse(LLVM.Module, fun.air_module) begin
            f(fun, mod)
        end
    end
end

@testset "building functions from modules" begin
    # Apple's toolchain derives a function's library metadata from its module like we do
    for metallib in metallibs
        lib = parse(MetalLib, joinpath(metallib_dir, metallib))
        each_module(lib) do fun, mod
            built = MetalLibFunction(mod, fun.name; fun.air_module)
            @test built.air_module === fun.air_module
            @test (metallib, fun.name, built.type) == (metallib, fun.name, fun.type)
            @test built.air_version == fun.air_version
            @test built.metal_version == fun.metal_version
            @test built.constants == fun.constants
            # (older toolchains strip the debug info from the module)
            if haskey(mod.metadata, "llvm.dbg.cu") || fun.debug_info === nothing
                @test built.debug_info == fun.debug_info
            end
        end
    end

    # fields can be overridden
    lib = parse(MetalLib, joinpath(metallib_dir, "kernel.26.metallib"))
    each_module(lib) do fun, mod
        built = MetalLibFunction(mod, fun.name; fun.air_module, air_version=v"2.7",
                                 type=Metal.METALLIB_VISIBLE_FUNCTION)
        @test built.air_version == v"2.7"
        @test built.metal_version == fun.metal_version
        @test built.type == Metal.METALLIB_VISIBLE_FUNCTION
        @test_throws ArgumentError MetalLibFunction(mod, "bar"; fun.air_module)
    end
end

@testset "function constants from unlinked modules" begin
    # in an unlinked module, constants the function checks with `is_function_constant_defined`
    # are optional
    ref = only(parse(MetalLib, joinpath(metallib_dir, "optional_constants.metallib")).functions)
    @test [(c.name, c.required) for c in ref.constants] == [("scale", true), ("offset", false)]
    air = read(joinpath(metallib_dir, "optional_constants.air"))
    fun = @dispose ctx=LLVM.Context() mod=parse(LLVM.Module, air) begin
        MetalLibFunction(mod, "affine"; air_module=air)
    end
    @test fun.constants == ref.constants

    # the runtime needs the constants to specialize the function
    lib = MTL.MTLLibraryFromData(device(), sprint(write, MetalLib(; functions=[fun])))
    @test length(MTL.MTLFunction(lib, "affine").functionConstantsDictionary) == 2
    function run_affine(constants...)
        fcv = MTL.MTLFunctionConstantValues()
        for (name, value) in constants
            MTL.setConstantValue!(fcv, Ref(value), MTL.MTLDataTypeUInt, name)
        end
        buf = MTL.MTLBuffer(device(), 4 * sizeof(UInt32); storage=MTL.SharedStorage)
        ptr = convert(Ptr{UInt32}, buf)
        unsafe_store!.(ptr, UInt32[1, 2, 3, 4], 1:4)
        pso = MTL.MTLComputePipelineState(device(), MTL.MTLFunction(lib, "affine", fcv))
        cmdbuf = MTL.MTLCommandBuffer(MTL.MTLCommandQueue(device()))
        MTL.MTLComputeCommandEncoder(cmdbuf) do cce
            MTL.set_function!(cce, pso)
            MTL.set_buffer!(cce, buf, 0, 1)
            MTL.dispatchThreadgroups!(cce, MTL.MTLSize(1, 1, 1), MTL.MTLSize(4, 1, 1))
        end
        MTL.commit!(cmdbuf)
        MTL.wait_completed(cmdbuf)
        return unsafe_wrap(Array, ptr, 4) |> copy
    end
    @test run_affine("scale" => UInt32(3), "offset" => UInt32(1)) == [4, 7, 10, 13]
    @test run_affine("scale" => UInt32(3)) == [3, 6, 9, 12]

    # functions require the constants they use, unless that use checks them. Apple's
    # linker only lists those, as it removes the others from the function's module
    ref = parse(MetalLib, joinpath(metallib_dir, "used_constants.metallib"))
    constants(f) = [(c.name, c.required) for c in f.constants]
    reffuns = Dict(f.name => f for f in ref.functions)
    @test constants(reffuns["derived"]) == [("c1", true)]
    @test constants(reffuns["checked"]) == [("c2", true), ("c3", false)]
    @test constants(reffuns["unrelated"]) == []
    @test constants(reffuns["called"]) == [("c3", true)]
    @test constants(reffuns["selected"]) == [("c4", true), ("c5", true), ("c6", true)]
    @test constants(reffuns["field"]) == [("c7", true)]
    @test constants(reffuns["second_field"]) == [("c9", true)]
    # (without optimization, the initializers branch, and Apple's linker lists all constants)
    for air_file in ("used_constants.air", "used_constants.O0.air")
        air = read(joinpath(metallib_dir, air_file))
        funs = @dispose ctx=LLVM.Context() mod=parse(LLVM.Module, air) begin
            [MetalLibFunction(mod, name; air_module=air) for name in keys(reffuns)]
        end
        lib = MTL.MTLLibraryFromData(device(), sprint(write, MetalLib(; functions=funs)))
        for fun in funs
            reffun = reffuns[fun.name]
            used = filter(c -> any(r -> r.name == c.name, reffun.constants), fun.constants)
            unused = setdiff(fun.constants, used)
            @test (air_file, fun.name, used) == (air_file, fun.name, reffun.constants)
            @test !any(c -> c.required, unused)

            # the function can be built by specializing only the constants it requires
            fcv = MTL.MTLFunctionConstantValues()
            for c in fun.constants
                c.required || continue
                value = c.datatype == MTL.MTLDataTypeBool ? Ref(true) : Ref(UInt32(1))
                MTL.setConstantValue!(fcv, value, c.datatype, c.name)
            end
            @test MTL.MTLComputePipelineState(device(), MTL.MTLFunction(lib, fun.name, fcv)) isa
                  MTL.MTLComputePipelineState
        end
    end

    # a store to a part of a global that depends on a constant depends on that constant
    @dispose ctx=LLVM.Context() mod=LLVM.Module("dynamic") builder=LLVM.IRBuilder() begin
        i32 = LLVM.Int32Type()
        arr = LLVM.ArrayType(i32, 2)
        fc = LLVM.GlobalVariable(mod, i32, "fc.MTL_FC_INIT", 2)
        d = LLVM.GlobalVariable(mod, arr, "d", 2)
        LLVM.initializer!(d, LLVM.null(arr))
        zero = LLVM.ConstantInt(i32, 0)

        # `d[fc & 1] = 1`
        init = LLVM.Function(mod, "init", LLVM.FunctionType(LLVM.VoidType()))
        LLVM.section!(init, "air.static_init")
        LLVM.position!(builder, LLVM.at_end(LLVM.BasicBlock(init, "entry")))
        index = LLVM.and!(builder, LLVM.load!(builder, i32, fc), LLVM.ConstantInt(i32, 1))
        LLVM.store!(builder, LLVM.ConstantInt(i32, 1), LLVM.gep!(builder, arr, d, [zero, index]))
        LLVM.ret!(builder)

        # `return d[0]`
        kernel = LLVM.Function(mod, "kernel", LLVM.FunctionType(i32))
        LLVM.position!(builder, LLVM.at_end(LLVM.BasicBlock(kernel, "entry")))
        LLVM.ret!(builder, LLVM.load!(builder, i32, LLVM.gep!(builder, arr, d, [zero, zero])))

        push!(get!(mod.metadata, "air.function_constants").operands,
              LLVM.MDNode([LLVM.Metadata(fc), LLVM.MDString("uint"), LLVM.MDString("fc"),
                           LLVM.Metadata(zero)]))
        @test Metal.function_constants(mod, kernel) ==
              [Metal.FunctionConstant("fc", MTL.MTLDataTypeUInt, 0, true)]
    end

    # a check that only decides about other stores does not make a use optional
    @dispose ctx=LLVM.Context() mod=LLVM.Module("reconverging") builder=LLVM.IRBuilder() begin
        i32 = LLVM.Int32Type()
        fc = LLVM.GlobalVariable(mod, i32, "fc.MTL_FC_INIT", 2)
        x = LLVM.GlobalVariable(mod, i32, "x", 2)
        y = LLVM.GlobalVariable(mod, i32, "y", 2)
        for gv in (x, y)
            LLVM.initializer!(gv, LLVM.ConstantInt(i32, 0))
        end
        isdefined_typ = LLVM.FunctionType(LLVM.Int1Type(), [LLVM.value_type(fc)])
        isdefined = LLVM.Function(mod, "air.is_function_constant_defined", isdefined_typ)

        # `if (is_function_constant_defined(fc)) x = 1; y = fc;`
        init = LLVM.Function(mod, "init", LLVM.FunctionType(LLVM.VoidType()))
        LLVM.section!(init, "air.static_init")
        entry_bb, then_bb, join_bb = (LLVM.BasicBlock(init, name)
                                      for name in ("entry", "then", "join"))
        LLVM.position!(builder, LLVM.at_end(entry_bb))
        LLVM.br!(builder, LLVM.call!(builder, isdefined_typ, isdefined, [fc]), then_bb, join_bb)
        LLVM.position!(builder, LLVM.at_end(then_bb))
        LLVM.store!(builder, LLVM.ConstantInt(i32, 1), x)
        LLVM.br!(builder, join_bb)
        LLVM.position!(builder, LLVM.at_end(join_bb))
        LLVM.store!(builder, LLVM.load!(builder, i32, fc), y)
        LLVM.ret!(builder)

        # `return y`
        kernel = LLVM.Function(mod, "kernel", LLVM.FunctionType(i32))
        LLVM.position!(builder, LLVM.at_end(LLVM.BasicBlock(kernel, "entry")))
        LLVM.ret!(builder, LLVM.load!(builder, i32, y))

        push!(get!(mod.metadata, "air.function_constants").operands,
              LLVM.MDNode([LLVM.Metadata(fc), LLVM.MDString("uint"), LLVM.MDString("fc"),
                           LLVM.Metadata(LLVM.ConstantInt(i32, 0))]))
        @test Metal.function_constants(mod, kernel) ==
              [Metal.FunctionConstant("fc", MTL.MTLDataTypeUInt, 0, true)]
    end
end

function metallib_kernel(a)
    @inbounds a[1] = 42f0
    return
end

# compile a kernel the way `@metal` does, returning the library
function compile_metallib(f, tt; kwargs...)
    cfg = Metal.compiler_config(device(); kernel=true, name=nothing, kwargs...)
    src = Metal.methodinstance(typeof(f), tt, Base.get_world_counter())
    job = Metal.GPUCompiler.CompilerJob(src, cfg, Base.get_world_counter())
    return Metal.compile_to_metallib(job).metallib
end

@testset "generated libraries" begin
    cfg = Metal.compiler_config(device(); kernel=true, name=nothing)
    tt = Tuple{MtlDeviceVector{Float32,1}}
    bytes = compile_metallib(metallib_kernel, tt)
    fun = only(read(IOBuffer(bytes), MetalLib).functions)
    @test fun.type == Metal.METALLIB_COMPUTE_FUNCTION
    @test fun.air_version == cfg.target.air
    @test fun.metal_version == cfg.target.metal

    # the debug info points to the kernel's definition
    method = only(methods(metallib_kernel))
    @test fun.debug_info == Metal.DebugInfo(method.line, abspath(@__FILE__))

    # ... unless we don't have debug info, or the kernel isn't defined in a file
    fun = only(read(IOBuffer(compile_metallib(metallib_kernel, tt; debug_level=0)),
                    MetalLib).functions)
    @test fun.debug_info === nothing
    for file in (Symbol("REPL[1]"), :none)
        body = Expr(:block, LineNumberNode(1, file), :(@inbounds a[1] = 42f0), nothing)
        kernel = Core.eval(Module(), Expr(:function, :(kernel(a)), body))
        @test only(methods(kernel)).file == file
        # (`invokelatest` as the kernel was defined after this test started)
        lib = read(IOBuffer(Base.invokelatest(compile_metallib, kernel, tt)), MetalLib)
        fun = only(lib.functions)
        @test fun.debug_info === nothing
    end

    validate = metal_tool("metal-validate")
    if validate === nothing
        @test_skip "Apple's metal-validate not available"
    else
        mktemp() do path, io
            write(io, bytes)
            close(io)
            @test success(`$validate $path`)
        end
    end
end

struct MetallibPoint
    x::Float32
    y::Int32
end
function metallib_reflection_kernel(a, x::Float32, p::MetallibPoint)
    @inbounds a[1] = x + p.x + p.y
    return
end

# the runtime builds pipeline reflection from the argument metadata in the module, which
# describes arguments in MSL terms since GPUCompiler 2.15
if pkgversion(Metal.GPUCompiler) >= v"2.15"
using ObjectiveC: @objc, id, Out
using ObjectiveC.Foundation: NSError
@testset "pipeline reflection" begin
    tt = Tuple{MtlDeviceVector{Float32,1}, Float32, MetallibPoint}
    bytes = compile_metallib(metallib_reflection_kernel, tt)
    name = only(read(IOBuffer(bytes), MetalLib).functions).name
    dev = device()
    fun = MTL.MTLFunction(MTL.MTLLibraryFromData(dev, bytes), name)

    options = MTL.MTLPipelineOption(MTL.MTLPipelineOptionBindingInfo |
                                    MTL.MTLPipelineOptionBufferTypeInfo)
    reflection = Out{MTL.MTLComputePipelineReflection}()
    err = Out{NSError}()
    pipeline = @objc [dev::id{MTL.MTLDevice} newComputePipelineStateWithFunction:fun::id{MTL.MTLFunction}
                      options:options::MTL.MTLPipelineOption
                      reflection:reflection::Out{MTL.MTLComputePipelineReflection}
                      error:err::Out{NSError}]::Union{Nothing,MTL.MTLComputePipelineState}
    @test pipeline !== nothing
    bindings = Dict(String(b.name) => MTL.MTLBufferBinding(reinterpret(id{MTL.MTLBufferBinding}, b.ptr))
                    for b in reflection[].bindings if b.type == MTL.MTLBindingTypeBuffer)

    # a scalar passed by reference has an MSL type
    @test bindings["x"].bufferDataType == MTL.MTLDataTypeFloat
    @test bindings["x"].bufferStructType === nothing

    # a struct passed by reference has its layout
    p = bindings["p"]
    @test p.bufferDataType == MTL.MTLDataTypeStruct
    @test p.bufferDataSize == sizeof(MetallibPoint)
    @test p.bufferStructType !== nothing
    members = p.bufferStructType.members
    @test [String(m.name) for m in members] == ["x", "y"]
    @test [m.offset for m in members] == [0, 4]
    @test [m.dataType for m in members] == [MTL.MTLDataTypeFloat, MTL.MTLDataTypeInt]
end
end

# the reflection entries of a library, in the order of its reflection list
function reflection_entries(lib::MetalLib)
    entries = []
    for fun in lib.functions
        tags = fun.layout.reflection_tags
        tags === nothing || any(e -> e.tags === tags, entries) || push!(entries, (; tags, fun))
    end
    sort!(entries; by = e -> first(e.tags.extent))
    return [e.fun for e in entries]
end

# a decoded reflection as Apple's tools print it, i.e. with enumerations by name
apple_json(x) = x
apple_json(x::Integer) = Int(x)
apple_json(x::Bool) = x
apple_json(x::Metal.ReflectionEnum) = string(x.name)
apple_json(x::AbstractVector) = Any[apple_json(v) for v in x]
apple_json(x::Metal.ReflectionObject) =
    Pair{String,Any}[string(k) => apple_json(v) for (k, v) in getfield(x, :fields)
                                                if v !== nothing]

@testset "reflection data" begin
    # compare with Apple's decoding (`metal-objdump --reflection`, see the Makefile)
    for file in readdir(joinpath(metallib_dir, "reflection"))
        lib = parse(MetalLib, joinpath(metallib_dir, replace(file, ".txt" => ".metallib")))
        text = read(joinpath(metallib_dir, "reflection", file), String)
        expected = map(parse_json, split(text, r"^Reflection No\. \d+:$"m)[2:end])
        entries = reflection_entries(lib)
        @test length(entries) == length(expected)
        for (fun, json) in zip(entries, expected)
            if fun.reflection_data === nothing
                # compressed reflection data (RBUZ) is not supported
                @test haskey(fun.layout.reflection_tags, "RBUZ")
            else
                @test apple_json(Metal.reflection(fun)) == json
            end
        end
    end

    lib = parse(MetalLib, joinpath(metallib_dir, "visible.26.metallib"))
    r = Metal.reflection(lib.functions[1])
    @test nameof(r) == :Reflection
    kernel = r[only(r.kernel_functions)]
    @test nameof(kernel) == :KernelFunction && kernel.name == "foo"
    a = r[kernel.arguments[1]]
    @test nameof(a) == :BufferArg
    @test a.address_space.name == :Global
    @test a.location_index.value == 0
    @test a.buffer_size === nothing     # (absent, not 0)
    @test contains(sprint(show, MIME"text/plain"(), r), "#1 BufferArg(")
    @test Metal.reflection(MetalLibFunction(lib.functions[1]; reflection_data=nothing)) === nothing

    # malformed data either decodes or throws a `FlatBufferError`
    function check_decode(data)
        try
            Metal.reflection(data)
            return true
        catch err
            err isa Metal.FlatBufferError && return true
            @error "Unexpected error decoding malformed reflection data" exception=(err, catch_backtrace())
            return false
        end
    end
    data = lib.functions[1].reflection_data
    @test all(n -> check_decode(data[1:n]), 0:length(data)-1)
    for value in (0x00, 0x7f, 0xff)
        @test all(1:length(data)) do i
            corrupted = copy(data)
            corrupted[i] = value
            check_decode(corrupted)
        end
    end
    @test_throws Metal.FlatBufferError Metal.reflection(UInt8[])

    # a minimal reflection: `count` nodes that all refer to the same kernel function (but no
    # version, which is optional)
    function shared_reflection(count; name="kernel")
        buf = UInt8[]
        u32(x) = append!(buf, reinterpret(UInt8, [UInt32(x)]))
        u16(x) = append!(buf, reinterpret(UInt8, [UInt16(x)]))
        offset_to(target) = u32(target - length(buf))   # (relative to where it is stored)
        u32(16); append!(buf, codeunits("AIRR"))         # root table, identifier
        u16(8); u16(8); u16(0); u16(4)                   # 8: vtable (no version, nodes)
        u32(16 - 8); offset_to(24)                       # 16: Reflection
        node = 24 + 4 + 4count + 8                       # (after the vector and the vtable)
        u32(count); foreach(_ -> offset_to(node), 1:count)
        u16(8); u16(12); u16(4); u16(8)                  # vtable (node_type, node)
        u32(8); u32(2); offset_to(node + 12 + 8)         # Node: a KernelFunction
        u16(6); u16(8); u16(4); u16(0)                   # vtable (name)
        u32(8); offset_to(node + 12 + 8 + 8)             # KernelFunction
        u32(sizeof(name)); append!(buf, codeunits(name)); push!(buf, 0x00)
        return buf
    end
    data = shared_reflection(2)
    r = Metal.reflection(data)
    @test r.version === nothing
    @test r.nodes[1].node.name == "kernel"
    @test contains(sprint(show, MIME"text/plain"(), r), "AIRR reflection with 2 nodes")
    # (shared objects decode once, also when there are many references to them)
    @test r.nodes[1] === r.nodes[2]
    # (copies of the name would take 6.5 GB)
    data = shared_reflection(100_000; name="x"^65536)
    Metal.reflection(data)
    @test (@allocated Metal.reflection(data)) < 100 * sizeof(data)

    # `count` kernel functions whose names overlap: name i starts at word i of a run of words
    # that each hold the number of bytes after them, so all names end at the same NUL
    function overlapping_reflection(count)
        nodes = 24 + 4 + 4count + 16        # (after the vector and two vtables)
        strings = nodes + 20count
        buf = UInt8[]
        u32(x) = append!(buf, reinterpret(UInt8, [UInt32(x)]))
        u16(x) = append!(buf, reinterpret(UInt8, [UInt16(x)]))
        offset_to(target) = u32(target - length(buf))
        u32(16); append!(buf, codeunits("AIRR"))
        u16(8); u16(8); u16(0); u16(4)                      # 8: Reflection vtable
        u32(16 - 8); offset_to(24)                          # 16: Reflection
        u32(count); foreach(i -> offset_to(nodes + 20i), 0:count-1)
        node_vtable = length(buf)
        u16(8); u16(12); u16(4); u16(8)
        kernel_vtable = length(buf)
        u16(6); u16(8); u16(4); u16(0)
        for i in 0:count-1
            u32(length(buf) - node_vtable); u32(2); offset_to(length(buf) + 4)
            u32(length(buf) - kernel_vtable); offset_to(strings + 4i)
        end
        foreach(i -> u32(4 * (count - i - 1)), 0:count-1)
        push!(buf, 0x00)
        return buf
    end
    r = Metal.reflection(overlapping_reflection(4))
    @test [node.node.name for node in r.nodes][end] == ""
    @test sizeof(r.nodes[1].node.name) == 12
    # (overlapping names can't be shared, so they count towards a limit instead)
    err = try Metal.reflection(overlapping_reflection(4096)) catch err; err end
    @test err isa Metal.FlatBufferError && contains(err.msg, "much more than the buffer")

    # what FlatBuffers requires is checked
    data = shared_reflection(1)
    data[end] = UInt8('x')      # (strings must be NUL-terminated)
    @test_throws Metal.FlatBufferError Metal.reflection(data)
    data = shared_reflection(1)
    data[11] = 4                # (the root table can't hold its fields anymore)
    @test_throws Metal.FlatBufferError Metal.reflection(data)

    # decoded objects compare and hash by value
    a, b = (Metal.reflection(lib.functions[1]) for _ in 1:2)
    @test a == b && hash(a) == hash(b) && b in Set([a])

    # nodes of an unknown kind are kept as such
    data = copy(lib.functions[1].reflection_data)
    tag = findfirst(reinterpret(UInt8, [UInt32(266240)]), data)   # ThreadPositionInGridArg
    data[tag] .= reinterpret(UInt8, [UInt32(999999)])
    node = Metal.reflection(data).nodes[3].node
    @test node isa Metal.UnknownReflectionNode && node.tag == 999999
end

@testset "encoding reflection data" begin
    # decoded reflection data encodes to the same reflection
    for file in readdir(joinpath(metallib_dir, "reflection"))
        lib = parse(MetalLib, joinpath(metallib_dir, replace(file, ".txt" => ".metallib")))
        for fun in lib.functions
            fun.reflection_data === nothing && continue
            r = Metal.reflection(fun)
            data = Metal.reflection_data(r)
            @test data[5:8] == codeunits("AIRR")
            @test Metal.reflection(data) == r
        end
    end

    # constructing reflection objects
    arg = Metal.ReflectionObject(:BufferArg; name="a", access_qualifier=:ReadWrite,
                                 location_index=Metal.ReflectionObject(:UIntValue; value=1))
    @test arg.name == "a"
    @test arg.access_qualifier == Metal.ReflectionEnum(:AccessQualifier, :ReadWrite, 3)
    @test arg.address_space.name === :Global        # (the default)
    @test arg.location_index.value === UInt32(1)
    @test arg.type_name === nothing
    node = Metal.ReflectionObject(:Node; node=arg)
    @test node.node_type.name === :BufferArg
    kernel = Metal.ReflectionObject(:KernelFunction; name="kernel",
                                    arguments=[Metal.ReflectionObject(:NodeId; id=1)])
    r = Metal.ReflectionObject(:Reflection;
                               nodes=[Metal.ReflectionObject(:Node; node=kernel), node],
                               kernel_functions=[Metal.ReflectionObject(:NodeId; id=0)])
    r′ = Metal.reflection(Metal.reflection_data(r))
    @test r′ == r
    @test r′[only(r′[only(r′.kernel_functions)].arguments)] == arg

    # vectors of scalars, of 8 bytes here
    for extents in ([], [1, 2])
        type = Metal.ReflectionObject(:ExtentsType; extents)
        r = Metal.ReflectionObject(:Reflection; nodes=[Metal.ReflectionObject(:Node; node=type)])
        r′ = Metal.reflection(Metal.reflection_data(r))
        @test r′ == r
        @test r′.nodes[1].node.extents == UInt64.(extents)
    end

    @test_throws ArgumentError Metal.ReflectionObject(:Frobnicate)
    @test_throws ArgumentError Metal.ReflectionObject(:BufferArg; frobnicate=1)
    @test_throws ArgumentError Metal.ReflectionObject(:BufferArg; access_qualifier=:Frobnicate)
    @test_throws ArgumentError Metal.reflection_data(arg)
    # (objects must have the type of their field)
    @test_throws ArgumentError Metal.reflection_data(Metal.ReflectionObject(:Reflection; nodes=[arg]))
    @test_throws ArgumentError Metal.ReflectionObject(:Node; node=Metal.ReflectionObject(:UIntValue))

    # nodes of an unknown kind can't be encoded
    lib = parse(MetalLib, joinpath(metallib_dir, "visible.26.metallib"))
    data = copy(lib.functions[1].reflection_data)
    tag = findfirst(reinterpret(UInt8, [UInt32(266240)]), data)   # ThreadPositionInGridArg
    data[tag] .= reinterpret(UInt8, [UInt32(999999)])
    @test_throws ArgumentError Metal.reflection_data(Metal.reflection(data))
end

@static if VERSION >= v"1.11"
    @testset "public API" begin
        for name in (:MetalLib, :MetalLibFunction, :FunctionConstant, :DebugInfo,
                     :MetalLibFormatError, :reflection, :reflection_data, :ReflectionObject,
                     :ReflectionEnum, :UnknownReflectionNode, :FlatBufferError)
            @test Base.ispublic(Metal, name)
        end
    end
end
