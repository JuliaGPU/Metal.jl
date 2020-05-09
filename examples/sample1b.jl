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

vecA = unsafe_wrap(Vector{Float32}, convert(Ptr{Float32}, contents(bufferA)), bufferSize)
vecB = unsafe_wrap(Vector{Float32}, convert(Ptr{Float32}, contents(bufferB)), bufferSize)
vecC = unsafe_wrap(Vector{Float32}, convert(Ptr{Float32}, contents(bufferC)), bufferSize)

using Random
rand!.([vecA, vecB])

## Setup
opts = MtlCompileOptions()
lib = MtlLibrary(dev, src, opts)

fun = MtlFunction(lib, "add_arrays")
pip_addfun = MtlComputePipelineState(dev, fun)
queue = MetalCore.global_queue(dev) #MtlCommandQueue(dev)

##
cmd = MetalCore.commit!(queue) do cmdbuf
    @info 4
    MtlComputeCommandEncoder(cmdbuf) do enc
        MetalCore.set_function!(enc, pip_addfun)
        MetalCore.set_buffers!(enc,
                                [bufferA, bufferB, bufferC],
                                [0,0,0], 1:3)
        gridSize = MetalCore.MtSize(length(vecA), 1, 1)
        threadGroupSize = min(length(vecA), pip_addfun.maxTotalThreadsPerThreadgroup)
        threadGroupSize = MetalCore.MtSize(threadGroupSize, 1, 1)
        MetalCore.append_current_function!(enc, gridSize, threadGroupSize)
    end
end

# Execute
wait(cmd)

@show vecC
