
## FFT Descriptor Creation

"""
    MPSGraphFFTDescriptor(; inverse=false, scalingMode=MPSGraphFFTScalingModeNone)

Create an MPSGraphFFTDescriptor with the specified parameters.
"""
function MPSGraphFFTDescriptor(; inverse::Bool = false, scalingMode::MPSGraphFFTScalingMode = MPSGraphFFTScalingModeNone)
    desc = @objc [MPSGraphFFTDescriptor descriptor]::MPSGraphFFTDescriptor
    desc.inverse = inverse
    desc.scalingMode = scalingMode
    return desc
end

## MPSGraph FFT operations
function fastFourierTransformWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "fft")
    @objc [graph::id{MPSGraph} fastFourierTransformWithTensor:tensor::id{MPSGraphTensor}
                                    axes:axes::id{NSArray}
                              descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                    name:name::id{NSString}]::MPSGraphTensor
end

function realToHermiteanFFTWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "rfft")
    @objc [graph::id{MPSGraph} realToHermiteanFFTWithTensor:tensor::id{MPSGraphTensor}
                                  axes:axes::id{NSArray}
                            descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                  name:name::id{NSString}]::MPSGraphTensor
end

function HermiteanToRealFFTWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "irfft")
    @objc [graph::id{MPSGraph} HermiteanToRealFFTWithTensor:tensor::id{MPSGraphTensor}
                                  axes:axes::id{NSArray}
                            descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                  name:name::id{NSString}]::MPSGraphTensor
end
