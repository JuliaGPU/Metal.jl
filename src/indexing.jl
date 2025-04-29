# indexing

using Base.Cartesian


## logical indexing

# we cannot use Base.LogicalIndex, which does not support indexing but requires iteration.
# TODO: it should still be possible to use the same technique;
#       Base.LogicalIndex basically contains the same as our `findall` here does.

Base.to_index(::MtlArray, I::AbstractArray{Bool}) = findall(I)
if VERSION >= v"1.11.0-DEV.1157"
    Base.to_indices(A::MtlArray, I::Tuple{AbstractArray{Bool}}) = (Base.to_index(A, I[1]),)
else
    Base.to_indices(A::MtlArray, inds,
                    I::Tuple{Union{Array{Bool,N}, BitArray{N}}}) where {N} =
        (Base.to_index(A, I[1]),)
end


## find*

function Base.findall(bools::WrappedMtlArray{Bool})
    I = keytype(bools)
    indices = cumsum(reshape(bools, prod(size(bools))))

    n = @allowscalar indices[end]
    ys = similar(bools, I, n)

    if n > 0
        function kernel(ys::MtlDeviceArray, bools, indices)
            i = (threadgroup_position_in_grid_1d() - Int32(1)) * threads_per_threadgroup_1d() + thread_position_in_threadgroup_1d()

            @inbounds if i <= length(bools) && bools[i]
                i′ = CartesianIndices(bools)[i]
                b = indices[i]   # new position
                ys[b] = i′
            end

            return
        end

        kernel = @metal name="findall" launch=false kernel(ys, bools, indices)
        threads = Int(kernel.pipeline.maxTotalThreadsPerThreadgroup)
        groups = cld(length(indices), threads)
        kernel(ys, bools, indices; groups, threads)
    end

    unsafe_free!(indices)

    return ys
end

@inline function _findall(f, A)
    bools = map(f, A)
    ys = findall(bools)
    unsafe_free!(bools)
    return ys
end

Base.findall(f::Function, A::WrappedMtlArray) = _findall(f, A)
Base.findall(f::Base.Fix2{typeof(in)}, A::WrappedMtlArray) = _findall(f, A)
