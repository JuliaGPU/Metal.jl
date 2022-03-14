export MtlCompileOptions

const MTLCompileOptions = Ptr{MtCompileOptions}

mutable struct MtlCompileOptions
    handle::MTLCompileOptions
end

Base.unsafe_convert(::Type{MTLCompileOptions}, opts::MtlCompileOptions) = opts.handle

Base.:(==)(a::MtlCompileOptions, b::MtlCompileOptions) = a.handle == b.handle
Base.hash(opts::MtlCompileOptions, h::UInt) = hash(opts.handle, h)

function MtlCompileOptions()
    handle = mtNewCompileOpts()
    obj = MtlCompileOptions(handle)
    finalizer(unsafe_destroy!, obj)
    return obj
end

function unsafe_destroy!(opts::MtlCompileOptions)
    opts.handle !== C_NULL && mtRelease(opts.handle)
end


## properties

Base.propertynames(::MtlCompileOptions) = (:fastMathEnabled, :languageVersion)

const language_versions = Dict(
    MtLanguageVersion1_0 => v"1.0",
    MtLanguageVersion1_1 => v"1.1",
    MtLanguageVersion1_2 => v"1.2",
    MtLanguageVersion2_0 => v"2.0",
    MtLanguageVersion2_1 => v"2.1",
    MtLanguageVersion2_2 => v"2.2",
    MtLanguageVersion2_3 => v"2.3",
    MtLanguageVersion2_4 => v"2.4",
)

function Base.getproperty(opts::MtlCompileOptions, f::Symbol)
    if f === :fastMathEnabled
        mtCompileOptsFastMath(opts)
    elseif f === :languageVersion
        ver = mtCompileOptsLanguageVersion(opts)
        haskey(language_versions, ver) || error("Unknown language version $ver; please file an issue.")
        language_versions[ver]
    else
        getfield(opts, f)
    end
end

function Base.setproperty!(opts::MtlCompileOptions, f::Symbol, val)
    if f === :fastMathEnabled
        mtCompileOptsFastMathSet(opts, val)
    elseif f === :languageVersion
        isa(val, VersionNumber) ||
            throw(ArgumentError("languageVersion property should be a version number"))
        for (enum,ver) in language_versions
            if ver === val
                mtCompileOptsLanguageVersionSet(opts, enum)
                return
            end
        end
        error("Unknown language version $val")
    else
        setfield!(opts, f, val)
    end
end


## display

function Base.show(io::IO, opts::MtlCompileOptions)
    print(io, "CompileOptions(…)")
end

function Base.show(io::IO, ::MIME"text/plain", opts::MtlCompileOptions)
    println(io, "CompileOptions:")
    println(io, " fast math:        ", opts.fastMathEnabled)
    print(io,   " language version: ", opts.languageVersion)
end
