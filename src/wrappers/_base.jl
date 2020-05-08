function unsafe_string_maybe(ptr::Cstring)
	if ptr == C_NULL
		return ""
	else
		return unsafe_string(ptr)
	end
end