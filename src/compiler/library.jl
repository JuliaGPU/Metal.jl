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


## enums

@cenum FileType::UInt8 begin
    FILE_EXECUTABLE          = 0
    FILE_CORE_IMAGE          = 1
    FILE_DYNAMIC             = 2
    FILE_SYMBOL_COMPANION    = 3
end

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

@cenum MetalDataType::UInt8 begin
	DATA_INVALID = 0

	DATA_STRUCT = 1
	DATA_ARRAY = 2

	DATA_FLOAT1 = 3
	DATA_FLOAT2 = 4
	DATA_FLOAT3 = 5
	DATA_FLOAT4 = 6
	DATA_FLOAT2X2 = 7
	DATA_FLOAT2X3 = 8
	DATA_FLOAT2X4 = 9
	DATA_FLOAT3X2 = 10
	DATA_FLOAT3X3 = 11
	DATA_FLOAT3X4 = 12
	DATA_FLOAT4X2 = 13
	DATA_FLOAT4X3 = 14
	DATA_FLOAT4X4 = 15

	DATA_HALF1 = 16
	DATA_HALF2 = 17
	DATA_HALF3 = 18
	DATA_HALF4 = 19
	DATA_HALF2X2 = 20
	DATA_HALF2X3 = 21
	DATA_HALF2X4 = 22
	DATA_HALF3X2 = 23
	DATA_HALF3X3 = 24
	DATA_HALF3X4 = 25
	DATA_HALF4X2 = 26
	DATA_HALF4X3 = 27
	DATA_HALF4X4 = 28

	DATA_INT1 = 29
	DATA_INT2 = 30
	DATA_INT3 = 31
	DATA_INT4 = 32

	DATA_UINT1 = 33
	DATA_UINT2 = 34
	DATA_UINT3 = 35
	DATA_UINT4 = 36

	DATA_SHORT1 = 37
	DATA_SHORT2 = 38
	DATA_SHORT3 = 39
	DATA_SHORT4 = 40

	DATA_USHORT1 = 41
	DATA_USHORT2 = 42
	DATA_USHORT3 = 43
	DATA_USHORT4 = 44

	DATA_CHAR1 = 45
	DATA_CHAR2 = 46
	DATA_CHAR3 = 47
	DATA_CHAR4 = 48

	DATA_UCHAR1 = 49
	DATA_UCHAR2 = 50
	DATA_UCHAR3 = 51
	DATA_UCHAR4 = 52

	DATA_BOOL1 = 53
	DATA_BOOL2 = 54
	DATA_BOOL3 = 55
	DATA_BOOL4 = 56

	DATA__UNUSED_0 = 57

	DATA_TEXTURE = 58
	DATA_SAMPLER = 59
	DATA_POINTER = 60

	DATA__UNUSED_1 = 61

	DATA_R8UNORM = 62
	DATA_R8SNORM = 63
	DATA_R16UNORM = 64
	DATA_R16SNORM = 65
	DATA_RG8UNORM = 66
	DATA_RG8SNORM = 67
	DATA_RG16UNORM = 68
	DATA_RG16SNORM = 69
	DATA_RGBA8UNORM = 70
	DATA_RGBA8UNORM_SRGB = 71
	DATA_RGBA8SNORM = 72
	DATA_RGBA16UNORM = 73
	DATA_RGBA16SNORM = 74
	DATA_RGB10A2UNORM = 75
	DATA_RG11B10FLOAT = 76
	DATA_RGB9E5FLOAT = 77

	DATA_RENDER_PIPELINE = 78
	DATA_COMPUTE_PIPELINE = 79
	DATA_INDIRECT_CMD_BUFFER = 80

	DATA_LONG1 = 81
	DATA_LONG2 = 82
	DATA_LONG3 = 83
	DATA_LONG4 = 84

	DATA_ULONG1 = 85
	DATA_ULONG2 = 86
	DATA_ULONG3 = 87
	DATA_ULONG4 = 88

	DATA_DOUBLE1 = 89
	DATA_DOUBLE2 = 90
	DATA_DOUBLE3 = 91
	DATA_DOUBLE4 = 92

	DATA_FLOAT8 = 93
	DATA_FLOAT16 = 94
	DATA_HALF8 = 95
	DATA_HALF16 = 96
	DATA_INT8 = 97
	DATA_INT16 = 98
	DATA_UINT8 = 99
	DATA_UINT16 = 100
	DATA_SHORT8 = 101
	DATA_SHORT16 = 102
	DATA_USHORT8 = 103
	DATA_USHORT16 = 104
	DATA_CHAR8 = 105
	DATA_CHAR16 = 106
	DATA_UCHAR8 = 107
	DATA_UCHAR16 = 108
	DATA_LONG8 = 109
	DATA_LONG16 = 110
	DATA_ULONG8 = 111
	DATA_ULONG16 = 112
	DATA_DOUBLE8 = 113
	DATA_DOUBLE16 = 114

	DATA_VISIBLE_FUNCTION_TABLE = 115
	DATA_INTERSECTION_FUNCTION_TABLE = 116
	DATA_PRIMITIVE_ACCELERATION_STRUCTURE = 117
	DATA_INSTANCE_ACCELERATION_STRUCTURE = 118

	DATA_BOOL8 = 119
	DATA_BOOL16 = 120
