# support for reading and writing Metal libraries
#
# see also:
# - https://github.com/YuAo/MetalLibraryArchive
# - floor library
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/lib/Bitcode/MetalLib/MetalLibWriterPass.cpp
#   https://github.com/a2flo/floor_llvm/blob/floor_toolchain_1406/llvm/tools/metallib-dis/metallib-dis.cpp
#
# TODO:
# - fully support metallib v2.7: RFLT, reflection list
# - fix UUID computation to be based on the module's data
# - figure out which LLVM IR version AIR v2.5 corresponds to

using SHA: sha256
using CEnum: @cenum
using UUIDs: UUID, uuid1
using Printf: @printf
using CodecBzip2: transcode, Bzip2Compressor, Bzip2Decompressor


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


## structures

struct FunctionConstant
    name::String
    datatype::MTL.MTLDataType
    index::Int
    active::Bool
end

struct DebugInfo
    line::Int
    path::String
end

struct EmbeddedSource
    link_options::String
    working_directory::Union{Nothing,String}
    archives::Vector{Pair{String,Vector{UInt8}}}
end

Base.@kwdef struct MetalLibFunction
    name::String
    air_version::VersionNumber
    metal_version::VersionNumber

    air_module::Vector{UInt8}

    source_id::Union{Nothing,String} = nothing

    # public metadata
    constants::Vector{FunctionConstant} = FunctionConstant[]

    # private metadata
    debug_info::Union{Nothing, DebugInfo} = nothing
    dependent_file::Union{Nothing, String} = nothing

    # reflection data
    reflection_data::Union{Nothing, Vector{UInt8}} = nothing
end

Base.@kwdef struct MetalLib
    # even though Metal.jl only supports macOS 13+, which supports metallib v1.2.7, we don't
    # fully support this format yet and fall back to v1.2.6 for now. this matches macOS 12,
    # but does support AIR/Metal v2.5/v3.0, as opposed to v2.4/v2.4 by macOS 12.
    file_version::VersionNumber=v"1.2.6"
    file_type::FileType=FILE_EXECUTABLE
    is_macos::Bool=true
    is_stub::Bool=false

    platform_version::VersionNumber=v"13"
    platform_type::PlatformType=PLATFORM_MACOS
    is_64bit::Bool=true

    uuid::Union{Nothing, UUID} = nothing

    functions::Vector{MetalLibFunction}
    embedded_source::Union{Nothing, EmbeddedSource} = nothing
end

function Base.show(io::IO, lib::MetalLib)
    println("MetalLib(")

    print("  file: $(lib.file_type) v$(lib.file_version)")
    file_flags = []
    if lib.is_macos
        push!(file_flags, "macOS")
    end
    if lib.is_stub
        push!(file_flags, "stub")
    end
    if !isempty(file_flags)
        print(" [$(join(file_flags, ", "))]")
    end
    println()

    print("  platform: $(lib.platform_type) v$(lib.platform_version)")
    platform_flags = []
    if lib.is_64bit
        push!(platform_flags, "64-bit")
    end
    if !isempty(platform_flags)
        print(" [$(join(platform_flags, ", "))]")
    end
    println()

    println("  functions:")

    for fun in lib.functions
        println("    $(fun.name) [AIR v$(fun.air_version), Metal v$(fun.metal_version)]")
    end

    print(")")
end


## tag groups

# a helper type for reading and writing tag groups
Base.@kwdef struct TagGroup
    data::Vector{Pair{String,Any}}=Pair{String,Any}[]   # like an ordered dict

    offsets::Dict{String,Int} = Dict()

    # the size of each tag's size fields in the tag group
    size_type::Type=UInt16

    # whether the tag group starts with a 32-bit size field for the entire group
    has_size::Bool=true

    # whether the tag group size field is included in the size
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
tag_value_io["RLST"] = (
    # Offset and size of the reflection list section; 2 x 64-bit unsigned integers
    @NamedTuple{offset::UInt64, size::UInt64},
    (io, _)   -> (; offset=read(io, UInt64), size=read(io, UInt64)),
    (io, val) -> write(io, UInt64[val.offset, val.size]))
