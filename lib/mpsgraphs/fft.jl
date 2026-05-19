
## FFT Descriptor Creation

"""
    MPSGraphFFTDescriptor(; inverse=false, scalingMode=MPSGraphFFTScalingModeNone)

Create an MPSGraphFFTDescriptor with the specified parameters.
"""
function MPSGraphFFTDescriptor(; inverse::Bool = false, scalingMode::MPSGraphFFTScalingMode = MPSGraphFFTScalingModeNone)
    obj = @objc [MPSGraphFFTDescriptor alloc]::id{MPSGraphFFTDescriptor}
    desc = MPSGraphFFTDescriptor(obj)
    desc.inverse = inverse
    desc.scalingMode = scalingMode
    return desc
end

## MPSGraph FFT operations
function fastFourierTransformWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "fft")
    obj = @objc [graph::id{MPSGraph} fastFourierTransformWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function realToHermiteanFFTWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "rfft")
    obj = @objc [graph::id{MPSGraph} realToHermiteanFFTWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function HermiteanToRealFFTWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, axes::NSArray, descriptor::MPSGraphFFTDescriptor, name = "irfft")
    obj = @objc [graph::id{MPSGraph} HermiteanToRealFFTWithTensor:tensor::id{MPSGraphTensor}
                                axes:axes::id{NSArray}
                                descriptor:descriptor::id{MPSGraphFFTDescriptor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
