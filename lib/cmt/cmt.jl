module cmt

using CEnum

using cmt_jll
const libcmt = cmt_jll.libcmt

include("libcmt.jl")

# export everything
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include)
        @eval export $n
    end
end

end
