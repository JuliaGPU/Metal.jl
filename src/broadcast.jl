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

# broadcasting type ctors isn't GPU compatible
Broadcast.broadcasted(::MtlArrayStyle{N}, f::Type{T}, args...) where {N, T} =
    Broadcasted{MtlArrayStyle{N}}((x...) -> T(x...), args, nothing)
