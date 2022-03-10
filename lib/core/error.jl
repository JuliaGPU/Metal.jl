export MtlError

const MTLError = Ptr{NsError}

mutable struct MtlError <: Exception
	code::NsInteger
	domain::String
	userinfo::String

	ptr::MTLError
end

Base.convert(::Type{MTLError}, err::MtlError) = err.ptr
Base.unsafe_convert(::Type{MTLError}, err::MtlError) = convert(MTLError, err.ptr)

function MtlError(err::MTLError)
	code = mtErrorCode(err)
	domain = mtErrorDomain(err) |> unsafe_string
	userinfo = mtErrorUserInfo(err) |> unsafe_string

	obj = MtlError(code, domain, userinfo, err)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(err::MtlError)
	mtRelease(err)
end

description(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedDescription(err))
recoverySuggestion(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedRecoverySuggestion(err))
failureReason(err::MtlError) = unsafe_string_maybe(mtErrorLocalizedFailureReason(err))

function recoveryOptions(err::MtlError)
	count = Ref{Csize_t}(0)
	mtErrorLocalizedRecoveryOptions(err, count, C_NULL)
	options = Vector{String}(undef, count[])
	mtErrorLocalizedRecoveryOptions(err, count, options)
	unsafe_string.(options)
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
