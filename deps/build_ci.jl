using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Git, Scratch, Dates

Metal = Base.UUID("dde4c033-4e86-420c-a63e-0dd931031962")

# get scratch directories
support_dir = get_scratch!(Metal, "support")

# is this a full-fledged check-out?
if isdir(joinpath(@__DIR__), "..", ".git")
    # determine latest change to the wrappers
    deps_timestamp = parse(Int, read(`$(git()) -C $(@__DIR__) log -1 --format=%ct cmt`, String))
    @info "Latest change to the wrappers: $(unix2datetime(deps_timestamp))"

    # find out which version of cmt_jll we are using
    Pkg.activate(joinpath(@__DIR__, ".."))
    deps = collect(values(Pkg.dependencies()))
    filter!(deps) do dep
        dep.name == "cmt_jll"
    end
    library_version = only(deps).version
    @info "cmt_jll version: $(library_version)"

    # compare to the JLL's tags
    jll_tags = mktempdir() do dir
        if !isdir(joinpath(support_dir, ".git"))
            run(`$(git()) clone -q https://github.com/JuliaBinaryWrappers/cmt_jll.jl $dir`)
        else
            run(`$(git()) -C $dir fetch -q`)
        end
        tags = Dict{String,Int}()
        for line in eachline(`$(git()) -C $dir tag --format "%(refname:short) %(creatordate:unix)"`)
            tag, timestamp = split(line)
            tags[tag] = parse(Int, timestamp)
        end
        tags
    end
    jll_timestamp = jll_tags["cmt-v$(library_version)"]
    @info "cmt_jll timestamp: $(unix2datetime(jll_timestamp))"

    if deps_timestamp > jll_timestamp
        @info "Wrappers have changed since the last JLL build. Building the support library locally."
        include(joinpath(@__DIR__, "build_local.jl"))
    else
        @info "Wrappers have not changed since the last JLL build. Using the JLL's support library."
    end
else
    @warn """Metal.jl source code is not checked-out from Git.
             This means we cannot check for changes, and need to unconditionally build the support library."""
    include(joinpath(@__DIR__, "build_local.jl"))
end
