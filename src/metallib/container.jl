# support for reading and writing Metal libraries
#
# see also:
# - https://github.com/YuAo/MetalLibraryArchive
# - floor library
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/lib/Bitcode/MetalLib/MetalLibWriterPass.cpp
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/tools/metallib-dis/metallib-dis.cpp
#
# parts of the format we read but do not generate:
# - reflection data: the official toolchain gives every function an RBUF reflection
#   buffer, a flatbuffer (identifier "AIRR", payload 16-byte aligned within the file)
#   describing the function's signature. the schemas are embedded as binary flatbuffer
#   schemas (BFBS) in the Metal toolchain binaries, and use a double-table scheme where
#   each node is a small table holding the node type and an offset to the type-specific
#   table. floor implements writing these; see metal_reflection_{types,writing}.hpp there.
# - script lists (SLST section, SBUF buffers), recording pipeline descriptor scripts;
#   compare with `metal-source -flatbuffers=json`
#
# parts we do not support at all:
# - compressed reflection buffers (RBUZ)
# - dynamic libraries and symbol companions: variable lists and imported/exported symbol
#   lists (the install name maps onto the dynamic header's NAME tag, which we do support)
# - graphics-related metadata: vertex attributes (VATT/VATY tags), tessellation (TESS)

using CEnum: @cenum
using UUIDs: UUID


## enums

@cenum FileType::UInt8 begin
    FILE_EXECUTABLE          = 0
    FILE_CORE_IMAGE          = 1
    FILE_DYNAMIC             = 2
    FILE_SYMBOL_COMPANION    = 3
end

# https://github.com/llvm/llvm-project/blob/main/llvm/include/llvm/BinaryFormat/MachO.def
@cenum PlatformType::UInt8 begin
    PLATFORM_UNKNOWN              = 0
    PLATFORM_MACOS                = 1
    PLATFORM_IOS                  = 2
    PLATFORM_TVOS                 = 3
    PLATFORM_WATCHOS              = 4
    PLATFORM_BRIDGEOS             = 5
    PLATFORM_MACCATALYST          = 6
    PLATFORM_IOS_SIMULATOR        = 7
    PLATFORM_TVOS_SIMULATOR       = 8
    PLATFORM_WATCHOS_SIMULATOR    = 9
    PLATFORM_DRIVERKIT            = 10
    PLATFORM_XROS                 = 11
    PLATFORM_MACOS_SIMULATOR      = 12
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


## tag groups

# a helper type for reading and writing tag groups
Base.@kwdef mutable struct TagGroup
    data::Vector{Pair{String,Any}}=Pair{String,Any}[]   # like an ordered dict

    offsets::Dict{String,Int} = Dict()

    # the size of each tag's size fields in the tag group
    size_type::Type=UInt16

    # whether the tag group starts with a 32-bit size field for the entire group
    has_size::Bool=true

    # whether the tag group size field is included in the size. the compiler driver and
    # air-lld include it, but Apple's standalone `metallib` tool does not for metadata
    # groups, so the reader detects and records which convention a group uses.
    counts_size::Bool=true
end

# Dict-like methods to interact with a tag group
function Base.get(tg::TagGroup, tag::String, default)
    for (key, value) in tg.data
        if key == tag
            return value
        end
    end
    return default
end
function Base.haskey(tg::TagGroup, tag::String)
    value = get(tg, tag, nothing)
    return value !== nothing
end
function Base.getindex(tg::TagGroup, tag::String)
    value = get(tg, tag, nothing)
    if value === nothing
        throw(KeyError(tag))
    end
    return value
end
function Base.setindex!(tg::TagGroup, value, tag::String)
    @assert value !== nothing
    if haskey(tg, tag)
        throw(ArgumentError("Tag $tag already exists"))
    end
    push!(tg.data, tag => value)
end

# look up the offset of a tag
function offsetof(tg::TagGroup, tag::String)
    if !haskey(tg, tag)
        throw(KeyError(tag))
    end
    return tg.offsets[tag]
end

# for processing tag values: expected type, read function (io, nb), write function (io, val)
const tag_value_io = Dict()
## function list
tag_value_io["NAME"] = (
    # Name of the function; a null-terminated string
    String,
    (io, _)   -> String(readuntil(io, UInt8(0))),
    (io, val) -> begin
        length(val) <= typemax(UInt16)-1 || throw(ArgumentError("Name too long"))
        write(io, val)
        write(io, UInt8(0))
    end)
tag_value_io["TYPE"] = (
    # Type of the function; 1 byte
    ProgramType,
    (io, _)   -> read(io, ProgramType),
    (io, val) -> write(io, UInt8(val)))
tag_value_io["HASH"] = (
    # Hash of the module data; 32 bytes (SHA-256)
    Vector{UInt8},
    (io, nb)  -> read(io, nb),
    (io, val) -> write(io, val))
tag_value_io["OFFT"] = (
    # Offsets of the information about this function in the public metadata section,
    # private metadata section, and module section; Each offset is a 64-bit unsigned integer
    @NamedTuple{public_md::UInt64, private_md::UInt64, air_module::UInt64},
    (io, _)   -> (; public_md=read(io, UInt64),
                    private_md=read(io, UInt64),
                    air_module=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.public_md, val.private_md, val.air_module]))
tag_value_io["SOFF"] = (
    # Offset of the source code archive of the function in the embedded source code section;
    # a 64-bit unsigned integer
    UInt64,
    (io, _)   -> read(io, UInt64),
    (io, val) -> write(io, val))
