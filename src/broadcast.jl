# broadcasting

using Base.Broadcast: BroadcastStyle, Broadcasted

struct MtlArrayStyle{N,S} <: AbstractGPUArrayStyle{N} end
MtlArrayStyle{M,S}(::Val{N}) where {N,M,S} = MtlArrayStyle{N,S}()

# identify the broadcast style of a (wrapped) MtlArray
BroadcastStyle(::Type{<:MtlArray{T,N,S}}) where {T,N,S} = MtlArrayStyle{N,S}()
BroadcastStyle(W::Type{<:WrappedMtlArray{T,N}}) where {T,N} =
    MtlArrayStyle{N, storagemode(Adapt.unwrap_type(W))}()

# when we are dealing with different buffer styles, we cannot know
# which one is better, so use shared memory
BroadcastStyle(::MtlArrayStyle{N, S1},
               ::MtlArrayStyle{N, S2}) where {N,S1,S2} =
    MtlArrayStyle{N, Shared}()

# allocation of output arrays
Base.similar(bc::Broadcasted{MtlArrayStyle{N,S}}, ::Type{T}, dims) where {T,N,S} =
    similar(MtlArray{T,length(dims),S}, dims)
