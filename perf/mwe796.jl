# MWE for the #796 accumulate/checked-indexing benchmark regression.
# Version-agnostic: runs on both pre- and post-#796 trees.

using Metal
using BenchmarkTools

@info "Configuration" pkgdir(Metal) Base.pkgversion(Metal.GPUCompiler) Base.JLOptions().debug_level

const n_el = 512 * 1000

# kernels from perf/kernel.jl: identical except for bounds checking,
# i.e. the presence of an exception (throw) path
function indexing_kernel(dest, src)
    i = thread_position_in_grid().x
    @inbounds dest[i] = src[i]
    return
end

function checked_indexing_kernel(dest, src)
    i = thread_position_in_grid().x
    dest[i] = src[i]
    return
end

src = Metal.rand(Float32, 512, 1000)
dest = similar(src)

# occupancy proxy: max threads per threadgroup is determined by register usage
let
    kern_unchecked = @metal launch=false indexing_kernel(dest, src)
    kern_checked = @metal launch=false checked_indexing_kernel(dest, src)
    println("maxTotalThreadsPerThreadgroup:")
    println("  unchecked: ", kern_unchecked.pipeline.maxTotalThreadsPerThreadgroup)
    println("  checked:   ", kern_checked.pipeline.maxTotalThreadsPerThreadgroup)
end

# the scan kernel used by accumulate
let
    f = +
    vec = reshape(src, length(src))
    output = similar(vec)
    Rdim = CartesianIndices((n_el,))
    Rpre = CartesianIndices(())
    Rpost = CartesianIndices(())
    Rother = CartesianIndices((1,))
    maxthreads = 1024
    kern = @metal launch=false Metal.partial_scan(f, output, vec, Rdim, Rpre, Rpost,
                                                  Rother, zero(Float32), nothing,
                                                  Val(maxthreads), Val(true))
    println("  partial_scan: ", kern.pipeline.maxTotalThreadsPerThreadgroup)
end

t = @belapsed(Metal.@sync(@metal threads=512 groups=1000 indexing_kernel($dest, $src)))
println("indexing (unchecked): ", round(t * 1e6; digits=1), " us")

t = @belapsed(Metal.@sync(@metal threads=512 groups=1000 checked_indexing_kernel($dest, $src)))
println("indexing (checked):   ", round(t * 1e6; digits=1), " us")

gpu_vec = reshape(src, length(src))
t = @belapsed Metal.@sync accumulate(+, $gpu_vec)
println("accumulate 1d:        ", round(t * 1e6; digits=1), " us")
