#
# compute pipeline descriptor
#

export MTL4ComputePipelineDescriptor, MTL4PipelineOptions

# @objcwrapper managed = true MTL4PipelineOptions <: NSObject

function MTL4PipelineOptions()
    return @objc [MTL4PipelineOptions new]::MTL4PipelineOptions
end

# @objcwrapper managed = true MTL4ComputePipelineDescriptor <: MTL4PipelineDescriptor

function MTL4ComputePipelineDescriptor()
    return @objc [MTL4ComputePipelineDescriptor new]::MTL4ComputePipelineDescriptor
end

# NOTE: Metal.jl builds its `MTLComputePipelineState`s through the Metal 3 device API (see
#       `link_pipeline`), because that is what supports the binary archives used to cache
#       compiled kernels across sessions. Metal 4 command encoders accept those pipeline
#       states unchanged, so the `MTL4Compiler` path is not needed to run kernels.
