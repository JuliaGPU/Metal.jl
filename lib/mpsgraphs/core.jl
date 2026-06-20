# Contains definitions for api from MPSGraphCore.h, MPSGraphDevice.h

## MPSGraphCore.h
# @objcwrapper MPSGraphObject <: NSObject
# @objcwrapper MPSGraphType <: MPSGraphObject

# @objcwrapper MPSGraph <: MPSGraphObject
function MPSGraph()
    MPSGraph(@objc [MPSGraph new]::id{MPSGraph})
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
    obj = @objc [MPSGraphDevice deviceWithMTLDevice:device::id{MTLDevice}]::id{MPSGraphDevice}
    MPSGraphDevice(obj)
end

# @objcwrapper MPSGraphExecutionDescriptor <: MPSGraphObject

function MPSGraphExecutionDescriptor()
    MPSGraphExecutionDescriptor(@objc [MPSGraphExecutionDescriptor new]::id{MPSGraphExecutionDescriptor})
end

# @objcwrapper MPSGraphCompilationDescriptor <: MPSGraphObject

function MPSGraphCompilationDescriptor()
    MPSGraphCompilationDescriptor(@objc [MPSGraphCompilationDescriptor new]::id{MPSGraphCompilationDescriptor})
end
