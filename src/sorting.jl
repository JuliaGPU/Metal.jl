# sorting: MPSGraph as a fast path for what it supports, GPUArrays' implementation otherwise

const AnyGPUVector = GPUArrays.AnyGPUVector
const AnyGPUArray = GPUArrays.AnyGPUArray

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

function mpsgraph_sort_descending(A::MtlArray{T}, lt, by, rev, order) where {T}
    A.offset == 0 || return nothing
    T <: Union{MPSGraphs.MPSGRAPH_VALID_SORT_TYPES...} || return nothing
    return sort_descending(lt, by, rev, order)
end

# Whether an `alg` asks for a stable sort, as GPUArrays interprets it, or `nothing` for
# algorithms that MPSGraph cannot stand in for (AcceleratedKernels' concrete algorithms,
# and those GPUArrays rejects)
mpsgraph_requires_stable(::Nothing) = true
mpsgraph_requires_stable(alg::GPUArrays.AK.Auto) = alg.stable
mpsgraph_requires_stable(::Union{Base.Sort.MergeSortAlg, Base.Sort.InsertionSortAlg}) = true
mpsgraph_requires_stable(::Union{Base.Sort.QuickSortAlg, Base.Sort.PartialQuickSort}) = false
@static if isdefined(Base.Sort, :DefaultStable)
    mpsgraph_requires_stable(::Base.Sort.DefaultStable) = true
    mpsgraph_requires_stable(::Base.Sort.DefaultUnstable) = false
else
    mpsgraph_requires_stable(::typeof(Base.Sort.DEFAULT_STABLE)) = true
end
mpsgraph_requires_stable(alg) = nothing

function mpsgraph_sort!(A::MtlArray; dim::Integer, rev::Bool)
    tmp = similar(A)
    MPSGraphs.graph_sort!(tmp, A; dim, rev)
    copyto!(A, tmp)
    return A
end

# Sorting values with `isless`, stability can only be observed for elements that compare
# equal but differ in their bits (NaNs with different payloads), so MPSGraph's sort is used
# for every algorithm it can stand in for.
function Base.sort!(v::MtlVector; alg=nothing, lt=isless, by=identity, rev=nothing,
                    order::Base.Order.Ordering=Base.Order.Forward, scratch=nothing)
    descending = mpsgraph_sort_descending(v, lt, by, rev, order)
    if descending === nothing || mpsgraph_requires_stable(alg) === nothing
        return invoke(sort!, Tuple{AnyGPUVector}, v; alg, lt, by, rev, order, scratch)
    end
    return mpsgraph_sort!(v; dim=1, rev=descending)
end

function Base.sort!(A::MtlArray; dims::Integer, alg=nothing, lt=isless, by=identity,
                    rev=nothing, order::Base.Order.Ordering=Base.Order.Forward,
                    scratch=nothing)
    descending = mpsgraph_sort_descending(A, lt, by, rev, order)
    if descending === nothing || mpsgraph_requires_stable(alg) === nothing ||
       !(1 <= dims <= ndims(A))
        return invoke(sort!, Tuple{AnyGPUArray}, A; dims, alg, lt, by, rev, order, scratch)
    end
    return mpsgraph_sort!(A; dim=dims, rev=descending)
end

# MPSGraph's argsort is not documented to be stable, so it is only used when the algorithm
# allows an unstable result (GPUArrays' default, like Base's, is stable)
function mpsgraph_sortperm_descending(ix::MtlArray{Ti}, A::MtlArray, alg, lt, by, rev,
                                      order) where {Ti}
    ix.offset == 0 || return nothing
    Ti <: MPSGraphs.MPSGRAPH_SORTPERM_INDEX_TYPES || return nothing
    mpsgraph_requires_stable(alg) === false || return nothing
    axes(ix) == axes(A) || return nothing
    return mpsgraph_sort_descending(A, lt, by, rev, order)
end

function Base.sortperm!(ix::MtlArray{<:Integer}, v::MtlVector; alg=nothing, lt=isless,
                        by=identity, rev=nothing,
                        order::Base.Order.Ordering=Base.Order.Forward, kwargs...)
    descending = mpsgraph_sortperm_descending(ix, v, alg, lt, by, rev, order)
    if descending === nothing || haskey(kwargs, :dims)
        return invoke(sortperm!, Tuple{AnyGPUArray{<:Integer}, AnyGPUVector}, ix, v;
                      alg, lt, by, rev, order, kwargs...)
    end
    MPSGraphs.graph_sortperm!(ix, v; dim=1, rev=descending)
    return ix
end

function Base.sortperm!(ix::MtlArray{<:Integer}, A::MtlArray; dims::Integer, alg=nothing,
                        lt=isless, by=identity, rev=nothing,
                        order::Base.Order.Ordering=Base.Order.Forward, kwargs...)
    descending = mpsgraph_sortperm_descending(ix, A, alg, lt, by, rev, order)
    if descending === nothing || !(1 <= dims <= ndims(A))
        return invoke(sortperm!, Tuple{AnyGPUArray{<:Integer}, AnyGPUArray}, ix, A;
                      dims, alg, lt, by, rev, order, kwargs...)
    end
    MPSGraphs.graph_sortperm!(ix, A; dim=dims, rev=descending)
    return ix
end
