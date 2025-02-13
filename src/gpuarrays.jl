## GPUArrays interfaces

const GLOBAL_RNGs = Dict{MTLDevice, GPUArrays.RNG}()
function GPUArrays.default_rng(::Type{<:MtlArray})
    dev = device()
    return get!(GLOBAL_RNGs, dev) do
        N = dev.maxThreadsPerThreadgroup.width
        state = MtlArray{NTuple{4, UInt32}}(undef, N)
        rng = GPUArrays.RNG(state)
        Random.seed!(rng)
        rng
    end
end
