# Contains definitions for api from MPSGraphCore.h, MPSGraphDevice.h

## MPSGraphCore.h
# @objcwrapper MPSGraphObject <: NSObject
# @objcwrapper MPSGraphType <: MPSGraphObject

# @objcwrapper MPSGraph <: MPSGraphObject
function MPSGraph()
    @objc [MPSGraph new]::MPSGraph
end

# @objcwrapper MPSGraphShapedType <: MPSGraphType

MPSGraphShapedType(shape, dataType) = MPSGraphShapedType(convert(MPSShape, shape), dataType)
function MPSGraphShapedType(shape::MPSShape, dataType)
    return @objc [[MPSGraphShapedType alloc]::id{MPSGraphShapedType} initWithShape:shape::id{MPSShape}
                                                               dataType:dataType::MPSDataType]::MPSGraphShapedType
end

## MPSGraphDevice.h
# @objcwrapper MPSGraphDevice <: MPSGraphType

function MPSGraphDevice(device::MTLDevice)
    @objc [MPSGraphDevice deviceWithMTLDevice:device::id{MTLDevice}]::MPSGraphDevice
end

# @objcwrapper MPSGraphExecutionDescriptor <: MPSGraphObject

function MPSGraphExecutionDescriptor()
    @objc [MPSGraphExecutionDescriptor new]::MPSGraphExecutionDescriptor
end

# @objcwrapper MPSGraphCompilationDescriptor <: MPSGraphObject

function MPSGraphCompilationDescriptor()
    @objc [MPSGraphCompilationDescriptor new]::MPSGraphCompilationDescriptor
end
