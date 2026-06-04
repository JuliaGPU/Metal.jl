# see mwe796.jl: per-debug-level timing of the raw partial_scan kernel; requires the
# `@metal debug_level=` keyword (post-#796)

let vec = gpu_vec
    output = similar(vec)
    Rdim = CartesianIndices((n_el,))
    Rpre = CartesianIndices(())
    Rpost = CartesianIndices(())
    Rother = CartesianIndices((1, 1))
    for level in 0:2
        kern = @metal launch=false debug_level=level Metal.partial_scan(
            +, output, vec, Rdim, Rpre, Rpost, Rother, 0.0f0, nothing,
            Val(1024), Val(true))
        t = @belapsed Metal.@sync $kern(+, $output, $vec, $Rdim, $Rpre, $Rpost, $Rother,
                                        0.0f0, nothing, Val(1024), Val(true);
                                        threads=1024, groups=(500, 1, 1))
        println("partial_scan -g$level:      ", round(t * 1e6; digits=1), " us")
    end
end