end


## structures

struct FunctionConstant
    name::String
    datatype::MetalDataType
    index::Int
    active::Bool
end

struct DebugInfo
    path::String
    line::Int
end

struct EmbeddedSource
    link_options::String
    working_directory::String
    archives::Vector{Pair{String,Vector{UInt8}}}
end

Base.@kwdef struct MetalLibFunction
    name::String
    air_version::VersionNumber
    metal_version::VersionNumber

    bitcode::Vector{UInt8}

    source_id::Union{Nothing,String} = nothing

    # public metadata
    constants::Vector{FunctionConstant} = FunctionConstant[]

    # private metadata
    debug_info::Union{Nothing, DebugInfo} = nothing
    dependent_file::Union{Nothing, String} = nothing
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


## reading

# generate a custom `read` function that also checks we don't over-read a section
function checked_reader(io, maxpos, name)
    function reader(io, args...)
        start = position(io)
        ret = read(io, args...)
        if position(io) > maxpos
            nbytes = position(io) - start
            overread = position(io) - maxpos
            error("Read of $nbytes bytes went $overread bytes past the end of the $name section")
        end
        return ret
    end
end

function Base.read(io::IO, ::Type{MetalLib})
    ## headers

    # 4 bytes: "MTLB" magic
    magic = Cchar[0,0,0,0]
    read!(io, magic)
    if Char.(magic) != ['M', 'T', 'L', 'B']
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

    # 2 x 8 bytes: bitcode offset and size
    bitcode_offset = read(io, UInt64)
    bitcode_size = read(io, UInt64)


    ## helpers

    function read_taggroup(read, name; size_type=UInt16)
        data = []
        while true
            tag_name = String(read(io, 4*sizeof(Cchar)))
            if tag_name == "ENDT"
                break
            end
            value_size = read(io, size_type)
            value_position = position(io)

            # parse data
            ## function list
            if tag_name == "NAME"
                push!(data, :name => String(readuntil(io, UInt8(0))))
            elseif tag_name == "TYPE"
                push!(data, :type => read(io, ProgramType))
            elseif tag_name == "HASH"
                push!(data, :hash => bytes2hex(read(io, value_size)))
            elseif tag_name == "OFFT"
                push!(data, :offsets => (;
                    public_md = read(io, UInt64),
                    private_md = read(io, UInt64),
                    bitcode = read(io, UInt64))
                )
            elseif tag_name == "SOFF"
                push!(data, :source_offset => read(io, UInt64))
            elseif tag_name == "VERS"
                push!(data, :versions => (;
                    air   = VersionNumber(read(io, UInt16), read(io, UInt16)),
                    metal = VersionNumber(read(io, UInt16), read(io, UInt16)))
                )
            elseif tag_name == "MDSZ"
                push!(data, :bitcode_size => read(io, UInt64))
            elseif tag_name == "RFLT"
                push!(data, :rflt => read(io, UInt64))
            ## header extension
            elseif tag_name == "HSRD"
                push!(data, :embedded_source => (;
                    offset = read(io, UInt64),
                    size = read(io, UInt64)))
            elseif tag_name == "RLST"
                push!(data, :reflection => (;
                    offset = read(io, UInt64),
                    size = read(io, UInt64)))
            elseif tag_name == "UUID"
                uuid_bits = Vector{UInt64}(undef, 2)
                read!(io, uuid_bits)
                push!(data, :uuid => UUID(Tuple(uuid_bits)))
            ## public metadata
            elseif tag_name == "CNST"
                num_constants = read(io, UInt16)
                constants = Vector{FunctionConstant}(undef, num_constants)
                pos = 3
                for i in 1:num_constants
                    name = String(readuntil(io, UInt8(0)))
                    datatype = read(io, MetalDataType)
                    index = read(io, UInt16)
                    active = Bool(read(io, UInt8))

                    constants[i] = FunctionConstant(name, datatype, index, active)
                end
                push!(data, :constants => constants)
            ## private metadata
            elseif tag_name == "DEBI"
                line = read(io, UInt32)
                path = String(readuntil(io, UInt8(0)))
                push!(data, :debug_info => DebugInfo(path, line))
            elseif tag_name == "DEPF"
                file_name = String(readuntil(io, UInt8(0)))
                push!(data, :dependent_file => file_name)
            ## embedded sources
            elseif tag_name == "SARC"
                id = String(readuntil(io, UInt8(0)))
                archive = read(io, value_size - sizeof(id) - 1)
                push!(data, :embedded_source => (; id, archive))
            ## reflection lists
            elseif tag_name == "RBUF"
                # XXX: there's a 2 byte mismatch between the reflection list size, and the
                #      next ENDT token... bug in air-lld?
                value_size += 2
                push!(data, :reflection_buffer => read(io, value_size))
            else
                @warn "Unknown $value_size-byte tag in $name: $tag_name"
            end

            seek(io, value_position + value_size)
        end
        return NamedTuple(data)
    end


    ## sections

    # function list
    function_list = []
    seek(io, function_list_offset)
    let read = checked_reader(io, function_list_offset + function_list_size, "function list")
        entry_count = read(io, UInt32)
        for i in 1:entry_count
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(function_list, read_taggroup(read, "function list"))
            end
        end
    end

    # header extension, if any
    header_ex = if position(io) < public_md_offset
        # the header extension group isn't preceded by a size field
        let read = checked_reader(io, public_md_offset, "header extension")
            read_taggroup(read, "header extension")
        end
    else
        nothing
    end

    # public md
    public_md = []
    let read = checked_reader(io, private_md_offset, "public metadata")
        for i in 1:length(function_list)
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(public_md, read_taggroup(read, "public metadata"))
            end
        end
    end

    # private_md
    @assert position(io) == private_md_offset
    private_md = []
    let read = checked_reader(io, bitcode_offset, "private metadata")
        for i in 1:length(function_list)
            tag_group_start = position(io)
            tag_group_size = read(io, UInt32)
            let read = checked_reader(io, tag_group_start + tag_group_size, "tag group")
                push!(private_md, read_taggroup(read, "private metadata"))
            end
        end
    end

    # bitcode
    @assert position(io) == bitcode_offset
    bitcode = []
    let read = checked_reader(io, bitcode_offset + bitcode_size, "bitcode")
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
                    push!(reflection_list, read_taggroup(read, "reflection list"))
                end
            end
        end
    end

    # embedded source
    embedded_source = nothing
    function_sources = Dict()
    if header_ex !== nothing && haskey(header_ex, :embedded_source)
        seek(io, header_ex.embedded_source.offset)
        source_archive_count = read(io, UInt32)
        command_line_info = String(readuntil(io, UInt8(0)))
        working_directory = String(readuntil(io, UInt8(0)))

        archives = []
        for i in 1:source_archive_count
            tag_group_size = read(io, UInt32)
            tag_group_start = position(io)  # SOFF points to here
            let read = checked_reader(io, tag_group_start + tag_group_size, "source archive")
                data = read_taggroup(read, "source archive"; size_type=UInt32)
                id, archive = data.embedded_source
                push!(archives, id => archive)

                # check if any function points to this source
                source_offset = tag_group_start - header_ex.embedded_source.offset
                for j in 1:length(function_list)
                    if function_list[j].source_offset == source_offset
                        function_sources[j] = id
                    end
                end
            end
        end

        embedded_source = EmbeddedSource(command_line_info, working_directory, archives)
    end

    # reconstruct objects
    functions = MetalLibFunction[]
    for i in 1:length(function_list)
        optional_args = []
        if haskey(public_md[i], :constants)
            push!(optional_args, :constants => public_md[i].constants)
        end
        if haskey(private_md[i], :debug_info)
            push!(optional_args, :debug_info => private_md[i].debug_info)
        end
        if haskey(private_md[i], :dependent_file)
            push!(optional_args, :dependent_file => private_md[i].dependent_file)
        end
        if haskey(function_sources, i)
            push!(optional_args, :source_id => function_sources[i])
        end

        push!(functions, MetalLibFunction(;
            name = function_list[i].name,
            bitcode = bitcode[i],
            air_version=function_list[i].versions.air,
            metal_version=function_list[i].versions.metal,
            optional_args...
        ))
    end

    optional_args = []
    if header_ex !== nothing && haskey(header_ex, :uuid)
        # TODO: get rid of the nothing checks
        push!(optional_args, :uuid => header_ex.uuid)
    end

    MetalLib(; file_version, file_type, is_macos, is_stub,
               platform_version, platform_type, is_64bit,
               functions, embedded_source, optional_args...)
