# display of Metal libraries

function Base.show(io::IO, lib::MetalLib)
    println(io, "MetalLib(")

    print(io, "  file: $(lib.file_type) v$(lib.file_version)")
    file_flags = []
    if lib.is_macos
        push!(file_flags, "macOS")
    end
    if lib.is_stub
        push!(file_flags, "stub")
    end
    if !isempty(file_flags)
        print(io, " [$(join(file_flags, ", "))]")
    end
    println(io)

    print(io, "  platform: $(lib.platform_type) v$(lib.platform_version)")
    platform_flags = []
    if lib.is_64bit
        push!(platform_flags, "64-bit")
    end
    if !isempty(platform_flags)
        print(io, " [$(join(platform_flags, ", "))]")
    end
    println(io)

    if lib.library_name !== nothing
        println(io, "  name: $(lib.library_name)")
    end

    println(io, "  functions:")

    for fun in lib.functions
        println(io, "    $(fun.name) [AIR v$(fun.air_version), Metal v$(fun.metal_version)]")
    end

    if lib.embedded_source !== nothing
        println(io, "  embedded source:")
        println(io, "    link options: $(lib.embedded_source.link_options)")
        if lib.embedded_source.working_directory !== nothing
            println(io, "    working directory: $(lib.embedded_source.working_directory)")
        end
        for (id, archive) in lib.embedded_source.archives
            tarball = decompress_source_archive(archive)
            println(io, "    archive $(id): $(sizeof(archive)) bytes ($(sizeof(tarball)) uncompressed)")
        end
    end

    print(io, ")")
end

@public MetalLib, MetalLibFunction, FunctionConstant, DebugInfo, MetalLibFormatError
