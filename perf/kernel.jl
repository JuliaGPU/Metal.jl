# using GPUArrays

group = addgroup!(SUITE, "kernel")

group["launch"] = @benchmarkable @metal identity(nothing)

# group["occupancy"] = @benchmarkable begin
#     kernel = @metal launch=false identity(nothing)
#     GPUArrays.launch_heuristic(Metal.mtlArrayBackend(), kernel.f; elements=1, elements_per_thread=1)
#     return
# end

src = Metal.rand(Float32, 512, 1000)
dest = similar(src)
function indexing_kernel(dest, src)
    i = (threadgroup_position_in_grid_2d().x-1) * threadgroups_per_grid_2d().x + thread_position_in_threadgroup_2d().x
    @inbounds dest[i] = src[i]
    return
end
group["indexing"] = @async_benchmarkable @metal threads=size(src,1) groups=size(src,2) $indexing_kernel($dest, $src)

function checked_indexing_kernel(dest, src)
    i = (threadgroup_position_in_grid_2d().x-1) * threadgroups_per_grid_2d().x + thread_position_in_threadgroup_2d().x
    dest[i] = src[i]
    return
end
group["indexing_checked"] = @async_benchmarkable @metal threads=size(src,1) groups=size(src,2) $checked_indexing_kernel($dest, $src)

## DELETE
# function rand_kernel(dest::AbstractArray{T}) where {T}
#     i = (threadgroup_position_in_grid_2d().x-1) * threadgroups_per_grid_2d().x + thread_position_in_threadgroup_2d().x
#     dest[i] = Metal.rand(T)
#     return
# end
# group["rand"] = @async_benchmarkable @metal threads=size(src,1) groups=size(src,2) $rand_kernel($dest)
