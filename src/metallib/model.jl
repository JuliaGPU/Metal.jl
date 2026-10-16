# the Metal library model: functions, their metadata, and the library container

using SHA: sha256, SHA2_256_CTX, update!, digest!
using CodecBzip2: Bzip2DecompressorStream

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
    # BZip2-compressed tarballs, kept verbatim: toolchains differ in compression level
    # and padding (Xcode 26 emits level 6 unpadded, older ones level 9 padded to 16 KiB
    # multiples), so recompressing would not round-trip. see `decompress_source_archive`.
    archives::Vector{Pair{String,Vector{UInt8}}}
end

# the source archives are stored as BZip2-compressed tarballs. some toolchains pad the
# compressed stream to a multiple of 16 KiB, so stop decompressing at the stream's end.
function decompress_source_archive(compressed::Vector{UInt8})
    stream = Bzip2DecompressorStream(IOBuffer(compressed); stop_on_end=true)
    read(stream, typemax(Int))
end

# derive a UUID from library contents. the official toolchain stamps every library with
# a deterministic, name-based (version 3) UUID whose inputs are not documented, and nothing
# seems to inspect it; deriving one from the modules keeps our output deterministic too.
function content_uuid(datas::Vector{UInt8}...)
    ctx = SHA2_256_CTX()
    for data in datas
        update!(ctx, data)
    end
    dgst = digest!(ctx)
    u = ntoh(only(reinterpret(UInt128, dgst[1:16])))
    # stamp the version and variant bits of a random (version 4) UUID
    u = (u & ~(UInt128(0xf) << 76)) | (UInt128(0x4) << 76)
    u = (u & ~(UInt128(0x3) << 62)) | (UInt128(0x2) << 62)
    return UUID(u)
end

# the tag groups a function was read with, kept so that writing the library back reproduces
# the input: they record the order of the tags, the tags we don't decode, and the size
# convention of each group. see `layout_group`.
struct FunctionLayout
    function_tags::TagGroup
    public_tags::TagGroup
    private_tags::TagGroup
    reflection_tags::Union{Nothing,TagGroup}

    # the SHA-256 of the module as read, to detect whether it was replaced: the HASH tag is
    # not always a digest of the module (Apple's compressed and Core Image libraries differ),
    # so we only recompute it for new modules
    module_digest::Vector{UInt8}
end

Base.@kwdef struct MetalLibFunction
    name::String
    type::ProgramType = METALLIB_COMPUTE_FUNCTION
    air_version::VersionNumber
    metal_version::VersionNumber

    air_module::Vector{UInt8}

    source_id::Union{Nothing,String} = nothing

    # public metadata
    constants::Vector{FunctionConstant} = FunctionConstant[]

    # private metadata
    debug_info::Union{Nothing, DebugInfo} = nothing
    dependencies::Vector{String} = String[]     # paths of the files the function came from

    # reflection data
    reflection_data::Union{Nothing, Vector{UInt8}} = nothing

    # how the function was laid out in the library it was read from, if any
    layout::Union{Nothing, FunctionLayout} = nothing
end

# the parts of a library's layout that are not covered by its functions; see `FunctionLayout`
struct LibraryLayout
    header_extension::Union{Nothing,TagGroup}
    dynamic_header::Union{Nothing,TagGroup}

    # sections we don't decode, by the header extension tag that points to them
    raw_sections::Dict{String,Vector{UInt8}}
end

# sections we keep as raw bytes, in the order they appear in a library
const raw_section_tags = ["VLST", "ILST"]

Base.@kwdef struct MetalLib
    # defaults to the newest file format the host supports. note that optional sections
    # the official toolchain would emit (e.g. reflection data) are simply left out when
    # we have nothing to put there; the loader accepts that.
    file_version::VersionNumber=metallib_target()
    file_type::FileType=METALLIB_EXECUTE
    is_macos::Bool=true
    is_stub::Bool=false

    platform_version::VersionNumber=macos_version()
    platform_type::PlatformType=METALLIB_PLATFORM_MACOS
    is_64bit::Bool=true

    uuid::Union{Nothing, UUID} = nothing

    # name of the library, as recorded in the dynamic header (metallib v1.2.9)
    library_name::Union{Nothing, String} = nothing

    functions::Vector{MetalLibFunction}
    embedded_source::Union{Nothing, EmbeddedSource} = nothing

    # how the library was laid out when it was read, if it was
    layout::Union{Nothing, LibraryLayout} = nothing
