## GPUArrays interfaces

GPUArrays.device(x::MtlArray) = x.dev


## execution

struct mtlArrayBackend <: AbstractGPUBackend end

struct mtlKernelContext <: AbstractKernelContext end

@inline function GPUArrays.launch_heuristic(::mtlArrayBackend, f::F, args::Vararg{Any,N};
                                             elements::Int, elements_per_thread::Int) where {F,N}
    kernel = @metal launch=false f(mtlKernelContext(), args...)

    items = 32 # suggest_groupsize(kernel.fun, elements).x
    return (threads=items, blocks=32)
end

function GPUArrays.gpu_call(::mtlArrayBackend, f, args, threads::Int, blocks::Int;
                            name::Union{String,Nothing})
    @metal items=threads groups=blocks name=name f(mtlKernelContext(), args...)
end


## on-device

# indexing
# TODO: Are these all 1d?
GPUArrays.blockidx(ctx::mtlKernelContext)  = Metal.threadgroup_position_in_grid_1d()
GPUArrays.blockdim(ctx::mtlKernelContext)  = Metal.threads_per_threadgroup_1d()
GPUArrays.threadidx(ctx::mtlKernelContext) = Metal.thread_position_in_threadgroup_1d()
GPUArrays.griddim(ctx::mtlKernelContext)   = Metal.threadgroups_per_grid_1d()

# math

@inline GPUArrays.cos(ctx::mtlKernelContext, x) = Metal.cos(x)
@inline GPUArrays.sin(ctx::mtlKernelContext, x) = Metal.sin(x)
# @inline GPUArrays.sqrt(ctx::mtlKernelContext, x) = Metal.sqrt(x)
# @inline GPUArrays.log(ctx::mtlKernelContext, x) = Metal.log(x)

# memory

# @inline function GPUArrays.LocalMemory(::oneKernelContext, ::Type{T}, ::Val{dims}, ::Val{id}
#                                       ) where {T, dims, id}
#     ptr = oneAPI.emit_localmemory(Val(id), T, Val(prod(dims)))
#     oneDeviceArray(dims, LLVMPtr{T, onePI.AS.Local}(ptr))
# end

# synchronization

# @inline GPUArrays.synchronize_threads(::oneKernelContext) = oneAPI.barrier()



#
# Host abstractions
#

GPUArrays.backend(::Type{<:MtlArray}) = mtlArrayBackend()

# const GLOBAL_RNGs = Dict{ZeDevice,GPUArrays.RNG}()
# function GPUArrays.default_rng(::Type{<:oneArray})
#     dev = device()
#     get!(GLOBAL_RNGs, dev) do
#         N = oneL0.compute_properties(dev).maxTotalGroupSize
#         state = oneArray{NTuple{4, UInt32}}(undef, N)
#         rng = GPUArrays.RNG(state)
#         Random.seed!(rng)
#         rng
#     end
# end