tag_value_io["UUID"] = (
    # UUID of the module; 16 bytes
    UUID,
    (io, _)   -> begin
        uuid_bits = Vector{UInt64}(undef, 2)
        read!(io, uuid_bits)
        UUID(Tuple(uuid_bits))
    end,
    (io, val) -> begin
        bits = convert(Tuple{UInt64,UInt64}, val)
        write(io, UInt64[bits...])
    end)
## public metadata
tag_value_io["CNST"] = (
    # A list of function constants
    Vector{FunctionConstant},
    (io, _)   -> begin
        num_constants = read(io, UInt16)
        constants = Vector{FunctionConstant}(undef, num_constants)
        for i in 1:num_constants
            name = String(readuntil(io, UInt8(0)))
            datatype = MTL.MTLDataType(read(io, UInt8))
            index = read(io, UInt16)
            active = Bool(read(io, UInt8))

            constants[i] = FunctionConstant(name, datatype, index, active)
        end
        constants
    end,
    (io, val) -> begin
        write(io, UInt16(length(val)))
        for constant in val
            write(io, constant.name)
            write(io, UInt8(0))
            write(io, UInt8(constant.datatype))
            write(io, UInt16(constant.index))
            write(io, UInt8(constant.active))
        end
    end)
## private metadata
tag_value_io["DEBI"] = (
    # Debug information; line number and path of the source file
    DebugInfo,
    (io, _)   -> DebugInfo(read(io, UInt32), String(readuntil(io, UInt8(0)))),
    (io, val) -> begin
        write(io, UInt32(val.line))
        write(io, val.path)
        write(io, UInt8(0))
    end)
tag_value_io["DEPF"] = (
    # Path of the dependent file; a null-terminated string
    String,
    (io, _)   -> String(readuntil(io, UInt8(0))),
    (io, val) -> begin
        write(io, val)
        write(io, UInt8(0))
    end)
## embedded sources
tag_value_io["SARC"] = (
    # Source archive; an identifier (null-terminated ASCII) and BZip2-compressed tarball
    @NamedTuple{id::String, archive::Vector{UInt8}},
    (io, nb)  -> begin
        id = String(readuntil(io, UInt8(0)))
        compressed = read(io, nb - sizeof(id) - 1)

        # unpad and decompress the archive
        i = findlast(!iszero, compressed)
        archive = transcode(Bzip2Decompressor, compressed[1:i])

        (; id, archive)
    end,
    (io, val) -> begin
        write(io, val.id)
        write(io, UInt8(0))

        # compress and pad the archive
        compressed = transcode(Bzip2Compressor, val.archive)
        padding = 16*1024 - (sizeof(compressed) % (16*1024))
        compressed = vcat(compressed, Base.zeros(UInt8, padding))

        write(io, compressed)
    end)
## reflection lists
tag_value_io["RBUF"] = (
    # Reflection buffer
    Vector{UInt8},
    (io, nb)  -> begin
        read(io, nb)
    end,
    (io, val) -> write(io, val))

function Base.read!(io::IO, tg::TagGroup)
    if tg.has_size
        if tg.counts_size
            group_start = position(io)
        end
        group_size = read(io, UInt32)
        if !tg.counts_size
            group_start = position(io)
        end
    end

    while true
        # read the tag name
        tag_name = String(read(io, 4*sizeof(Cchar)))
        if tag_name == "ENDT"
            break
        end

        # read the value size and note our position
        value_size = read(io, tg.size_type)
        tg.offsets[tag_name] = position(io)

        # XXX: there's a 2 byte mismatch between the reflection list size, and the
        #      next token... bug in air-lld?
        if tag_name == "RBUF"
            value_size += 2
        end

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
        @assert position(io) == group_start + group_size
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

            # XXX: there's a 2 byte mismatch between the reflection list size, and the
            #      next token... bug in air-lld?
            if tag == "RBUF"
                value_size -= 2
            end

            # write the value size and the value itself
            write(io, tg.size_type(value_size))
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


