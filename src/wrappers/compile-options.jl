export MtlCompileOptions

const MTLCompileOptions = Ptr{MtCompileOptions}

mutable struct MtlCompileOptions
	handle::MTLCompileOptions
end

Base.convert(::Type{MTLCompileOptions}, opts::MtlCompileOptions) = opts.handle
Base.unsafe_convert(::Type{MTLCompileOptions}, opts::MtlCompileOptions) = convert(MTLCompileOptions, opts.handle) 

Base.:(==)(a::MtlCompileOptions, b::MtlCompileOptions) = a.handle == b.handle
Base.hash(opts::MtlCompileOptions, h::UInt) = hash(opts.handle, h)

function MtlCompileOptions()
	handle = mtNewCompileOpts()
	obj = MtlCompileOptions(handle)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(opts::MtlCompileOptions)
	opts.handle !== C_NULL && mtCompileOptsRelease(opts)
end

Base.propertynames(o::MtlCompileOptions) = (:fastmath, :languageversion)
function Base.getproperty(o::MtlCompileOptions, f::Symbol)
	if f === :handle
		return getfield(o, :handle)
	elseif f === :fastmath
		return mtCompileOptsFastMath(o)
	elseif f === :languageversion
		return mtCompileOptsLanguageVersion(o)
	else
		error("CompileOptions does not have field $f")
	end
end

function Base.setproperty!(o::MtlCompileOptions, f::Symbol, val)
	if f === :fastmath
		return mtCompileOptsFastMathSet(o, val)
	elseif f === :languageversion
		return mtCompileOptsLanguageVersionSet(o, val)
	else
		error("CompileOptions does not have field $f")
	end
end

function Base.show(io::IO, l::MtlCompileOptions)
	print(io, "CompileOptions(…)")
end

function Base.show(io::IO, ::MIME"text/plain", l::MtlCompileOptions)
	println(io, "CompileOptions:")
	println(io, " fastmath : ", l.fastmath)
	  print(io, " version  : ", l.languageversion)
end
