function sort_descending(lt, by, rev::Union{Bool,Nothing}, order::Base.Order.Ordering)
    lt === isless || return nothing
    by === identity || return nothing

    descending = if order === Base.Order.Forward
        false
    elseif order === Base.Order.Reverse
        true
    else
        return nothing
    end

    return rev === true ? !descending : descending
end

function mps_sort_descending(::Type{T}, lt, by, rev::Union{Bool,Nothing},
                             order::Base.Order.Ordering) where {T}
    T <: MPSGraphs.MPSGRAPH_VALID_SORT_TYPES || return nothing
    return sort_descending(lt, by, rev, order)
end

mps_sort_descending(A::MtlArray{T}, lt, by, rev::Union{Bool,Nothing},
                    order::Base.Order.Ordering) where {T} =
    A.offset == 0 ? mps_sort_descending(T, lt, by, rev, order) : nothing

function invoke_base_sort!(v::AbstractVector{T}; alg, lt, by, rev, order, scratch) where {T}
    return invoke(Base.sort!, Tuple{AbstractVector{T}}, v; alg, lt, by, rev, order,
                  scratch)
end

function invoke_base_sort!(A::AbstractArray{T}; dims, alg, lt, by, rev, order,
                           scratch) where {T}
    return invoke(Base.sort!, Tuple{AbstractArray{T}}, A; dims, alg, lt, by, rev,
                  order, scratch)
end

function invoke_base_sortperm(A::AbstractArray; alg, lt, by, rev, order, scratch,
                              dims)
    if dims === nothing
        return invoke(Base.sortperm, Tuple{AbstractArray}, A; alg, lt, by, rev,
                      order, scratch)
    else
        return invoke(Base.sortperm, Tuple{AbstractArray}, A; alg, lt, by, rev,
                      order, scratch, dims)
    end
end

function invoke_base_sortperm!(index::AbstractArray{Ti}, A::AbstractArray; alg, lt,
                               by, rev, order, initialized, scratch, dims) where {Ti}
    if dims === nothing
        return invoke(Base.sortperm!, Tuple{AbstractArray{Ti}, AbstractArray},
                      index, A; alg, lt, by, rev, order, initialized, scratch)
    else
        return invoke(Base.sortperm!, Tuple{AbstractArray{Ti}, AbstractArray},
                      index, A; alg, lt, by, rev, order, initialized, scratch,
                      dims)
    end
end

function check_sort_dim(A::MtlArray, dim::Integer)
    1 <= dim <= ndims(A) || throw(ArgumentError("dimension out of range"))
    return Int(dim)
end

function check_sortperm_dim(A::MtlArray, dims)
    if dims === nothing
        A isa AbstractVector ||
            throw(ArgumentError("sortperm on a multidimensional Metal array requires dims"))
        return 1
    else
        return check_sort_dim(A, dims)
    end
end

function mps_sort!(A::MtlArray; dim::Integer, rev::Bool)
    tmp = similar(A)
    MPSGraphs.graph_sort!(tmp, A; dim, rev)
    copyto!(A, tmp)
    return A
end

function Base.sort!(v::MtlVector{T};
                    alg::Base.Sort.Algorithm=Base.Sort.defalg(v),
                    lt=isless,
                    by=identity,
                    rev::Union{Bool,Nothing}=nothing,
                    order::Base.Order.Ordering=Base.Order.Forward,
                    scratch::Union{Vector{T}, Nothing}=nothing) where {T}
    descending = mps_sort_descending(v, lt, by, rev, order)
    descending === nothing &&
        return invoke_base_sort!(v; alg, lt, by, rev, order, scratch)
    return mps_sort!(v; dim=1, rev=descending)
end

function Base.sort!(A::MtlArray{T};
                    dims::Integer,
                    alg::Base.Sort.Algorithm=Base.Sort.defalg(A),
                    lt=isless,
                    by=identity,
                    rev::Union{Bool,Nothing}=nothing,
                    order::Base.Order.Ordering=Base.Order.Forward,
                    scratch::Union{Vector{T}, Nothing}=nothing) where {T}
    dim = check_sort_dim(A, dims)
    descending = mps_sort_descending(A, lt, by, rev, order)
    descending === nothing &&
        return invoke_base_sort!(A; dims=dim, alg, lt, by, rev, order, scratch)
    return mps_sort!(A; dim, rev=descending)
end

Base.sort(v::MtlVector; kws...) = sort!(copy(v); kws...)

function Base.sort(A::MtlArray{T};
                   dims::Integer,
                   alg::Base.Sort.Algorithm=Base.Sort.defalg(A),
                   lt=isless,
                   by=identity,
                   rev::Union{Bool,Nothing}=nothing,
                   order::Base.Order.Ordering=Base.Order.Forward,
                   scratch::Union{Vector{T}, Nothing}=nothing) where {T}
    out = copy(A)
    return sort!(out; dims, alg, lt, by, rev, order, scratch)
end

function Base.sortperm(A::MtlArray;
                       alg::Base.Sort.Algorithm=Base.Sort.DEFAULT_UNSTABLE,
                       lt=isless,
                       by=identity,
                       rev::Union{Bool,Nothing}=nothing,
                       order::Base.Order.Ordering=Base.Order.Forward,
                       scratch::Union{Vector{<:Integer}, Nothing}=nothing,
                       dims=nothing)
    descending = mps_sort_descending(A, lt, by, rev, order)
    descending === nothing &&
        return invoke_base_sortperm(A; alg, lt, by, rev, order, scratch, dims)
    index = similar(A, Int)
    sortperm!(index, A; alg, lt, by, rev, order, scratch, dims)
    return index
end

function Base.sortperm!(index::MtlArray{Ti}, A::MtlArray;
                        alg::Base.Sort.Algorithm=Base.Sort.DEFAULT_UNSTABLE,
                        lt=isless,
                        by=identity,
                        rev::Union{Bool,Nothing}=nothing,
                        order::Base.Order.Ordering=Base.Order.Forward,
                        initialized::Bool=false,
                        scratch::Union{Vector{Ti}, Nothing}=nothing,
                        dims=nothing) where {Ti<:Integer}
    axes(index) == axes(A) ||
        throw(ArgumentError("index array must have the same axes as the source array"))
    dim = check_sortperm_dim(A, dims)
    descending = index.offset == 0 ? mps_sort_descending(A, lt, by, rev, order) : nothing
    if descending === nothing || !(Ti <: MPSGraphs.MPSGRAPH_SORTPERM_INDEX_TYPES)
        basedims = dims === nothing ? nothing : dim
        return invoke_base_sortperm!(index, A; alg, lt, by, rev, order,
                                     initialized, scratch, dims=basedims)
    end
    MPSGraphs.graph_sortperm!(index, A; dim, rev=descending)
    return index
end
