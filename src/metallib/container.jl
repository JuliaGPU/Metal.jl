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
#   describing the function's signature. airr.jl decodes it; floor implements writing it,
#   see metal_reflection_{types,writing}.hpp there.
# - script lists (SLST section, SBUF buffers), recording pipeline descriptor scripts;
#   compare with `metal-source -flatbuffers=json`
#
# tags we do not decode, such as graphics-related metadata (vertex attributes in VATT/VATY,
# tessellation in TESS, layered rendering in LAYR) or compressed reflection buffers (RBUZ),
# are kept as raw bytes and written back unchanged.
#
# parts we do not support at all:
# - dynamic libraries and symbol companions: we keep variable lists (VLST) and imported symbol
#   lists (ILST) as raw bytes, and only decode the dynamic header's NAME tag (the install name)

using CEnum: @cenum
using UUIDs: UUID


## enums

# named like Apple's `metal-readobj` prints them

@cenum FileType::UInt8 begin
    METALLIB_EXECUTE    = 0
    METALLIB_CI         = 1     # Core Image kernels
    METALLIB_DYLIB      = 2
    METALLIB_COMPANION  = 3     # symbol companion (.metallibsym)
end

# the values match LLVM's Mach-O platforms (llvm/include/llvm/BinaryFormat/MachO.def)
@cenum PlatformType::UInt8 begin
    METALLIB_PLATFORM_MACOS             = 1
    METALLIB_PLATFORM_IOS               = 2
    METALLIB_PLATFORM_TVOS              = 3
    METALLIB_PLATFORM_WATCHOS           = 4
    METALLIB_PLATFORM_MACCATALYST       = 6
    METALLIB_PLATFORM_IOS_SIMULATOR     = 7
    METALLIB_PLATFORM_TVOS_SIMULATOR    = 8
    METALLIB_PLATFORM_WATCHOS_SIMULATOR = 9
    METALLIB_PLATFORM_XROS              = 11
    METALLIB_PLATFORM_XROS_SIMULATOR    = 12
end

@cenum ProgramType::UInt8 begin
    METALLIB_VERTEX_FUNCTION        = 0
    METALLIB_FRAGMENT_FUNCTION      = 1
    METALLIB_COMPUTE_FUNCTION       = 2
    METALLIB_UNQUALIFIED_FUNCTION   = 3
    METALLIB_VISIBLE_FUNCTION       = 4
    METALLIB_CI_FUNCTION            = 5
    METALLIB_INTERSECTION_FUNCTION  = 6
    METALLIB_MESH_FUNCTION          = 7
    METALLIB_OBJECT_FUNCTION        = 8
end


## errors

"""
    MetalLibFormatError

Thrown when reading a Metal library that is malformed or that uses parts of the format
Metal.jl does not support. `offset` is the position in the library where the problem was
detected, if known.
"""
struct MetalLibFormatError <: Exception
    msg::String
    offset::Union{Nothing,Int}
end
MetalLibFormatError(msg) = MetalLibFormatError(msg, nothing)

function Base.showerror(io::IO, err::MetalLibFormatError)
    print(io, "MetalLibFormatError: ", err.msg)
    err.offset === nothing || print(io, " (at offset ", err.offset, ")")
end

format_check(cond::Bool, msg, offset=nothing) =
    cond || throw(MetalLibFormatError(msg, offset === nothing ? nothing : Int(offset)))


## tag groups

# a tag value we keep as raw bytes: either the tag is unknown to us, or its decoded value
# would not encode back to the same bytes (e.g. because of trailing data we don't parse)
struct RawTag
    data::Vector{UInt8}
end

