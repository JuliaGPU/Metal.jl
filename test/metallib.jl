# test that we can parse and regenerate Metal libraries accurately

using Metal: MetalLibFunction, MetalLib, MetalLibFormatError, content_uuid
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

    # stub libraries, which only describe their functions, are not supported
    bytes = read(joinpath(metallib_dir, "kernel.26.metallib"))
    mdsz = findfirst(codeunits("MDSZ"), bytes)
    bytes[mdsz] .= codeunits("XDSZ")
    err = try read(IOBuffer(bytes), MetalLib) catch err; err end
    @test err isa MetalLibFormatError
    @test contains(sprint(showerror, err), "stub")
end

@static if VERSION >= v"1.11"
    @testset "public API" begin
        for name in (:MetalLib, :MetalLibFunction, :FunctionConstant, :DebugInfo,
                     :MetalLibFormatError)
            @test Base.ispublic(Metal, name)
        end
    end
end