end


## writing

function emit_tag_group(io::IO, data::Vector; emit_size=true, size_type::Type=UInt16)
    # keep track of where we write tag values
    locations = Dict{String,Int}()

    # emit the data and their values
    tag_stream = IOBuffer()
    for (tag, value) in data
        emit_tag(tag_stream, tag, value; size_type, locations)
    end
    emit_tag(tag_stream, "ENDT"; size_type, locations)
    tag_group = take!(tag_stream)

    # emit the tag group
    if emit_size
        # the size of the tag group includes the size bytes itself
        write(io, UInt32(sizeof(tag_group) + sizeof(UInt32)))
    end
    write(io, tag_group)

    return locations
end

function emit_tag(io::IO, tag::String, value=nothing; size_type::Type, locations::Dict)
    # emit the tag
    @assert length(tag) == 4
    write(io, tag)

    # helpers for emitting the value
    write_len(len) = write(io, size_type(len))
    function write_value(value, T=typeof(value))
        value = convert(T, value)
        write_len(sizeof(value))
        locations[tag] = position(io)
        write(io, value)
    end

    # emit the value
    if tag == "NAME"
        # Name of the function
        isa(value, String) || throw(ArgumentError("Name must be a string"))
        length(value) <= typemax(UInt16)-1 || throw(ArgumentError("Name too long"))
        write_value(UInt8[Vector{UInt8}(value); 0])
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
        write_value([bits...])
    elseif tag == "RLST"
        # Unknown section; added in Metal 2.7
        write_value(UInt64[value.offset, value.size])
    elseif tag == "HSRD"
        write_value(UInt64[value.offset, value.size])
    elseif tag == "SOFF"
        write_value(value, UInt64)
    ## public metadata data
    elseif tag == "CNST"
        # a list of function constants
        if !isa(value, Vector{FunctionConstant})
            throw(ArgumentError("CNST tag must be a vector of FunctionConstants"))
        end
        constant_buf = IOBuffer()
        write(constant_buf, UInt16(length(value)))
        for constant in value
            write(constant_buf, constant.name)
            write(constant_buf, UInt8(0))
            write(constant_buf, UInt8(constant.datatype))
            write(constant_buf, UInt16(constant.index))
            write(constant_buf, UInt8(constant.active))
        end
        write_value(take!(constant_buf))
    ## private metadata data
    elseif tag == "DEBI"
        if !isa(value, DebugInfo)
            throw(ArgumentError("DEBI tag must be a DebugInfo"))
        end
        debuginfo_buf = IOBuffer()
        write(debuginfo_buf, UInt32(value.line))
        write(debuginfo_buf, value.path)
        write(debuginfo_buf, UInt8(0))
        write_value(take!(debuginfo_buf))
    elseif tag == "DEPF"
        if !isa(value, String)
            throw(ArgumentError("DEPF tag must be a string"))
        end
        write_value(UInt8[Vector{UInt8}(value); 0])
    ## embedded sources
    elseif tag == "SARC"
        source_buf = IOBuffer()
        write(source_buf, String(value.id))
        write(source_buf, UInt8(0))
        write(source_buf, value.archive)
        write_value(take!(source_buf))
    else
        throw(ArgumentError("Unknown tag: $tag"))
    end