# a helper type for reading and writing tag groups
Base.@kwdef mutable struct TagGroup
    # the tags in order, with decoded values or as `RawTag`s. like an ordered dict, but
    # tags can repeat
    data::Vector{Pair{String,Any}}=Pair{String,Any}[]

    offsets::Dict{String,Int} = Dict()

    # the size of each tag's size fields in the tag group
    size_type::Type=UInt16

    # whether the tag group starts with a 32-bit size field for the entire group
    has_size::Bool=true

    # whether the tag group size field is included in the size. the compiler driver and
    # air-lld include it, but Apple's standalone `metallib` tool does not for metadata
    # groups, so the reader detects and records which convention a group uses.
    counts_size::Bool=true

    # when read: where the group starts and ends, and the position and size of each value
    # (for inspecting libraries; positions are relative to the stream the group was read from)
    extent::Union{Nothing,UnitRange{Int}} = nothing
    value_extents::Vector{UnitRange{Int}} = UnitRange{Int}[]
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
# offset and size of the variable list and imported symbol list sections of dynamic
# libraries and the libraries linking against them, which we keep as raw bytes;
# 2 x 64-bit unsigned integers
tag_value_io["VLST"] = tag_value_io["RLST"]
tag_value_io["ILST"] = tag_value_io["RLST"]
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
# presumably so that their contents can outgrow the 16-bit size limit. RBUZ holds a
# BZip2-compressed reflection buffer (emitted by `air-lld --compress-sections`, together with
# an RBSZ tag with the uncompressed size); we keep it as raw bytes.
const wide_size_tags = ["RBUF", "RBUZ", "SBUF"]

function encode_tag(tag::String, value)
    value isa RawTag && return value.data
    haskey(tag_value_io, tag) || error("Unknown tag $tag")
    value_type, _, value_writer = tag_value_io[tag]
    io = IOBuffer()
    value_writer(io, convert(value_type, value))
    return take!(io)
end

# decode a tag value, keeping it as raw bytes unless it re-encodes identically: the file
# format is only partially documented, and we must be able to write back what we read
function decode_tag(tag::String, bytes::Vector{UInt8})
    if !haskey(tag_value_io, tag)
        @debug "Keeping unknown metallib tag $tag as raw bytes"
        return RawTag(bytes)
    end
    value_type, value_parser, _ = tag_value_io[tag]
    value = try
        value_parser(IOBuffer(bytes), sizeof(bytes))
    catch err
        # a value we cannot parse is kept as raw bytes too
        err isa InterruptException && rethrow()
        nothing
    end
    if !isa(value, value_type) || encode_tag(tag, value) != bytes
        @debug "Keeping metallib tag $tag as raw bytes, as its value does not round-trip"
        return RawTag(bytes)
    end
    return value
end

function Base.read!(io::IO, tg::TagGroup)
    start = position(io)
    if tg.has_size
        group_start = position(io)
        group_size = read(io, UInt32)
    end

    while true
        # read the tag name
        tag_name = String(read(io, 4*sizeof(Cchar)))
        sizeof(tag_name) == 4 || throw(EOFError())
        if tag_name == "ENDT"
            break
        end

        # read the value size and note our position
        value_size = if tag_name in wide_size_tags
            read(io, UInt32)
        else
            read(io, tg.size_type)
        end
        # (like values, offsets are those of a tag's first occurrence)
        haskey(tg.offsets, tag_name) || (tg.offsets[tag_name] = position(io))
        push!(tg.value_extents, position(io) .+ (0:Int(value_size)-1))
        value_bytes = read(io, value_size)
        sizeof(value_bytes) == value_size || throw(EOFError())

        # we only decode the first occurrence of a tag, as that's the one we use
        value = if haskey(tg, tag_name)
            RawTag(value_bytes)
        else
            decode_tag(tag_name, value_bytes)
        end
        push!(tg.data, tag_name => value)
    end

    # ensure we consumed the entire group
    if tg.has_size
        group_end = position(io)
        if group_end == group_start + group_size
            tg.counts_size = true
        elseif group_end == group_start + sizeof(UInt32) + group_size
            tg.counts_size = false
        else
            throw(MetalLibFormatError("tag group ends at offset $group_end, which does not " *
                                      "match its size of $group_size bytes", group_start))
        end
    end
    tg.extent = start:position(io)-1

    return tg
end

function Base.write(io::IO, tg::TagGroup)
    empty!(tg.offsets)
    # emit the data and their values
    group_data = let io=IOBuffer()
        for (tag, value) in tg.data
            # write the tag name
            @assert length(tag) == 4
            write(io, tag)

            value_bytes = encode_tag(tag, value)
            value_size = sizeof(value_bytes)

            # write the value size and the value itself
            if tag in wide_size_tags
                write(io, UInt32(value_size))
            else
                write(io, tg.size_type(value_size))
            end
            haskey(tg.offsets, tag) || (tg.offsets[tag] = position(io))
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
