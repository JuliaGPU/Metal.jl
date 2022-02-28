# broadcasting

using Base.Broadcast: BroadcastStyle, Broadcasted

struct MtlArrayStyle{N} <: AbstractGPUArrayStyle{N} end
MtlArrayStyle(::Val{N}) where N = MtlArrayStyle{N}()
MtlArrayStyle{M}(::Val{N}) where {N,M} = MtlArrayStyle{N}()

BroadcastStyle(::Type{<:MtlArray{T,N}}) where {T,N} = MtlArrayStyle{N}()

Base.similar(bc::Broadcasted{MtlArrayStyle{N}}, ::Type{T}) where {N,T} =
    similar(MtlArray{T}, axes(bc))

Base.similar(bc::Broadcasted{MtlArrayStyle{N}}, ::Type{T}, dims...) where {N,T} =
    MtlArray{T}(undef, dims...)
