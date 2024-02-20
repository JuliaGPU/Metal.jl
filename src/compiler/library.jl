# support for reading and writing Metal libraries
#
# see also:
# - https://github.com/YuAo/MetalLibraryArchive
# - floor library
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/lib/Bitcode/MetalLib/MetalLibWriterPass.cpp
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/tools/metallib-dis/metallib-dis.cpp

using SHA: sha256
using CEnum: @cenum
using StructIO: StructIO, @io, pack, unpack
using UUIDs: UUID, uuid1
using Printf: @printf


## binary datastructures

# these map directly on the data in Metal libraries

# XXX: this doesn't seem correct
@cenum TargetPlatform::UInt16 begin
    PLATFORM_MACOS  = 0x8001
    PLATFORM_IOS    = 0x0001
end

@cenum OSType::UInt8 begin
    OS_UNKNOWN              = 0x00
    OS_MACOS                = 0x81
    OS_IOS                  = 0x82
    OS_TVOS                 = 0x83
    OS_WATCHOS              = 0x84
    OS_BRIDGEOS             = 0x85
    OS_MACCATALYST          = 0x86
    OS_IOS_SIMULATOR        = 0x87
    OS_TVOS_SIMULATOR       = 0x88
    OS_WATCHOS_SIMULATOR    = 0x89
end

@cenum LibraryType::UInt8 begin
    LIBRARY_EXECUTABLE          = 0
    LIBRARY_CORE_IMAGE          = 1
    LIBRARY_DYNAMIC             = 2
    LIBRARY_SYMBOL_COMPANION    = 3
end

@cenum ProgramType::UInt8 begin
    PROGRAM_VERTEX       = 0
    PROGRAM_FRAGMENT     = 1
    PROGRAM_KERNEL       = 2
    PROGRAM_UNQUALIFIED  = 3
    PROGRAM_VISIBLE      = 4
    PROGRAM_EXTERN       = 5
    PROGRAM_INTERSECTION = 6
    PROGRAM_NONE         = 255
end

@io struct MetalLibHeader
    magic::NTuple{4,Cchar}

    platform::TargetPlatform

    library_major::UInt16
    library_minor::UInt8
    library_patch::UInt8
    library_type::LibraryType

    os_type::OSType
    os_major::UInt16
    os_minor::UInt8
    os_patch::UInt8

    file_size::UInt64

    function_list_offset::UInt64
    function_list_size::UInt64

    public_md_offset::UInt64
    public_md_size::UInt64

    private_md_offset::UInt64
    private_md_size::UInt64

    bitcode_offset::UInt64
    bitcode_size::UInt64
end

function Base.show(io::IO, header::MetalLibHeader)
    library_version = VersionNumber(header.library_major, header.library_minor, header.library_patch)
    os_version = VersionNumber(header.os_major, header.os_minor, header.os_patch)

    print_location(name, offset, size) = @printf(io, "  %s: %s at [0x%x, 0x%x[", name, Base.format_bytes(size), offset, offset+size)

    println(io, "MetalLibHeader($(header.library_type) v$(library_version)):")
    println(io, "  platform: $(header.platform)")
    println(io, "  target OS: $(header.os_type) v$(header.os_major).$(header.os_minor).$(header.os_patch)")
    println(io, "  file size: $(Base.format_bytes(header.file_size))")
    print_location("function list", header.function_list_offset, header.function_list_size)
    println(io)
    print_location("public metadata", header.public_md_offset, header.public_md_size)
    println(io)
    print_location("private metadata", header.private_md_offset, header.private_md_size)
    println(io)
    print_location("bitcode", header.bitcode_offset, header.bitcode_size)
end


## logical datastructures

struct MetalLibFunction
    name::String

    public_md::Vector{UInt8}    # unknown
    private_md::Vector{UInt8}   # unknown
    bitcode::Vector{UInt8}      # binary LLVM IR

    # AIR version support:
    # - v2.6: macOS 14+
    # - v2.5: macOS 13+
    # - v2.4: macOS 12+
    # - v2.3: macOS 11+
    # - v2.2: macOS 10.15+
    # - v2.1: macOS 10.14+
    # - v2.0: macOS 10.13+
    air_version::VersionNumber

    # Metal version support:
    # - v3.1: macOS 14+
    # - v3.0: macOS 13+
    # - v2.4: macOS 12+
    # - v2.3: macOS 11+
    # - v2.2: macOS 10.15+
    # - v2.1: macOS 10.14+
    # - v2.0: macOS 10.13+
    metal_version::VersionNumber
end
function MetalLibFunction(name::String, bitcode;
                          public_md = UInt8[], private_md = UInt8[],
                          air_version::VersionNumber, metal_version::VersionNumber)
    MetalLibFunction(name, public_md, private_md, bitcode, air_version, metal_version)