## metal library format

Base.parse(::Type{MetalLib}, path::AbstractString) = open(path) do io
    read(io, MetalLib)
end

function Base.read(io::IO, ::Type{MetalLib})
    ## header

    # 4 bytes: "MTLB" magic
    magic = String(read(io, 4))
    if magic != "MTLB"
        throw(ArgumentError("Not a Metal library"))
    end

    # 3 x 2 bytes: file version
    file_major = read(io, UInt16)
    file_minor = read(io, UInt16)
    file_patch = read(io, UInt16)
    ## upper bit of file_major indicates whether this is a macOS target
    is_macos = file_major >> 15 == 1
    file_major &= 0x7fff
    file_version = VersionNumber(file_major, file_minor, file_patch)

    # 1 byte: file type (on v1.2.4+)
    if file_version >= v"1.2.4"
        file_type = read(io, FileType)
        ## upper bit of file_type indicates whether this is a stub library
        is_stub = file_type >> 7 == 1
        file_type = FileType(file_type & 0x7f)
    else
        read(io, 1)
        file_type = FILE_EXECUTABLE
        is_stub = false
    end

    # 1 byte: platform type (on v1.2.6+)
    if file_version >= v"1.2.6"
        platform_type = read(io, PlatformType)
        ## upper bit of platform_type indicates whether this is a 64-bit library
        is_64bit = platform_type >> 7 == 1
        platform_type = PlatformType(platform_type & 0x7f)
    else
        read(io, 1)
        platform_type = PLATFORM_MACOS
        is_64bit = true
    end

    # 2+1+1 byte: platform version (on v1.2.6+)
    if file_version >= v"1.2.6"
        platform_major = read(io, UInt16)
        platform_minor = read(io, UInt8)
        platform_patch = read(io, UInt8)
        platform_version = VersionNumber(platform_major, platform_minor, platform_patch)
    else
        read(io, 4)
        platform_version = v"0"
    end

    # 8 bytes: file size
    file_size = read(io, UInt64)

    # 2 x 8 bytes: function list offset and size
    function_list_offset = read(io, UInt64)
    function_list_size = read(io, UInt64)

    # 2 x 8 bytes: public metadata offset and size
    public_md_offset = read(io, UInt64)
    public_md_size = read(io, UInt64)

    # 2 x 8 bytes: private metadata offset and size
    private_md_offset = read(io, UInt64)
    private_md_size = read(io, UInt64)

    # 2 x 8 bytes: module list offset and size
    module_list_offset = read(io, UInt64)
    module_list_size = read(io, UInt64)


    ## sections

    # function list
    function_list = []
    seek(io, function_list_offset)
    function_count = read(io, UInt32)
    for i in 1:function_count
        tag_group_start = position(io)
        push!(function_list, read!(io, TagGroup()))
    end
    # the function list size excludes the size field at the start
    @assert position(io) <= function_list_offset + function_list_size + sizeof(UInt32)

    # header extension, if any
    if position(io) < public_md_offset
        header_ex = read!(io, TagGroup(has_size=false))
        @assert position(io) == public_md_offset
    else
        header_ex = nothing
    end

    # public metadata
    public_md = []
    for i in 1:function_count
        tag_group_start = position(io)
        push!(public_md, read!(io, TagGroup()))
    end
    @assert position(io) == private_md_offset

    # private metadata
    private_md = []
    for i in 1:function_count
        tag_group_start = position(io)
        push!(private_md, read!(io, TagGroup()))
    end
    @assert position(io) == module_list_offset

    # module list
    module_list = []
    for i in 1:function_count
        module_size = function_list[i]["MDSZ"]
        push!(module_list, read(io, module_size))
    end
    @assert position(io) == module_list_offset + module_list_size

    # reflection list
    #
    # there always seems to be one buffer per function, so let's store it in MetalLibFunction
    reflection_data = Vector{Vector{UInt8}}(undef, function_count)
    if header_ex !== nothing && haskey(header_ex, "RLST")
        seek(io, header_ex["RLST"].offset)
        reflection_count = read(io, UInt32)
        for i in 1:reflection_count
            # note the offset as used by the RFLT tag
            reflection_offset = position(io) - header_ex["RLST"].offset

            reflection_buf = read!(io, TagGroup())

            # check if any function points to this reflection
            function_idx = findfirst(function_list) do fun
                fun["RFLT"] == reflection_offset
            end
            if function_idx === nothing
                error("No function points to this reflection")
            end
            reflection_data[function_idx] = reflection_buf["RBUF"]
        end
        @assert position(io) == header_ex["RLST"].offset + header_ex["RLST"].size
    end

    # embedded source
    #
    # there can be fewer sources than functions, so preserve the function -> source mapping
    embedded_source = nothing
    function_sources = Dict()
    have_hsrc = header_ex !== nothing && haskey(header_ex, "HSRC")
    have_hsrd = header_ex !== nothing && haskey(header_ex, "HSRD")
    if have_hsrc || have_hsrd
        # HSRC and HSRC are identical except for the working directory field
        @assert have_hsrc != have_hsrd
        tag = have_hsrc ? "HSRC" : "HSRD"
        seek(io, header_ex[tag].offset)

        source_archive_count = read(io, UInt32)
        command_line_info = String(readuntil(io, UInt8(0)))
        working_directory = if have_hsrd
            String(readuntil(io, UInt8(0)))
        else
            nothing
        end

        archives = []
        for i in 1:source_archive_count
            # note the offset as used by the SOFF tag
            source_offset = position(io) + sizeof(UInt32) - header_ex[tag].offset

            data = read!(io, TagGroup(size_type=UInt32, counts_size=false))
            id, archive = data["SARC"]
            push!(archives, id => archive)

            # check if any function points to this source
            for j in 1:length(function_list)
                if function_list[j]["SOFF"] == source_offset
                    function_sources[j] = id
                end
            end
        end

        embedded_source = EmbeddedSource(command_line_info, working_directory, archives)
    end

    # reconstruct objects
    functions = MetalLibFunction[]
    for i in 1:length(function_list)
        optional_args = []
        if haskey(public_md[i], "CNST")
            push!(optional_args, :constants => public_md[i]["CNST"])
        end
        if haskey(private_md[i], "DEBI")
            push!(optional_args, :debug_info => private_md[i]["DEBI"])
        end
        if haskey(private_md[i], "DEPF")
            push!(optional_args, :dependent_file => private_md[i]["DEPF"])
        end
        if haskey(function_sources, i)
            push!(optional_args, :source_id => function_sources[i])
        end
        if isassigned(reflection_data, i)
            push!(optional_args, :reflection_data => reflection_data[i])
        end

        push!(functions, MetalLibFunction(;
            name = function_list[i]["NAME"],
            air_module = module_list[i],
            air_version=function_list[i]["VERS"].air,
            metal_version=function_list[i]["VERS"].metal,
            optional_args...
        ))
    end

    optional_args = []
    if header_ex !== nothing && haskey(header_ex, "UUID")
        # TODO: get rid of the nothing checks
        push!(optional_args, :uuid => header_ex["UUID"])
    end

    MetalLib(; file_version, file_type, is_macos, is_stub,
               platform_version, platform_type, is_64bit,
               functions, embedded_source,
               optional_args...)
