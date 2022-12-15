using Documenter, Literate
using Metal

const src = "https://github.com/JuliaGPU/Metal.jl"
const dst = "https://cuda.juliagpu.org/stable/" # TODO

function main()
    ci = get(ENV, "CI", "") == "true"

    @info "Generating Documenter.jl site"
    DocMeta.setdocmeta!(Metal, :DocTestSetup, :(using Metal); recursive=true)
    makedocs(
        sitename = "Metal.jl",
        authors = "Tim Besard", # TODO: Who to put
        repo = "$src/blob/{commit}{path}#{line}",
        format = Documenter.HTML(
            # Use clean URLs on CI
            prettyurls = ci,
            canonical = dst,
            assets = ["assets/favicon.ico"],
            analytics = "", # TODO
        ),
        doctest = true,
        #strict = true,
        modules = [Metal],
        pages = Any[
            "Home" => "index.md",
            "API reference" => Any[
                "api/essentials.md",
                "api/compiler.md",
                "api/kernel.md",
                "api/array.md",
            ],
            "Profiling" => "profiling.md",
            "FAQ" => "faq.md",
        ]
    )

    if ci
        @info "Deploying to GitHub"
        deploydocs(
            repo = "github.com/JuliaGPU/Metal.jl.git",
            push_preview = true
        )
    end
end

isinteractive() || main()
