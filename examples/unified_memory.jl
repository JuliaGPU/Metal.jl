using Metal
using Test
using Random
using LinearAlgebra

# All M-series chips have a unified memory model (as of this commit).
# This means the CPU, GPU, and other hardware accelerators share the
# exact same memory pool. This is unlike most other GPU systems
# where the CPU and GPU have different physical memory that must
# be synced (usually across a PCI-E) connection.
# A unified memory system is beneficial for many workloads because
# these transfers are unnecessary and allow for a more seamless
# use of the available heterogeneous compute architecture.

# This document is meant to showcase potential use cases allowed by unified memory.

function simple_kernel(arr)
    idx = thread_position_in_grid_1d()
    arr[idx] = cos(arr[idx])
    return
end

### Unsafe wrapping a GPU array by a CPU array and altering each other's (same) data
# Note that since the GPU array allocation requires more assumptions about the
# underlying data, in a unified memory architecture, the GPU array should first
# be allocated, then wrapped by a CPU array...not the other way around.

# Create a Metal array with a storage mode of shared (both CPU and GPU get access)
arr_mtl = Metal.@sync Metal.zeros(Float32, (16, 16); storage = Metal.SharedStorage)
# Unsafe wrap the contents of the Metal array with a CPU array
arr_cpu = unsafe_wrap(Array{Float32}, arr_mtl, size(arr_mtl))

# Alter the CPU array data
arr_cpu .= pi

# These changes are reflected in the Metal array
Metal.@allowscalar @test arr_mtl[1] == Float32(pi)

# Now launch a kernel altering the Metal array
Metal.@sync @metal threads=1024 groups=1024 simple_kernel(arr_mtl)

# These changes are reflected in the wrapped CPU array
synchronize()
@test all(arr_cpu .== -1.0)


### Using CPU functions that are unavailable to the GPU in the middle of a series of kernels
# This would otherwise require a set of copies back and forth.

round.(rand!(arr_cpu)*100)
# Example 1: Calculate the determinant using CPU implementation
det(arr_cpu)
# Example 2: Singular Value Decomposition
svd(arr_cpu)


# Care must still be taken to make sure that any GPU work is finished before altering data on the CPU
# GPU kernel launches are still ASYNCHRONOUS!
# Relevant doc page: https://developer.apple.com/documentation/metal/mtlstoragemode/mtlstoragemodeshared?language=objc
# TODO: Come up with simultaneous launch of GPU and CPU work that results in undesired behavior

function long_kernel(arr, dummy)
    idx = thread_position_in_grid_1d()
    for i in 1:100000
        dummy[1] += Float32(0.3)
    end
    arr[idx] = Float32(pi)
    arr[idx] = cos(arr[idx])
    return
end

# Make larger arrays to make the kernel take non-trivial time
# Create a Metal array with a default storage mode of shared (both CPU and GPU get access)
arr_mtl = Metal.@sync Metal.zeros(Float32, 1024 * 1024; storage = Metal.SharedStorage)
# Unsafe wrap the contents of the Metal array with a CPU array
arr_cpu = unsafe_wrap(Array{Float32}, arr_mtl, size(arr_mtl))
dummy_mtl = MtlArray{Float32}(undef, 1)

rand!(arr_cpu)
# Now launch a kernel altering the Metal array
@metal threads=1024 groups=1024 long_kernel(arr_mtl, dummy_mtl)

# we need to synchronize the device as the kernel may not have finished yet
synchronize()
@test all(arr_cpu .== -1.0)