tag_value_io["VERS"] = (
    # Module and language versions (air.major, air.minor, language.major, language.minor);
    # 4 x 16-bit unsigned integers
    @NamedTuple{air::VersionNumber, metal::VersionNumber},
    (io, _)   -> (; air=VersionNumber(read(io, UInt16), read(io, UInt16)),
                    metal=VersionNumber(read(io, UInt16), read(io, UInt16))),
    (io, val) -> write(io, UInt16[val.air.major, val.air.minor,
                                  val.metal.major, val.metal.minor]))
tag_value_io["MDSZ"] = (
    # Size of the module; a 64-bit unsigned integer
    UInt64,
    (io, _)   -> read(io, UInt64),
    (io, val) -> write(io, val))
tag_value_io["RFLT"] = (
    # Offset of the reflection list of the function in the reflection list section;
    # a 64-bit unsigned integer
    UInt64,
    (io, _)   -> read(io, UInt64),
    (io, val) -> write(io, val))
## header extension
tag_value_io["HSRC"] = (
    # Offset and size of the embedded source code section; 2 x 64-bit unsigned integers
    @NamedTuple{offset::UInt64, size::UInt64},
    (io, _)   -> (; offset=read(io, UInt64), size=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.offset, val.size]))
tag_value_io["HSRD"] = tag_value_io["HSRC"]
tag_value_io["HDYN"] = (
    # Offset and size of the dynamic header section; 2 x 64-bit unsigned integers
    @NamedTuple{offset::UInt64, size::UInt64},
    (io, _)   -> (; offset=read(io, UInt64), size=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.offset, val.size]))
tag_value_io["RLST"] = (
    # Offset and size of the reflection list section; 2 x 64-bit unsigned integers
    @NamedTuple{offset::UInt64, size::UInt64},
    (io, _)   -> (; offset=read(io, UInt64), size=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.offset, val.size]))
tag_value_io["SLST"] = (
    # Offset and size of the script list section; 2 x 64-bit unsigned integers
    @NamedTuple{offset::UInt64, size::UInt64},
    (io, _)   -> (; offset=read(io, UInt64), size=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.offset, val.size]))
tag_value_io["UUID"] = (
    # UUID of the module; 16 bytes in RFC 4122 (big-endian) order
    UUID,
    (io, _)   -> UUID(ntoh(read(io, UInt128))),
    (io, val) -> write(io, hton(val.value)))
## reflection lists
tag_value_io["RBUF"] = (
    # Reflection buffer: zero-padding to align the payload to 16 bytes within the file,
    # followed by a flatbuffer with an "AIRR" identifier (see the format notes up top)
    Vector{UInt8},
    (io, nb) -> begin
        read(io, nb)
    end,
    (io, val) -> write(io, val))
## script lists
tag_value_io["SBUF"] = (
    # Script buffer; a flatbuffer describing pipeline descriptor scripts
    Vector{UInt8},
    (io, nb) -> begin
        read(io, nb)
    end,
    (io, val) -> write(io, val))

# unlike other tags, buffer tags encode the size of their value as a 32-bit field,
# presumably so that their contents can outgrow the 16-bit size limit
const wide_size_tags = ["RBUF", "SBUF"]

function Base.read!(io::IO, tg::TagGroup)
    if tg.has_size
        group_start = position(io)
        group_size = read(io, UInt32)
    end

    while true
        # read the tag name
        tag_name = String(read(io, 4*sizeof(Cchar)))
        if tag_name == "ENDT"
            break
        end

        # read the value size and note our position
        value_size = if tag_name in wide_size_tags
            read(io, UInt32)
        else
            read(io, tg.size_type)
        end
        tg.offsets[tag_name] = position(io)

        if !haskey(tag_value_io, tag_name)
            @warn "Unknown tag: $tag_name"
            skip(io, value_size)
            continue
        end

        # read and parse the value
        value_type, value_parser, _ = tag_value_io[tag_name]
        value = value_parser(io, value_size)
        isa(value, value_type) || error("Value for tag $tag_name has type $(typeof(value)), expected $value_type")
        tg[tag_name] = value

        # ensure we consumed the entire value
        @assert position(io) == tg.offsets[tag_name] + value_size
    end

    # ensure we consumed the entire group
    if tg.has_size
        group_end = position(io)
        if group_end == group_start + group_size
            tg.counts_size = true
        elseif group_end == group_start + sizeof(UInt32) + group_size
            tg.counts_size = false
        else
            error("Tag group at offset $group_start ends at offset $group_end, " *
                  "which does not match its recorded size of $group_size bytes")
        end
    end

    return tg
end

function Base.write(io::IO, tg::TagGroup)
    # emit the data and their values
    group_data = let io=IOBuffer()
        for (tag, value) in tg.data
            # write the tag name
            @assert length(tag) == 4
            write(io, tag)

            # look up the tag and validate the value
            haskey(tag_value_io, tag) || error("Unknown tag $tag")
            value_type, _, value_writer = tag_value_io[tag]

            # serialize the value
            value_bytes = let io=IOBuffer()
                value_writer(io, convert(value_type, value))
                take!(io)
            end
            value_size = sizeof(value_bytes)

            # write the value size and the value itself
            if tag in wide_size_tags
                write(io, UInt32(value_size))
            else
                write(io, tg.size_type(value_size))
            end
            tg.offsets[tag] = position(io)
            write(io, value_bytes)
        end
        write(io, "ENDT")

        take!(io)
    end

    # emit the tag group
    if tg.has_size
        sz = sizeof(group_data)
        if tg.counts_size
            sz += sizeof(UInt32)
        end
        write(io, UInt32(sz))
    end
    write(io, group_data)

    return io
end
