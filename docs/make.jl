using Documenter, Literate
using Metal
using Metal: MPS, MPSGraphs, MTL

const dst = "https://metal.juliagpu.org/stable/"

# Public names of `mod` that it owns but that have no docstring. Names re-exported from
# other packages are documented there, and deprecated functions shouldn't be documented.
function undocumented_public_names(mod::Module)
    deprecated = (:current_device,)
    filter(Docs.undocumented_names(mod)) do name
        name === nameof(mod) && return true
        isdefined(mod, name) || return true
        Base.binding_module(mod, name) === mod || return false
        (name in deprecated || contains(string(name), r"_[123]d$")) && return false
        # enum values are documented by their type
        T = typeof(getfield(mod, name))
        !(isprimitivetype(T) && parentmodule(T) === mod && Docs.hasdoc(mod, nameof(T)))
    end
end

# Documenter only renders docstrings of the checked modules, which excludes MTL and MPS (see
# `checkdocs_ignored_modules` below). Register the few of their docstrings that the manual
# shows with Metal too.
function register_docs(bindings)
    for binding in bindings
        multidoc = Docs.meta(binding.mod)[binding]
        copy = Docs.MultiDoc()
        for sig in multidoc.order
            docstr = multidoc.docs[sig]
            data = merge(docstr.data, Dict{Symbol,Any}(:module => Metal))
            copy.docs[sig] = Docs.DocStr(docstr.text, docstr.object, data)
            push!(copy.order, sig)
        end
        Docs.meta(Metal)[binding] = copy
    end
end
register_docs(Docs.Binding(mod, name) for (mod, name) in [
    (MTL, :MTLDevice), (MTL, :devices), (MTL, :CommandBufferError),
    (MPS, :matmul!), (MPS, :matvecmul!), (MPS, :MPS_VALID_MATMUL_TYPES),
    (MPS, :MPS_VALID_MATVECMUL_TYPES), (MPS, :topk), (MPS, :topk!), (MPS, :RNG),
    (MPS, :MPSMatrix), (MPS, :MPSVector),
])

function main()
    ci = get(ENV, "CI", "") == "true"

    @static if VERSION >= v"1.11"
        for mod in (Metal, MPSGraphs)
            missing = undocumented_public_names(mod)
            isempty(missing) ||
                error("Public names of $mod without a docstring: $(join(missing, ", "))")
        end
    end

    @info "Building Literate.jl documentation"
    cd(@__DIR__) do
        Literate.markdown(
            "src/tutorials/introduction.jl", "src/tutorials";
            repo_root_url = "https://github.com/JuliaGPU/Metal.jl/blob/main/docs"
        )
    end

    # On a virtualized GPU, like the one of the macOS runners, creating the device warns.
    # Doing so here keeps that warning out of the doctest output: Documenter evaluates every
    # doctest with a fresh logger, defeating `maxlog`, but in this task, which caches the
    # device.
    Metal.device()

    @info "Generating Documenter.jl site"
    DocMeta.setdocmeta!(Metal, :DocTestSetup, :(using Metal); recursive=true)
    makedocs(
        sitename = "Metal.jl",
        authors = "Tim Besard and contributors",
        repo = Remotes.GitHub("JuliaGPU", "Metal.jl"),
        format = Documenter.HTML(
            # Use clean URLs on CI
            prettyurls = ci,
            canonical = dst,
            assets = ["assets/favicon.ico"],
            # the kernel API page lists many intrinsics
            size_threshold_warn = 150 * 2^10,
        ),
        doctest = true,
        modules = [Metal],
        checkdocs = :public,
        # these wrap Apple's frameworks, which Apple's documentation covers
        checkdocs_ignored_modules = [MTL, MPS],
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