end

# assemble a tag group from `values` (tag => value pairs, or nothing to omit a tag), laid out
# like `template` if we have one: tags keep their position, tags we could not decode are
# written back verbatim (unless we now have a value for them), and tags that are not in the
# template are added at the end.
function layout_group(template::Union{Nothing,TagGroup}, values; kwargs...)
    tg = TagGroup(; kwargs...)
    pending = Dict{String,Any}(tag => value for (tag, value) in values if value !== nothing)
    if template !== nothing
        tg.counts_size = template.counts_size
        for (tag, value) in template.data
            if haskey(pending, tag)
                push!(tg.data, tag => pop!(pending, tag))
            elseif value isa RawTag
                push!(tg.data, tag => value)
            end
        end
    end
    for (tag, _) in values
        if haskey(pending, tag)
            push!(tg.data, tag => pop!(pending, tag))
        end
    end
    return tg
end

# look up a decoded tag value, or `nothing` if the tag is missing or was kept as raw bytes
function decoded(tg::Union{Nothing,TagGroup}, tag::String)
    tg === nothing && return nothing
    value = get(tg, tag, nothing)
    return value isa RawTag ? nothing : value
end
function decoded(tg::TagGroup, tag::String, ::Type{T}) where T
    value = decoded(tg, tag)
    format_check(value isa T, "missing a valid $tag tag")
    return value
end

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
    # Paths of the files the function depends on (e.g. the object files it was linked
    # from); a sequence of null-terminated strings
    Vector{String},
    (io, _)   -> begin
        paths = String[]
        while !eof(io)
            push!(paths, String(readuntil(io, UInt8(0))))
        end
        paths
    end,
    (io, val) -> begin
        for path in val
            write(io, path)
            write(io, UInt8(0))
        end
    end)
## embedded sources
tag_value_io["SARC"] = (
    # Source archive; an identifier (null-terminated ASCII) and BZip2-compressed tarball,
    # which is stored as-is (see the comments on `EmbeddedSource`)
    @NamedTuple{id::String, archive::Vector{UInt8}},
    (io, nb) -> begin
        id = String(readuntil(io, UInt8(0)))
        archive = read(io, nb - sizeof(id) - 1)
        (; id, archive)
    end,
    (io, val) -> begin
        write(io, val.id)
        write(io, UInt8(0))
        write(io, val.archive)
    end)
## metal library format

Base.parse(::Type{MetalLib}, path::AbstractString) = open(path) do io
    read(io, MetalLib)
end

function Base.read(io::IO, ::Type{MetalLib})
    # read the whole library into memory: the format is based on offsets from its start,
    # and reading from memory keeps corrupt sizes from allocating more than we have
    header = read(io, 24)
    format_check(sizeof(header) >= 4 && header[1:4] == codeunits("MTLB"),
                 "not a Metal library (bad magic)", 0)
    format_check(sizeof(header) == 24, "truncated header", sizeof(header))
    file_size = only(reinterpret(UInt64, header[17:24]))
    format_check(24 <= file_size <= typemax(Int), "invalid file size $file_size", 16)
    data = UInt8[]
    readbytes!(io, data, file_size - 24)
    format_check(sizeof(data) == file_size - 24,
                 "truncated: expected $file_size bytes, got $(24 + sizeof(data))",
                 24 + sizeof(data))
    buffer = IOBuffer([header; data])

    try
        read_metallib(buffer)
    catch err
        err isa EOFError || rethrow()
        throw(MetalLibFormatError("unexpected end of a section or tag", position(buffer)))
    end
end

# seek to a section of `size` bytes at `offset`, checking that it lies within the library
function seek_section(io::IOBuffer, offset::Integer, size::Integer, what)
    format_check(offset <= io.size && size <= io.size - offset,
                 "$what of $size bytes at offset $offset lies outside the library")
    seek(io, offset)
end

