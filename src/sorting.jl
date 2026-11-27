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

# whether MPSGraph can sort `A` along `dims` (`nothing` for a vector), and in which direction
function mpsgraph_sort_descending(A::MtlArray, dims, lt, by, rev, order)
    # the output is a fresh array like `A`, so `A` stands in for it (overlap isn't checked)
    MPSGraphs.supports(MPSGraphs.sort!, A, A; dims) || return nothing
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

function mpsgraph_sort!(A::MtlArray; dims::Integer, rev::Bool)
    tmp = similar(A)
    MPSGraphs.sort!(tmp, A; dims, rev)
    copyto!(A, tmp)
    return A
end

# Sorting values with `isless`, stability can only be observed for elements that compare
# equal but differ in their bits (NaNs with different payloads), so MPSGraph's sort is used
# for every algorithm it can stand in for.
function Base.sort!(v::MtlVector; alg=nothing, lt=isless, by=identity, rev=nothing,
                    order::Base.Order.Ordering=Base.Order.Forward, scratch=nothing)
    descending = mpsgraph_sort_descending(v, nothing, lt, by, rev, order)
    if descending === nothing || mpsgraph_requires_stable(alg) === nothing
        return invoke(sort!, Tuple{AnyGPUVector}, v; alg, lt, by, rev, order, scratch)
    end
    return mpsgraph_sort!(v; dims=1, rev=descending)
end

function Base.sort!(A::MtlArray; dims::Integer, alg=nothing, lt=isless, by=identity,
                    rev=nothing, order::Base.Order.Ordering=Base.Order.Forward,
                    scratch=nothing)
    descending = mpsgraph_sort_descending(A, dims, lt, by, rev, order)
    if descending === nothing || mpsgraph_requires_stable(alg) === nothing
        return invoke(sort!, Tuple{AnyGPUArray}, A; dims, alg, lt, by, rev, order, scratch)
    end
    return mpsgraph_sort!(A; dims, rev=descending)
end

# MPSGraph's argsort is not documented to be stable, so it is only used when the algorithm
# allows an unstable result (GPUArrays' default, like Base's, is stable)
function mpsgraph_sortperm_descending(ix::MtlArray, A::MtlArray, dims, alg, lt, by, rev,
                                      order)
    mpsgraph_requires_stable(alg) === false || return nothing
    MPSGraphs.supports(MPSGraphs.sortperm!, ix, A; dims) || return nothing
    return sort_descending(lt, by, rev, order)
end

function Base.sortperm!(ix::MtlArray{<:Integer}, v::MtlVector; alg=nothing, lt=isless,
                        by=identity, rev=nothing,
                        order::Base.Order.Ordering=Base.Order.Forward, kwargs...)
    descending = mpsgraph_sortperm_descending(ix, v, nothing, alg, lt, by, rev, order)
    if descending === nothing || haskey(kwargs, :dims)
        return invoke(sortperm!, Tuple{AnyGPUArray{<:Integer}, AnyGPUVector}, ix, v;
                      alg, lt, by, rev, order, kwargs...)
    end
    MPSGraphs.sortperm!(ix, v; dims=1, rev=descending)
    return ix
end

function Base.sortperm!(ix::MtlArray{<:Integer}, A::MtlArray; dims::Integer, alg=nothing,
                        lt=isless, by=identity, rev=nothing,
                        order::Base.Order.Ordering=Base.Order.Forward, kwargs...)
    descending = mpsgraph_sortperm_descending(ix, A, dims, alg, lt, by, rev, order)
    if descending === nothing
        return invoke(sortperm!, Tuple{AnyGPUArray{<:Integer}, AnyGPUArray}, ix, A;
                      dims, alg, lt, by, rev, order, kwargs...)
    end
    MPSGraphs.sortperm!(ix, A; dims, rev=descending)
    return ix
end
