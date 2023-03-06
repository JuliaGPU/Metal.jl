module cmt

using cmt_jll
using ObjectiveC, .Foundation

include("libcmt.jl")

# export everything
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include)
        @eval export $n
    end
end

function __init__()
    precompiling = ccall(:jl_generating_output, Cint, ()) != 0
    precompiling && return

    if !cmt_jll.is_available()
        @error """Metal library wrapper not available for your platform."""
        return
    end
end

end
