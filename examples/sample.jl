using MetalCore

@show devices()
dev = MtlDevice(1)


#lib = MetalCore.LibraryWithFile(d, "default.metallib")

src = """
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A shader that adds two arrays of floats.
*/

#include <metal_stdlib>
using namespace metal;
/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}
"""

bufferSize = 128
bufferA = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModeShared)
bufferB = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModeShared)
bufferC = MtlBuffer(dev, Float32, bufferSize, MetalCore.MtResourceStorageModeShared)

ptrA = convert(Ptr{Float32}, contents(bufferA))
ptrB = convert(Ptr{Float32}, contents(bufferB))
ptrC = convert(Ptr{Float32}, contents(bufferC))

vecA = unsafe_wrap(Vector{Float32}, ptrA, bufferSize)
vecB = unsafe_wrap(Vector{Float32}, ptrB, bufferSize)
vecC = unsafe_wrap(Vector{Float32}, ptrC, bufferSize)

using Random
rand!.([vecA, vecB])

## Setup
opts = MtlCompileOptions()
lib = MtlLibrary(dev, src, opts)

fun = MtlFunction(lib, "add_arrays")
pip_addfun = MtlComputePipelineState(dev, fun)
queue = MtlCommandQueue(dev)

## Compute
cmdBuffer = MtlCommandBuffer(queue)
computeEncoder = MtlComputeCommandEncoder(cmdBuffer)

## add compute
MetalCore.set!(computeEncoder, pip_addfun)
MetalCore.setbuffer!(computeEncoder, bufferA, 0, 0)
MetalCore.setbuffer!(computeEncoder, bufferB, 0, 1)
MetalCore.setbuffer!(computeEncoder, bufferC, 0, 2)

gridSize = MetalCore.MtSize(length(vecA), 1, 1)

# Calculate a threadgroup size.
threadGroupSize = min(length(vecA), pip_addfun.maxTotalThreadsPerThreadgroup)
threadGroupSize = MetalCore.MtSize(threadGroupSize, 1, 1)

# Encode the compute command.
MetalCore.dispatchThreads!(computeEncoder, gridSize, threadGroupSize)

#End the compute pass.
MetalCore.endEncoding!(computeEncoder)

# Execute
MetalCore.commit!(cmdBuffer)

MetalCore.waitUntilCompleted(cmdBuffer)

@show vecC