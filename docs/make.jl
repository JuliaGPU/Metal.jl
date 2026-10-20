using Documenter, Literate
using Metal

const src = "https://github.com/JuliaGPU/Metal.jl"
const dst = "https://metal.juliagpu.org/stable/" # TODO

function main()
    ci = get(ENV, "CI", "") == "true"

    @info "Building Literate.jl documentation"
    cd(@__DIR__) do
        Literate.markdown(
            "src/tutorials/introduction.jl", "src/tutorials";
            repo_root_url = "https://github.com/JuliaGPU/Metal.jl/blob/main/docs"
        )
    end

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
        warnonly = true,
        modules = [Metal],
        pages = Any[
            "Home" => "index.md",
            "Introduction" => "tutorials/introduction.md",
            "Usage" => Any[
                "usage/array.md",
                "usage/memory.md",
                "usage/tasks.md",
                "usage/kernel.md",
                "usage/kernel_advanced.md",
                "usage/numerical.md",
                "usage/kernelabstractions.md",
            ],
            "Development" => Any[
                "development/performance.md",
                "development/profiling.md",
                "development/xcode.md",
                "development/troubleshooting.md",
                "development/configuration.md",
            ],
            "API reference" => Any[
                "api/essentials.md",
                "api/compiler.md",
                "api/kernel.md",
                "api/array.md",
                "api/mps.md",
                "api/mpsgraphs.md",
                "api/libraries.md",
            ],
            "Developers" => Any[
                "developers/contributing.md",
                "developers/hacking.md",
            ],
        ]
    )

    if ci
        deploydocs(
            repo = "github.com/JuliaGPU/Metal.jl.git",
            push_preview = true
        )
    end
end

isinteractive() || main()