function read_metallib(io::IOBuffer)
    ## header

    # 4 bytes: "MTLB" magic
    skip(io, 4)

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
        file_type = METALLIB_EXECUTE
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
        platform_type = METALLIB_PLATFORM_MACOS
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
    _file_size = read(io, UInt64)

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
    function_list = TagGroup[]
    # (the function list size excludes the size field at the start)
    seek_section(io, function_list_offset, function_list_size, "function list")
    function_count = read(io, UInt32)
    for _ in 1:function_count
        push!(function_list, read!(io, TagGroup()))
    end
    format_check(position(io) <= function_list_offset + function_list_size + sizeof(UInt32),
                 "function list exceeds its size", function_list_offset)

    # header extension, if any
    if position(io) < public_md_offset
        header_ex = read!(io, TagGroup(has_size=false))
        format_check(position(io) == public_md_offset,
                     "header extension does not end at the public metadata", position(io))
    else
        header_ex = nothing
    end

    # public metadata
    public_md = TagGroup[]
    seek_section(io, public_md_offset, public_md_size, "public metadata")
    for _ in 1:function_count
        push!(public_md, read!(io, TagGroup()))
    end
    format_check(position(io) == private_md_offset,
                 "public metadata does not end at the private metadata", position(io))

    # private metadata
    private_md = TagGroup[]
    seek_section(io, private_md_offset, private_md_size, "private metadata")
    for _ in 1:function_count
        push!(private_md, read!(io, TagGroup()))
    end
    format_check(position(io) == module_list_offset,
                 "private metadata does not end at the module list", position(io))

    # module list
    #
    # functions can share a module (e.g., in Core Image libraries and dynamic libraries),
    # in which case they also share the vector holding it
    seek_section(io, module_list_offset, module_list_size, "module list")
    modules = Dict{UInt64,Vector{UInt8}}()
    module_list = Vector{UInt8}[]
    for i in 1:function_count
        offset = decoded(function_list[i], "OFFT", NamedTuple).air_module
        module_size = decoded(function_list[i], "MDSZ")
        format_check(module_size !== nothing,
                     "function $(i-1) has no module (MDSZ tag); stub libraries, which only " *
                     "describe their functions, are not supported")
        format_check(offset <= module_list_size && module_size <= module_list_size - offset,
                     "module of function $(i-1) lies outside the module list")
        air_module = get!(modules, offset) do
            seek(io, module_list_offset + offset)
            read(io, module_size)
        end
        format_check(sizeof(air_module) == module_size,
                     "modules of different sizes at offset $offset of the module list")
        push!(module_list, air_module)
    end
    module_digests = IdDict{Vector{UInt8},Vector{UInt8}}(m => sha256(m) for m in values(modules))

    # reflection list
    #
    # like modules, reflection entries can be shared by several functions
    reflection_tags = Vector{Union{Nothing,TagGroup}}(nothing, function_count)
    if (rlst = decoded(header_ex, "RLST")) !== nothing
        seek_section(io, rlst.offset, rlst.size, "reflection list")
        reflection_count = read(io, UInt32)
        for _ in 1:reflection_count
            # note the offset as used by the RFLT tag
            reflection_offset = position(io) - rlst.offset

            reflection_buf = read!(io, TagGroup())

            # check which functions point to this reflection
            function_idxs = findall(function_list) do fun
                decoded(fun, "RFLT") == reflection_offset
            end
            format_check(!isempty(function_idxs),
                         "no function refers to this reflection entry", position(io))
            reflection_tags[function_idxs] .= Ref(reflection_buf)
        end
        format_check(position(io) == rlst.offset + rlst.size,
                     "reflection list does not match its size", rlst.offset)
    end

    # script list
    #
    # this section contains pipeline descriptor scripts
    if (slst = decoded(header_ex, "SLST")) !== nothing
        seek_section(io, slst.offset, slst.size, "script list")
        script_count = read(io, UInt32)
        for _ in 1:script_count
            _script_buf = read!(io, TagGroup())

            # script_buf["SBUF"] contains flatbuffer data; compare with:
            # $ metal-source -flatbuffers=binary
            # $ metal-source -flatbuffers=json
        end
        format_check(position(io) == slst.offset + slst.size,
                     "script list does not match its size", slst.offset)
    end

    # dynamic header
    #
    # this section records the name of the library
    dynamic_header = nothing
    if (hdyn = decoded(header_ex, "HDYN")) !== nothing
        seek_section(io, hdyn.offset, hdyn.size, "dynamic header")
        dynamic_header = read!(io, TagGroup(has_size=false))
        format_check(position(io) == hdyn.offset + hdyn.size,
                     "dynamic header does not match its size", hdyn.offset)
    end
    library_name = decoded(dynamic_header, "NAME")

    # variable and imported symbol lists
    raw_sections = Dict{String,Vector{UInt8}}()
    for tag in raw_section_tags
        if (section = decoded(header_ex, tag)) !== nothing
            seek_section(io, section.offset, section.size, tag)
            raw_sections[tag] = read(io, section.size)
        end
    end

    # embedded source
    #
    # there can be fewer sources than functions, so preserve the function -> source mapping
    embedded_source = nothing
    function_sources = Dict()
    hsrc = decoded(header_ex, "HSRC")
    hsrd = decoded(header_ex, "HSRD")
    if hsrc !== nothing || hsrd !== nothing
        # HSRC and HSRD are identical except for the working directory field
        format_check((hsrc === nothing) != (hsrd === nothing),
                     "both HSRC and HSRD embedded source sections")
        section = something(hsrc, hsrd)
        seek_section(io, section.offset, section.size, "embedded source")

        source_archive_count = read(io, UInt32)
        command_line_info = String(readuntil(io, UInt8(0)))
        working_directory = if hsrd !== nothing
            String(readuntil(io, UInt8(0)))
        else
            nothing
        end

        archives = []
        for _ in 1:source_archive_count
            # note the offset as used by the SOFF tag
            source_offset = position(io) + sizeof(UInt32) - section.offset

            data = read!(io, TagGroup(size_type=UInt32, counts_size=false))
            id, archive = decoded(data, "SARC", NamedTuple)
            push!(archives, id => archive)

            # check if any function points to this source
            for j in 1:length(function_list)
                if decoded(function_list[j], "SOFF") == source_offset
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
        if (constants = decoded(public_md[i], "CNST")) !== nothing
            push!(optional_args, :constants => constants)
        end
        if (debug_info = decoded(private_md[i], "DEBI")) !== nothing
            push!(optional_args, :debug_info => debug_info)
        end
        if (dependencies = decoded(private_md[i], "DEPF")) !== nothing
            push!(optional_args, :dependencies => dependencies)
        end
        if haskey(function_sources, i)
            push!(optional_args, :source_id => function_sources[i])
        end
        if (reflection_data = decoded(reflection_tags[i], "RBUF")) !== nothing
            push!(optional_args, :reflection_data => reflection_data)
        end
        versions = decoded(function_list[i], "VERS", NamedTuple)

        push!(functions, MetalLibFunction(;
            name = decoded(function_list[i], "NAME", String),
            type = decoded(function_list[i], "TYPE", ProgramType),
            air_module = module_list[i],
            air_version = versions.air,
            metal_version = versions.metal,
            layout = FunctionLayout(function_list[i], public_md[i], private_md[i],
                                    reflection_tags[i], module_digests[module_list[i]]),
            optional_args...
        ))
    end

    MetalLib(; file_version, file_type, is_macos, is_stub,
               platform_version, platform_type, is_64bit,
               functions, embedded_source,
               uuid = decoded(header_ex, "UUID"), library_name,
               layout = LibraryLayout(header_ex, dynamic_header, raw_sections))
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


    ## dynamic header

    dynamic_header = let io=IOBuffer()
        template = lib.layout === nothing ? nothing : lib.layout.dynamic_header
        dynamic_header_tags = layout_group(template, ["NAME" => lib.library_name];
                                           has_size=false)
        if !isempty(dynamic_header_tags.data)
            write(io, dynamic_header_tags)
        end
        take!(io)
    end


    ## variable and imported symbol lists

    raw_sections = lib.layout === nothing ? Dict{String,Vector{UInt8}}() :
                   lib.layout.raw_sections


    ## reflection list

    reflection_list_offsets = Vector{Union{Nothing,Int}}(nothing, length(lib.functions))

    reflection_list = let io=IOBuffer()
        # functions that were read sharing a reflection entry share its tag group; keep
        # sharing it unless their reflection data changed
        reflection_groups = Dict{Tuple{UInt,UInt},Tuple{Vector{Int},TagGroup}}()
        for (i, fun) in enumerate(lib.functions)
            template = fun.layout === nothing ? nothing : fun.layout.reflection_tags
            key = (objectid(template), objectid(fun.reflection_data))
            if haskey(reflection_groups, key)
                push!(reflection_groups[key][1], i)
            else
                tg = layout_group(template, ["RBUF" => fun.reflection_data])
                isempty(tg.data) || (reflection_groups[key] = ([i], tg))
            end
        end

        if !isempty(reflection_groups)
            write(io, UInt32(length(reflection_groups)))
            entries = sort!(collect(values(reflection_groups)); by=first)
            for (function_idxs, reflection_tags) in entries
                reflection_list_offsets[function_idxs] .= position(io)
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

    # modules shared by several functions are only written once
    module_offsets = IdDict{Vector{UInt8},Int}()
    module_digests = IdDict{Vector{UInt8},Vector{UInt8}}()

    for (i, fun) in enumerate(lib.functions)
        layout = fun.layout

        # public metadata
        public_md_offset = position(public_md_stream)
        public_md_tags = layout_group(layout === nothing ? nothing : layout.public_tags,
            ["CNST" => isempty(fun.constants) ? nothing : fun.constants])
        write(public_md_stream, public_md_tags)

        # private metadata
        private_md_offset = position(private_md_stream)
        private_md_tags = layout_group(layout === nothing ? nothing : layout.private_tags,
            ["DEBI" => fun.debug_info,
             "DEPF" => isempty(fun.dependencies) ? nothing : fun.dependencies])
        write(private_md_stream, private_md_tags)

        # module
        module_list_offset = get!(module_offsets, fun.air_module) do
            offset = position(module_list_stream)
            write(module_list_stream, fun.air_module)
            offset
        end
        module_hash = get!(() -> sha256(fun.air_module), module_digests, fun.air_module)
        if layout !== nothing && module_hash == layout.module_digest
            module_hash = something(decoded(layout.function_tags, "HASH"), module_hash)
        end
        module_size = sizeof(fun.air_module)

        # tags
        source_offset = if fun.source_id !== nothing
            get(embedded_source_offsets, fun.source_id, nothing)
        end
        reflection_offset = if lib.file_version >= v"1.2.7"
            reflection_list_offsets[i]
        end
        function_tags = layout_group(layout === nothing ? nothing : layout.function_tags, [
            "NAME" => fun.name,
            "TYPE" => fun.type,
            "HASH" => module_hash,
            "OFFT" => (; public_md=public_md_offset,
                         private_md=private_md_offset,
                         air_module=module_list_offset),
            "VERS" => (; air=fun.air_version, metal=fun.metal_version),
            "MDSZ" => module_size,
            "SOFF" => source_offset,
            "RFLT" => reflection_offset])
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
        # section offsets are patched in when writing the sections
        embedded_source_tag = lib.file_version >= v"1.2.6" ? "HSRD" : "HSRC"
        section(data) = sizeof(data) > 0 ? (; offset=0, size=sizeof(data)) : nothing
        template = lib.layout === nothing ? nothing : lib.layout.header_extension
        header_ex_tags = layout_group(template, [
            embedded_source_tag => section(embedded_source),
            "HDYN" => section(dynamic_header),
            (tag => section(get(raw_sections, tag, UInt8[])) for tag in raw_section_tags)...,
            "RLST" => lib.file_version >= v"1.2.7" ? section(reflection_list) : nothing,
            "UUID" => lib.uuid]; has_size=false)

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
        _position = mark(io)
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
    if sizeof(dynamic_header) > 0
        mark_placeholder(:dynamic_header_offset,
                         position(io) + offsetof(header_ex_tags, "HDYN"))
    end
    for (tag, data) in raw_sections
        if sizeof(data) > 0
            mark_placeholder(Symbol(tag), position(io) + offsetof(header_ex_tags, tag))
        end
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

    # dynamic header
    if sizeof(dynamic_header) > 0
        patch_placeholder(io, :dynamic_header_offset, position(io))
        write(io, dynamic_header)
    end

    # variable list and imported symbol list
    for tag in raw_section_tags
        data = get(raw_sections, tag, UInt8[])
        if sizeof(data) > 0
            patch_placeholder(io, Symbol(tag), position(io))
            write(io, data)
        end
    end

    # reflection list
    if sizeof(reflection_list) > 0
        patch_placeholder(io, :reflection_list_offset, position(io))
        write(io, reflection_list)
    end

    # TODO: script list

    patch_placeholder(io, :file_size, position(io))
end