end

function Base.write(io::IO, lib::MetalLib)
    ## embedded source

    embedded_source_offsets = Dict()

    embedded_source_io = IOBuffer()
    if lib.embedded_source !== nothing
        write(embedded_source_io, UInt32(length(lib.embedded_source.archives)))
        write(embedded_source_io, lib.embedded_source.link_options)
        write(embedded_source_io, UInt8(0))
        write(embedded_source_io, lib.embedded_source.working_directory)
        write(embedded_source_io, UInt8(0))
        for (id, archive) = lib.embedded_source.archives
            # the offset points past the tag token
            embedded_source_offsets[id] = position(embedded_source_io) + sizeof(UInt32)

            data = [ "SARC" => (; id, archive) ]
            emit_tag_group(embedded_source_io, data; size_type=UInt32)
        end
    end
    embedded_source = take!(embedded_source_io)


    ## function list

    public_md_stream = IOBuffer()
    private_md_stream = IOBuffer()
    bitcode_stream = IOBuffer()

    tag_groups = []

    for fun in lib.functions
        # public metadata
        public_md_offset = position(public_md_stream)
        data = []
        if !isempty(fun.constants)
            push!(data, "CNST" => fun.constants)
        end
        emit_tag_group(public_md_stream, data)

        # private metadata
        private_md_offset = position(private_md_stream)
        data = []
        if fun.debug_info !== nothing
            push!(data, "DEBI" => fun.debug_info)
        end
        if fun.dependent_file !== nothing
            push!(data, "DEPF" => fun.dependent_file)
        end
        emit_tag_group(private_md_stream, data)

        # bitcode
        bitcode_offset = position(bitcode_stream)
        bitcode_hash = sha256(fun.bitcode)
        bitcode_size = sizeof(fun.bitcode)
        write(bitcode_stream, fun.bitcode)

        # tags
        data = [
            "NAME" => fun.name,
            "TYPE" => PROGRAM_KERNEL,
            "HASH" => bitcode_hash,
            "OFFT" => (; public_md=public_md_offset,
                         private_md=private_md_offset,
                         bitcode=bitcode_offset),
            "VERS" => (; air=fun.air_version, metal=fun.metal_version),
            "MDSZ" => bitcode_size,
        ]
        if fun.source_id !== nothing && haskey(embedded_source_offsets, fun.source_id)
            # XXX: version check
            push!(data, "SOFF" => embedded_source_offsets[fun.source_id])
        end
        if lib.file_version >= v"1.2.7"
            # XXX: placeholder; this data is invalid
            push!(data, "RFLT" => 0)
        end
        tag_stream = IOBuffer()
        emit_tag_group(tag_stream, data)
        push!(tag_groups, take!(tag_stream))
    end

    function_list_stream = IOBuffer()
    write(function_list_stream, UInt32(length(lib.functions)))
    for data in tag_groups
        write(function_list_stream, data)
    end

    function_list = take!(function_list_stream)
    public_md = take!(public_md_stream)
    private_md = take!(private_md_stream)
    bitcode = take!(bitcode_stream)


    ## header extensions

    if lib.file_version >= v"1.2.3"
        data = []
        # XXX: HSRD only on 12, 11 is HSRC
        if sizeof(embedded_source) > 0
            push!(data, "HSRD" => (; offset=0, size=sizeof(embedded_source)))
        end
        if lib.file_version >= v"1.2.7"
            # XXX: placeholder; this data is invalid
            push!(data, "RLST" => (; offset=0, size=0))
        end
        # XXX: placeholder; this data is invalid
        #      it should be a UUID based on all of the module's data
        if lib.uuid !== nothing
            push!(data, "UUID" => lib.uuid)
        end

        header_ex_stream = IOBuffer()
        header_ex_locations = emit_tag_group(header_ex_stream, data; emit_size=false)
        header_ex = take!(header_ex_stream)
    end


    ## header

    # magic
    write(io, Cchar['M', 'T', 'L', 'B'])

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
    # the function list size excludes the size field at the start, but it is included in
    # other offset calculations, so only substract it here. this isn't very nice; instead
    # we could just determine the offsets by backpatching them after writing the sections.
    write(io, UInt64(sizeof(function_list)-sizeof(UInt32)))

    # public metadata offset and size
    write_placeholder(io, UInt64, :public_md_offset)
    write(io, UInt64(sizeof(public_md)))

    # private metadata offset and size
    write_placeholder(io, UInt64, :private_md_offset)
    write(io, UInt64(sizeof(private_md)))

    # bitcode offset and size
    write_placeholder(io, UInt64, :bitcode_offset)
    write(io, UInt64(sizeof(bitcode)))


    ## write sections

    # function list
    patch_placeholder(io, :function_list_offset, position(io))
    write(io, function_list)

    # header extension
    if sizeof(embedded_source) > 0
        mark_placeholder(:embedded_source, position(io) + header_ex_locations["HSRD"])
    end
    write(io, header_ex)

    # public metadata
    patch_placeholder(io, :public_md_offset, position(io))
    write(io, public_md)

    # private metadata
    patch_placeholder(io, :private_md_offset, position(io))
    write(io, private_md)

    # bitcode
    patch_placeholder(io, :bitcode_offset, position(io))
    write(io, bitcode)

    # sources
    if sizeof(embedded_source) > 0
        patch_placeholder(io, :embedded_source, position(io))
        write(io, embedded_source)
    end

    # TODO: dynamic header

    # TODO: variable list

    # TODO: imported symbol list

    # TODO: reflection list

    # TODO: script list

    patch_placeholder(io, :file_size, position(io))
end
