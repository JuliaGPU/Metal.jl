export MtlError

const MTLError = Ptr{NsError}

mutable struct MtlError <: Exception
	code::NsInteger
	domain::String
	userinfo::String

	ptr::MTLError
end

Base.unsafe_convert(::Type{MTLError}, err::MtlError) = err.ptr

function MtlError(err::MTLError)
	code = mtErrorCode(err)
	domain = mtErrorDomain(err) |> unsafe_string
	userinfo = mtErrorUserInfo(err) |> unsafe_string

	obj = MtlError(code, domain, userinfo, err)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(err::MtlError)
	mtRelease(err.ptr)
end


## properties

Base.propertynames(::MtlError) = (
	# error properties
	:code, :domain, :userInfo,
	# localized error descriptions
	:localizedDescription, :localizedRecoveryOptions,
	:localizedRecoverySuggestion, :localizedFailureReason)

function Base.getproperty(o::MtlError, f::Symbol)
    if f === :code
        mtErrorCode(o)
    elseif f === :domain
        unsafe_string(mtErrorDomain(o))
    elseif f === :userinfo 
        ptr = mtErrorUserInfo(o)
        if ptr == C_NULL
			Dict{String,Any}()
		else
			JSON.parse(unsafe_string(ptr))
		end		
    elseif f === :localizedDescription
        unsafe_string(mtErrorLocalizedDescription(o))
    elseif f === :localizedRecoveryOptions
		count = Ref{Csize_t}(0)
		mtErrorLocalizedRecoveryOptions(o, count, C_NULL)
		options = Vector{String}(undef, count[])
		mtErrorLocalizedRecoveryOptions(o, count, options)
		unsafe_string.(options)
    elseif f === :localizedRecoverySuggestion
        ptr = mtErrorLocalizedRecoverySuggestion(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    elseif f === :localizedFailureReason
        ptr = mtErrorLocalizedFailureReason(o)
        ptr == C_NULL ? nothing : unsafe_string(ptr)
    else
        getfield(o, f)
    end
end


## display

function Base.showerror(io::IO, err::MtlError)
	print(io, "MtlError: $(err.localizedDescription) (code $(err.code), $(err.domain))")

	if err.localizedFailureReason !== nothing
		print(io, "\nFailure reason: $(err.localizedFailureReason)")
	end

	recovery_options = err.localizedRecoveryOptions
	if !isempty(recovery_options)
		print(io, "\nRecovery Options:")
		for option in recovery_options
			print(io, "\n - $(option)")
		end
	end
end
