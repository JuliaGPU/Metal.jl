export MtlError

const MTLError = Ptr{NsError}

mutable struct MtlError <: Exception
	code::NsInteger
	domain::String
	userinfo::String

	ptr::Ptr{NsError}
end

Base.convert(::Type{MTLError}, err::MtlError) = err.ptr
Base.unsafe_convert(::Type{MTLError}, err::MtlError) = convert(MTLError, err.ptr) 

function MtlError(err::Ptr{NsError})
	code = mtErrorCode(err) 
	domain = mtErrorDomain(err) |> unsafe_string
	userinfo = mtErrorUserInfo(err) |> unsafe_string

	obj = MtlError(code, domain, userinfo, err)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(err::MtlError)
	mtErrorRelease(err)
end

description(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedDescription(err))
recoverySuggestion(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedRecoverySuggestion(err))
failureReason(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedFailureReason(err))

function recoveryOptions(err::MtlError)
	options = mtErrorLocalizedRecoveryOptions(err)
	opts = Vector{String}();
	for i=0:typemax(Int)
		_opt = Base.unsafe_load(options + i * sizeof(Ptr{NsError}))
		_opt == C_NULL && break
		push!(opts, unsafe_string(_opt))
	end
	Base.Libc.free(options)
	return opts
end

Base.show(io::IO, ::MIME"text/plain", err::MtlError) = _show(io, err)
Base.show(io::IO, err::MtlError) = _show(io, err)

function _show(io::IO,  err::MtlError)
	println(io, "MtlError (Error in Metal Runtime):")
	println(io, " code     : ", err.code)
	println(io, " domain   : ", err.domain)
	println(io, " userinfo : ", replace(err.userinfo, "\\n"=>"\n"))

	isempty(description(err)) || println(io, "Description:", description(err))
	isempty(recoverySuggestion(err)) || println(io, "Suggestion:", recoverySuggestion(err))
	isempty(failureReason(err)) || println(io, "Failure Reason:", failureReason(err))
	isempty(recoveryOptions(err)) || println(io, "Recovery Options:", recoveryOptions(err))
end