end

Base.@kwdef struct MetalLib
    platform::TargetPlatform=PLATFORM_MACOS

    # even though Metal.jl only supports macOS 13+, which supports metallib v2.7, we don't
    # fully support this format yet and fall back to v2.6 for now. this matches macOS 12,
    # but does support AIR/Metal v2.5/v3.0, as opposed to v2.4/v2.4 by macOS 12.
    version::VersionNumber=v"2.6"
    type::LibraryType=LIBRARY_EXECUTABLE

    os_type::OSType=OS_MACOS
    platform_version::VersionNumber=v"13"

    functions::Vector{MetalLibFunction}
end


## parsing functionality

function Base.read(io::IO, ::Type{MetalLib})
    header = unpack(io, MetalLibHeader)
    if Char.(header.magic) != ('M', 'T', 'L', 'B')
        throw(ArgumentError("Not a Metal library"))
    end

    function read_taggroup(read)
        tags = []
        while true
            tag_name = String(read(io, 4*sizeof(Cchar)))
            if tag_name == "ENDT"
                break
            end
            tag_size = read(io, UInt16)
            tag_data = read(io, tag_size)

            # parse tags
            ## function list tags
            if tag_name == "NAME"
                push!(tags, :name => String(tag_data[1:end-1]))
            elseif tag_name == "TYPE"
                push!(tags, :type => only(reinterpret(ProgramType, tag_data)))
            elseif tag_name == "HASH"
                push!(tags, :hash => bytes2hex(tag_data))
            elseif tag_name == "OFFT"
                offsets = reinterpret(UInt64, tag_data)
                @assert length(offsets) == 3
                push!(tags, :offsets => (;
                    public_md = offsets[1],
                    private_md = offsets[2],
                    bitcode = offsets[3])
                )
            elseif tag_name == "SOFF"
                push!(tags, :source_offset => only(reinterpret(UInt64, tag_data)))
            elseif tag_name == "VERS"
                vers = reinterpret(UInt16, tag_data)
                @assert length(vers) == 4
                push!(tags, :versions => (;
                    air   = VersionNumber(vers[1], vers[2]),
                    metal = VersionNumber(vers[3], vers[4]))
                )
            elseif tag_name == "MDSZ"
                push!(tags, :bitcode_size => only(reinterpret(UInt64, tag_data)))
            elseif tag_name == "RFLT"
                push!(tags, :rflt => only(reinterpret(UInt64, tag_data)))
            ## header extension tags
            elseif tag_name == "RLST"
                section_info = reinterpret(UInt64, tag_data)
                @assert length(section_info) == 2
                push!(tags, :reflection => (; offset=section_info[1], size=section_info[2]))
            elseif tag_name == "UUID"
                push!(tags, :uuid => UUID(only(reinterpret(UInt128, tag_data))))
            ## reflection lists
            elseif tag_name == "RBUF"
                # XXX: there's a 2 byte mismatch between the reflection list size, and the
                #      next ENDT token... bug in air-lld? let's eagerly read those bytes.
                append!(tag_data, read(io, 2))
                push!(tags, :reflection_buffer => tag_data)
            else
                @warn "unknown tag: $tag_name" tag_size tag_data
            end
        end
        return NamedTuple(tags)
    end

    # generate a custom `read` function that also checks we don't over-read the section
    function checked_reader(io, maxpos, name)
        function reader(io, args...)
            ret = read(io, args...)
            if position(io) > maxpos
                throw(EOFError())
            end
            return ret
        end
    end

    # function list
    function_list = []
    seek(io, header.function_list_offset)
    let read = checked_reader(io, header.function_list_offset + header.function_list_size, "function list")
        entry_count = read(io, UInt32)
        for i in 1:entry_count
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(function_list, read_taggroup(read))
            end
        end
    end

    # header extension, if any
    header_ex = if position(io) < header.public_md_offset
        # the header extension group isn't preceded by a size field
        let read = checked_reader(io, header.public_md_offset, "header extension")
            read_taggroup(read)
        end
    else
        nothing
    end

    # public md
    public_md = []
    let read = checked_reader(io, header.private_md_offset, "public metadata")
        for i in 1:length(function_list)
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(public_md, read_taggroup(read))
            end
        end
    end

    # private_md
    @assert position(io) == header.private_md_offset
    private_md = []
    let read = checked_reader(io, header.bitcode_offset, "private metadata")
        for i in 1:length(function_list)
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(private_md, read_taggroup(read))
            end
        end
    end

    # bitcode
    @assert position(io) == header.bitcode_offset
    bitcode = []
    let read = checked_reader(io, header.bitcode_offset + header.bitcode_size, "bitcode")
        for i in 1:length(function_list)
            bitcode_size = function_list[i].bitcode_size
            push!(bitcode, read(io, bitcode_size))
        end
    end

    # reflection list
    reflection_list = []
    if header_ex !== nothing && haskey(header_ex, :reflection)
        seek(io, header_ex.reflection.offset)
        let read = checked_reader(io, header_ex.reflection.offset + header_ex.reflection.size, "reflection")
            num_lists = read(io, UInt32)
            for i in 1:num_lists
                list_start = position(io)
                list_size = read(io, UInt32)
                let read = checked_reader(io, list_start + list_size, "reflection sublist")
                    push!(reflection_list, read_taggroup(read))
                end
            end
        end
    end

    # reconstruct objects
    functions = MetalLibFunction[]
    for i in 1:length(function_list)
        push!(functions, MetalLibFunction(
            function_list[i].name,
            bitcode[i];
            air_version=function_list[i].versions.air,
            metal_version=function_list[i].versions.metal
        ))
    end

    MetalLib(;
        header.platform,
        version=VersionNumber(header.library_major, header.library_minor, header.library_patch),
        type=header.library_type,
        header.os_type,
        platform_version=VersionNumber(header.os_major, header.os_minor, header.os_patch),
        functions)