end

Base.write(path::AbstractString, lib::MetalLib) = open(path, "w") do io
    write(io, lib)
end

function Base.write(io::IO, lib::MetalLib)
    ## embedded source

    embedded_source_offsets = Dict()

    embedded_source = let io=IOBuffer()
        if lib.embedded_source !== nothing
            write(io, UInt32(length(lib.embedded_source.archives)))
            write(io, lib.embedded_source.link_options)
            write(io, UInt8(0))
            if lib.file_version >= v"1.2.6"
                write(io, lib.embedded_source.working_directory)
                write(io, UInt8(0))
            end
            for (id, archive) = lib.embedded_source.archives
                # the offset points past the tag token
                embedded_source_offsets[id] = position(io) + sizeof(UInt32)

                archive_tags = TagGroup(size_type=UInt32, counts_size=false)
                archive_tags["SARC"] = (; id, archive)
                write(io, archive_tags)
            end
        end
        take!(io)
    end


    ## reflection list

    reflection_list_offsets = Int[]

    reflection_list = let io=IOBuffer()
        reflection_buffers = count(lib.functions) do fun
            fun.reflection_data !== nothing
        end

        # we expect either no reflection buffers, or one for each function
        # (otherwise it's not clear how to encode the offsets in the RFLT tags)
        @assert reflection_buffers == 0 || reflection_buffers == length(lib.functions)

        if reflection_buffers > 0
            write(io, UInt32(reflection_buffers))
            for fun in lib.functions
                push!(reflection_list_offsets, position(io))

                reflection_tags = TagGroup()
                reflection_tags["RBUF"] = fun.reflection_data
                write(io, reflection_tags)
            end
        end
        take!(io)
    end


    ## function list

    public_md_stream = IOBuffer()
    private_md_stream = IOBuffer()
    module_list_stream = IOBuffer()

    function_tag_groups = []

    for (i, fun) in enumerate(lib.functions)
        # public metadata
        public_md_offset = position(public_md_stream)
        public_md_tags = TagGroup()
        if !isempty(fun.constants)
            public_md_tags["CNST"] = fun.constants
        end
        write(public_md_stream, public_md_tags)

        # private metadata
        private_md_offset = position(private_md_stream)
        private_md_tags = TagGroup()
        if fun.debug_info !== nothing
            private_md_tags["DEBI"] = fun.debug_info
        end
        if fun.dependent_file !== nothing
            private_md_tags["DEPF"] = fun.dependent_file
        end
        write(private_md_stream, private_md_tags)

        # module
        module_list_offset = position(module_list_stream)
        module_hash = sha256(fun.air_module)
        module_size = sizeof(fun.air_module)
        write(module_list_stream, fun.air_module)

        # tags
        function_tags = TagGroup()
        function_tags["NAME"] = fun.name
        function_tags["TYPE"] = PROGRAM_KERNEL
        function_tags["HASH"] = module_hash
        function_tags["OFFT"] = (; public_md=public_md_offset,
                                   private_md=private_md_offset,
                                   air_module=module_list_offset)
        function_tags["VERS"] = (; air=fun.air_version, metal=fun.metal_version)
        function_tags["MDSZ"] = module_size
        if fun.source_id !== nothing && haskey(embedded_source_offsets, fun.source_id)
            function_tags["SOFF"] = embedded_source_offsets[fun.source_id]
        end
        if lib.file_version >= v"1.2.7"
            function_tags["RFLT"] = reflection_list_offsets[i]
        end
        push!(function_tag_groups, function_tags)
    end

    function_list_stream = IOBuffer()
    write(function_list_stream, UInt32(length(function_tag_groups)))
    for tag_group in function_tag_groups
        write(function_list_stream, tag_group)
    end

    function_list = take!(function_list_stream)
    public_md = take!(public_md_stream)
    private_md = take!(private_md_stream)
    module_list = take!(module_list_stream)


    ## header extensions

    if lib.file_version >= v"1.2.3"
        header_ex_tags = TagGroup(has_size=false)
        if sizeof(embedded_source) > 0
            embedded_source_tag = lib.file_version >= v"1.2.6" ? "HSRD" : "HSRC"
            header_ex_tags[embedded_source_tag] = (; offset=0, size=sizeof(embedded_source))
        end
        if lib.file_version >= v"1.2.7"
            header_ex_tags["RLST"] = (; offset=0, size=sizeof(reflection_list))
        end
        # XXX: placeholder; this data is invalid
        #      it should be a UUID based on all of the module's data
        if lib.uuid !== nothing
            header_ex_tags["UUID"] = lib.uuid
        end

        header_ex_stream = IOBuffer()
        write(header_ex_stream, header_ex_tags)
        header_ex = take!(header_ex_stream)
    end


    ## header

    # magic
    write(io, "MTLB")

    # file version
    write(io, UInt16(lib.file_version.major) | UInt16(lib.is_macos) << 15)
    write(io, UInt16(lib.file_version.minor))
    write(io, UInt16(lib.file_version.patch))

    # file type (on v1.2.4+)
    if lib.file_version >= v"1.2.4"
        write(io, UInt8(lib.file_type) | UInt8(lib.is_stub) << 7)
    else
        write(io, UInt8(0))
    end

    # platform type (on v1.2.6+)
    if lib.file_version >= v"1.2.6"
        write(io, UInt8(lib.platform_type) | UInt8(lib.is_64bit) << 7)
    else
        write(io, UInt8(0))
    end

    # platform version
    if lib.file_version >= v"1.2.6"
        write(io, UInt16(lib.platform_version.major))
        write(io, UInt8(lib.platform_version.minor))
        write(io, UInt8(lib.platform_version.patch))
    else
        write(io, UInt16(0))
        write(io, UInt8(0))
        write(io, UInt8(0))
    end

    # we can only write offset fields after having written the sections,
    # so keep track of their positions and patch them later
    placeholders = Dict{Symbol,Int}()
    function mark_placeholder(name, location)
        placeholders[name] = location
    end
    function write_placeholder(io, T, name)
        pos = position(io)
        write(io, zero(T) #= placeholder =#)
        mark_placeholder(name, pos)
    end
    function patch_placeholder(io, name, value)
        position = mark(io)
        seek(io, placeholders[name])
        write(io, value)
        reset(io)
    end

    # file size
    write_placeholder(io, UInt64, :file_size)

    # function list offset and size
    write_placeholder(io, UInt64, :function_list_offset)
    # the function list size excludes the size field at the start
    write(io, UInt64(sizeof(function_list) - sizeof(UInt32)))

    # public metadata offset and size
    write_placeholder(io, UInt64, :public_md_offset)
    write(io, UInt64(sizeof(public_md)))

    # private metadata offset and size
    write_placeholder(io, UInt64, :private_md_offset)
    write(io, UInt64(sizeof(private_md)))

    # module list offset and size
    write_placeholder(io, UInt64, :module_list_offset)
    write(io, UInt64(sizeof(module_list)))


    ## write sections

    # function list
    patch_placeholder(io, :function_list_offset, position(io))
    write(io, function_list)

    # header extension
    if sizeof(embedded_source) > 0
        mark_placeholder(:embedded_source_offset,
                         position(io) + offsetof(header_ex_tags, embedded_source_tag))
    end
    if sizeof(reflection_list) > 0
        mark_placeholder(:reflection_list_offset,
                         position(io) + offsetof(header_ex_tags, "RLST"))
    end
    write(io, header_ex)

    # public metadata
    patch_placeholder(io, :public_md_offset, position(io))
    write(io, public_md)

    # private metadata
    patch_placeholder(io, :private_md_offset, position(io))
    write(io, private_md)

    # module list
    patch_placeholder(io, :module_list_offset, position(io))
    write(io, module_list)

    # sources
    if sizeof(embedded_source) > 0
        patch_placeholder(io, :embedded_source_offset, position(io))
        write(io, embedded_source)
    end

    # TODO: dynamic header

    # TODO: variable list

    # TODO: imported symbol list

    # reflection list
    if sizeof(reflection_list) > 0
        patch_placeholder(io, :reflection_list_offset, position(io))
        write(io, reflection_list)
    end

    # TODO: script list

    patch_placeholder(io, :file_size, position(io))
end
