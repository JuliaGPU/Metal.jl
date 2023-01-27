## GPUArrays interfaces

GPUArrays.device(x::MtlArray) = x.dev


## execution

struct mtlArrayBackend <: AbstractGPUBackend end

struct mtlKernelContext <: AbstractKernelContext end

@inline function GPUArrays.launch_heuristic(::mtlArrayBackend, f::F, args::Vararg{Any,N};
                                             elements::Int, elements_per_thread::Int) where {F,N}
    kernel = @metal launch=false f(mtlKernelContext(), args...)

    # The pipeline state automatically computes occupancy stats
    threads = min(elements, kernel.pipeline_state.maxTotalThreadsPerThreadgroup)
    blocks  = cld(elements, threads)

    return (; threads, blocks)
end

function GPUArrays.gpu_call(::mtlArrayBackend, f, args, threads::Int, blocks::Int;
                            name::Union{String,Nothing})
    @metal threads=threads grid=blocks name=name f(mtlKernelContext(), args...)
end


## on-device

# indexing
GPUArrays.blockidx(ctx::mtlKernelContext)     = Metal.threadgroup_position_in_grid_1d()
GPUArrays.blockdim(ctx::mtlKernelContext)     = Metal.threads_per_threadgroup_1d()
GPUArrays.threadidx(ctx::mtlKernelContext)    = Metal.thread_position_in_threadgroup_1d()
GPUArrays.griddim(ctx::mtlKernelContext)      = Metal.threadgroups_per_grid_1d()
GPUArrays.global_index(ctx::mtlKernelContext) = Metal.thread_position_in_grid_1d()

# math

@inline GPUArrays.cos(ctx::mtlKernelContext, x)  = cos(x)
@inline GPUArrays.sin(ctx::mtlKernelContext, x)  = sin(x)
@inline GPUArrays.sqrt(ctx::mtlKernelContext, x) = sqrt(x)
@inline GPUArrays.log(ctx::mtlKernelContext, x)  = log(x)

# memory

@inline function GPUArrays.LocalMemory(::mtlKernelContext, ::Type{T}, ::Val{dims}, ::Val{id}
                                      ) where {T, dims, id}
    ptr = Metal.emit_threadgroup_memory(T, Val(prod(dims)))
    MtlDeviceArray(dims, ptr)
end

# synchronization

@inline GPUArrays.synchronize_threads(::mtlKernelContext) =
    Metal.threadgroup_barrier(Metal.MemoryFlagThreadGroup)



#
# Host abstractions
#

GPUArrays.backend(::Type{<:MtlArray}) = mtlArrayBackend()

const GLOBAL_RNGs = Dict{MtlDevice,GPUArrays.RNG}()
function GPUArrays.default_rng(::Type{<:MtlArray})
    dev = MtlDevice(1)
    get!(GLOBAL_RNGs, dev) do
        N = 128 # Size of default oneAPI working group with barrier, so should be good for Metal
        state = MtlArray{NTuple{4, UInt32}}(undef, N)
        rng = GPUArrays.RNG(state)
        Random.seed!(rng)
        rng
    end
end