end


## emission functionality

function emit_tag_group(io::IO, data::Vector; emit_size=true)
    # emit the tags and their values
    tag_stream = IOBuffer()
    for (tag, value) in data
        emit_tag(tag_stream, tag, value)
    end
    emit_tag(tag_stream, "ENDT")
    tag_group = take!(tag_stream)

    # emit the tag group
    if emit_size
        # the size of the tag group includes the size bytes itself
        write(io, UInt32(sizeof(tag_group) + sizeof(UInt32)))
    end
    write(io, tag_group)
    return io
end

function emit_tag(io::IO, tag::String, value=nothing)
    # emit the tag
    @assert length(tag) == 4
    write(io, tag)

    # helpers for emitting the value
    write_len(len) = write(io, UInt16(len))
    function write_value(value, T=typeof(value))
        value = convert(T, value)
        write_len(sizeof(value))
        write(io, value)
    end

    # emit the value
    if tag == "NAME"
        # Name of the function
        isa(value, String) || throw(ArgumentError("Name must be a string"))
        length(value) <= typemax(UInt16)-1 || throw(ArgumentError("Name too long"))
        write_len(length(value) + 1)
        write(io, value)
        write(io, UInt8(0))
    elseif tag == "MDSZ"
        # Size of the bitcode
        write_value(value, UInt64)
    elseif tag == "TYPE"
        # Type of the function
        write_value(value, UInt8)
    elseif tag == "HASH"
        # Hash of the bitcode data (SHA256)
        if !isa(value, Vector) || sizeof(value) != 32
            throw(ArgumentError("Hash must be a 32-byte vector"))
        end
        write_value(value)
    elseif tag == "OFFT"
        # Offsets of the information about this function in the public metadata section,
        # private metadata section, and bitcode section
        write_value(UInt64[value.public_md, value.private_md, value.bitcode])
    elseif tag == "SOFF"
        # Offset of the source code archive of the function in the embedded source code
        # section
        write_value(value, UInt64)
    elseif tag == "VERS"
        # Bitcode and language versions (air.major, air.minor, metal.major, metal.minor)
        write_value(UInt16[value.air.major, value.air.minor,
                           value.metal.major, value.metal.minor])
    elseif tag == "LAYR"
        # Metal type of the render_target_array_index (for layered rendering)
        write_value(value, UInt8)
    elseif tag == "TESS"
        # Patch type and number of control points per-patch (for post-tessellation vertex
        # function)
        write_value(value, UInt8)
    elseif tag == "RFLT"
        # Unknown tag; added in Metal 2.7
        write_value(value, UInt64)
    elseif tag == "ENDT"
        # End of the tag group
        if value !== nothing
            throw(ArgumentError("ENDT tag must not have a value"))
        end
    elseif tag == "UUID"
        # UUID of the Metal library
        if !isa(value, UUID)
            throw(ArgumentError("UUID must be a UUID"))
        end
        bits = convert(Tuple{UInt64,UInt64}, value)
        write_len(16)
        write(io, bits[1])
        write(io, bits[2])
    elseif tag == "RLST"
        # Unknown section; added in Metal 2.7
        write_value(UInt64[value.offset, value.size])
    else
        throw(ArgumentError("Unknown tag: $tag"))
    end
end

