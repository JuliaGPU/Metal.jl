using Documenter, Literate
using Metal

const src = "https://github.com/JuliaGPU/Metal.jl"
const dst = "https://metal.juliagpu.org/stable/" # TODO

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
            "Usage" => Any[
                "usage/overview.md",
                "usage/array.md",
                "usage/kernel.md",
            ],
            "Profiling" => "profiling.md",
            "API reference" => Any[
                "api/essentials.md",
                "api/compiler.md",
                "api/kernel.md",
                "api/array.md",
                "api/mps.md",
            ],
            "FAQ" => Any[
                "faq/faq.md",
                "faq/contributing.md",
            ],
        ]
    )
end

isinteractive() || main()
