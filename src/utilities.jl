"""
    @sync ex

Run expression `ex` and synchronize the GPU afterwards.

See also: [`synchronize`](@ref).
"""
macro sync(code)
    quote
        local ret = $(esc(code))
        synchronize()
        ret
    end
end

function versioninfo(io::IO=stdout)
    println(io, "macOS $(macos_version()), Darwin $(darwin_version())")
    println(io)

    println(io, "Toolchain:")
    println(io, "- Julia: $VERSION")
    println(io, "- LLVM: $(LLVM.version())")
    println(io)

    env = filter(var->startswith(var, "JULIA_METAL") || startswith(var, "MTL"), keys(ENV))
    if !isempty(env)
        println(io, "Environment:")
        for var in env
            println(io, "- $var: $(ENV[var])")
        end
        println(io)
    end

    devs = devices()
    if isempty(devs)
        println(io, "No Metal devices.")
    elseif length(devs) == 1
        println(io, "1 device:")
    else
        println(io, length(devs), " devices:")
    end
    for (i, dev) in enumerate(devs)
        println(io, "- $(dev.name) ($(Base.format_bytes(dev.currentAllocatedSize)) allocated)")
    end

    return
end
