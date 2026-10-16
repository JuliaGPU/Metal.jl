# test that we can parse and regenerate Metal libraries accurately

using Metal: MetalLibFunction, MetalLib, content_uuid
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
    @test_throws ErrorException read!(IOBuffer(bytes), Metal.TagGroup())
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
