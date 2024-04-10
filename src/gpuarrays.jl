## GPUArrays interfaces

GPUArrays.device(x::MtlArray) = x.dev

import KernelAbstractions
import KernelAbstractions: Backend

struct mtlArrayBackend <: Backend end

@inline function GPUArrays.launch_heuristic(::mtlArrayBackend, f::F, args::Vararg{Any,N};
                                             elements::Int, elements_per_thread::Int) where {F,N}
    kernel = @metal launch=false f(mtlKernelContext(), args...)

    # The pipeline state automatically computes occupancy stats
    threads = min(elements, kernel.pipeline.maxTotalThreadsPerThreadgroup)
    blocks  = cld(elements, threads)

    return (; threads=Int(threads), blocks=Int(blocks))
end

const GLOBAL_RNGs = Dict{MTLDevice,GPUArrays.RNG}()
function GPUArrays.default_rng(::Type{<:MtlArray})
    dev = current_device()
    get!(GLOBAL_RNGs, dev) do
        N = dev.maxThreadsPerThreadgroup.width
        state = MtlArray{NTuple{4, UInt32}}(undef, N)
        rng = GPUArrays.RNG(state)
        Random.seed!(rng)
        rng
    end
end
