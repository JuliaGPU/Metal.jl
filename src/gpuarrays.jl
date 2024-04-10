## GPUArrays interfaces

GPUArrays.device(x::MtlArray) = x.dev

import KernelAbstractions
import KernelAbstractions: Backend

@inline function GPUArrays.launch_heuristic(::MetalBackend, f::F, args::Vararg{Any,N};
                                             elements::Int, elements_per_thread::Int) where {F,N}

    ndrange, workgroupsize, iterspace, dynamic = KA.launch_config(obj, nothing,
                                                                  nothing)

    # this might not be the final context, since we may tune the workgroupsize
    ctx = KA.mkcontext(obj, ndrange, iterspace)

    kernel = @metal launch=false f(ctx(), args...)

    # The pipeline state automatically computes occupancy stats
    threads = min(elements, kernel.pipeline.maxTotalThreadsPerThreadgroup)
    blocks  = cld(elements, threads)

    return (; threads=Int(threads), blocks=Int(blocks))
end

const GLOBAL_RNGs = Dict{MTLDevice,GPUArrays.RNG}()
function GPUArrays.default_rng(::Type{<:MtlArray})
    dev = device()
    get!(GLOBAL_RNGs, dev) do
        N = dev.maxThreadsPerThreadgroup.width
        state = MtlArray{NTuple{4, UInt32}}(undef, N)
        rng = GPUArrays.RNG(state)
        Random.seed!(rng)
        rng
    end
end