# write a metallib archive containing one or more bitcode functions
#
# this is supposed to be compatible with the output from the metal compiler:
# $ xcrun metal -mmacosx-version-min=12 input.metal -o output.metallib
#
# TODO:
# - fully support metallib v2.7: RFLT, reflection list
# - fix UUID computation
# - figure out which LLVM IR version AIR v2.5 corresponds to
function Base.write(io::IO, lib::MetalLib)
    ## section contents

    public_md_stream = IOBuffer()
    private_md_stream = IOBuffer()
    bitcode_stream = IOBuffer()

    tag_groups = []

    for fun in lib.functions
        # TODO: public metadata
        public_md_offset = position(public_md_stream)
        emit_tag_group(public_md_stream, [])

        # TODO: private metadata
        private_md_offset = position(private_md_stream)
        emit_tag_group(private_md_stream, [])

        # bitcode
        bitcode_offset = position(bitcode_stream)
        bitcode_hash = sha256(fun.bitcode)
        bitcode_size = sizeof(fun.bitcode)
        write(bitcode_stream, fun.bitcode)

        # tags
        tags = [
            "NAME" => fun.name,
            "TYPE" => PROGRAM_KERNEL,
            "HASH" => bitcode_hash,
            "OFFT" => (; public_md=public_md_offset,
                         private_md=private_md_offset,
                         bitcode=bitcode_offset),
            "VERS" => (; air=fun.air_version, metal=fun.metal_version),
            "MDSZ" => bitcode_size,
        ]
        if lib.version >= v"2.7"
            # XXX: placeholder; this data is invalid
            push!(tags, "RFLT" => 0)
        end
        tag_stream = IOBuffer()
        emit_tag_group(tag_stream, tags)
        push!(tag_groups, take!(tag_stream))
    end

    function_list_stream = IOBuffer()
    write(function_list_stream, UInt32(length(lib.functions)))
    for tags in tag_groups
        write(function_list_stream, tags)
    end

    function_list = take!(function_list_stream)
    function_list_size = sizeof(function_list)

    # header extensions
    if lib.version >= v"2.3"
        tags = []
        if lib.version >= v"2.7"
            # XXX: placeholder; this data is invalid
            push!(tags, "RLST" => (; offset=0, size=0))
        end
        # XXX: placeholder; this data is invalid
        #      it should be a UUID based on all of the module's data
        push!(tags, "UUID" => uuid1())

        header_ex_stream = IOBuffer()
        emit_tag_group(header_ex_stream, tags; emit_size=false)
        header_ex = take!(header_ex_stream)
        header_ex_size = sizeof(header_ex)
    else
        header_ex = UInt8[]
        header_ex_size = 0
    end

    public_md = take!(public_md_stream)
    public_md_size = sizeof(public_md)

    private_md = take!(private_md_stream)
    private_md_size = sizeof(private_md)

    bitcode = take!(bitcode_stream)
    bitcode_size = sizeof(bitcode)

    file_size = sizeof(MetalLibHeader) + function_list_size + header_ex_size + public_md_size + private_md_size + bitcode_size


    ## header

    # calculate section offsets
    function_list_offset = sizeof(MetalLibHeader)
    public_md_offset = function_list_offset + function_list_size + header_ex_size
    private_md_offset = public_md_offset + public_md_size
    bitcode_offset = private_md_offset + private_md_size

    # the function list size excludes the size field at the start, but it is included in
    # other offset calculations, so only substract it here. this isn't very nice; instead
    # we could just determine the offsets by backpatching them after writing the sections.
    function_list_size -= sizeof(UInt32)

    header = MetalLibHeader(
        ('M', 'T', 'L', 'B'),
        lib.platform,
        lib.version.major,
        lib.version.minor,
        lib.version.patch,
        lib.version < v"2.4" ? LIBRARY_EXECUTABLE : lib.type,
        lib.version < v"2.6" ? OS_UNKNOWN : lib.os_type,
        lib.version < v"2.6" ? 0 : lib.platform_version.major,
        lib.version < v"2.6" ? 0 : lib.platform_version.minor,
        lib.version < v"2.6" ? 0 : lib.platform_version.patch,
        file_size,
        function_list_offset,
        function_list_size,
        public_md_offset,
        public_md_size,
        private_md_offset,
        private_md_size,
        bitcode_offset,
        bitcode_size
    )

    pack(io, header)


    ## write sections

    # function list
    @assert position(io) == function_list_offset
    write(io, function_list)

    # header extension
    # @assert position(io) == function_list_offset + function_list_size
    write(io, header_ex)

    # public metadata
    @assert position(io) == public_md_offset
    write(io, public_md)

    # private metadata
    @assert position(io) == private_md_offset
    write(io, private_md)

    # module list
    @assert position(io) == bitcode_offset
    write(io, bitcode)

    # TODO: sources

    # TODO: dynamic header

    # TODO: variable list

    # TODO: imported symbol list

    # TODO: reflection list

    # TODO: script list

    @assert position(io) == file_size
end
