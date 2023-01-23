using Documenter, Base64

keyfile = joinpath(@__DIR__, "documenter.key")
isfile(keyfile) ||
    error("Missing documenter keyfile (is this running as part of a secure CI pipeline?)")
key = read(keyfile, String)

withenv("DOCUMENTER_KEY" => base64encode(key)) do
    deploydocs(
        repo = "github.com/JuliaGPU/Metal.jl.git",
        push_preview = true
    )
end
