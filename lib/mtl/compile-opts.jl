#
# Extra definitions to go with MTLLanguageVersion defined in libmtl.jl
#

const language_versions = Dict(
    MTLLanguageVersion1_0 => v"1.0",
    MTLLanguageVersion1_1 => v"1.1",
    MTLLanguageVersion1_2 => v"1.2",
    MTLLanguageVersion2_0 => v"2.0",
    MTLLanguageVersion2_1 => v"2.1",
    MTLLanguageVersion2_2 => v"2.2",
    MTLLanguageVersion2_3 => v"2.3",
    MTLLanguageVersion2_4 => v"2.4",
    MTLLanguageVersion3_0 => v"3.0",
    MTLLanguageVersion3_1 => v"3.1",
    MTLLanguageVersion3_2 => v"3.2",
)

function Base.convert(::Type{VersionNumber}, ver::MTLLanguageVersion)
    haskey(language_versions, ver) || error("Unknown language version $ver; please file an issue.")
    language_versions[ver]
end

function Base.convert(::Type{MTLLanguageVersion}, ver::VersionNumber)
    for (k, v) in language_versions
        v == ver && return k
    end
    error("Unknown language version $ver; please file an issue.")
end


#
# compile options
#

export MTLCompileOptions

# @objcwrapper immutable=false MTLCompileOptions <: NSObject

function MTLCompileOptions()
    handle = @objc [MTLCompileOptions new]::id{MTLCompileOptions}
    obj = MTLCompileOptions(handle)
    finalizer(release, obj)
    return obj
end
