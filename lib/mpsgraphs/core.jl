# Contains definitions for api from MPSGraphCore.h, MPSGraphDevice.h

## MPSGraphCore.h
# @objcwrapper MPSGraphObject <: NSObject
# @objcwrapper MPSGraphType <: MPSGraphObject

# @objcwrapper MPSGraph <: MPSGraphObject
function MPSGraph()
    MPSGraph(@objc [MPSGraph new]::id{MPSGraph})
end

# @objcwrapper MPSGraphShapedType <: MPSGraphType
function MPSGraphShapedType(shape::MPSShape, dataType)
    tmp = @objc [MPSGraphShapedType alloc]::id{MPSGraphShapedType}
    obj = MPSGraphShapedType(tmp)
    finalizer(release, obj)
    @objc [obj::id{MPSGraphShapedType} initWithShape:shape::id{MPSShape}
                                       dataType:dataType::MPSDataType]::id{MPSGraphShapedType}
    return obj
end

## MPSGraphDevice.h
# @objcwrapper MPSGraphDevice <: MPSGraphType

function MPSGraphDevice(device::MTLDevice)
    obj = @objc [MPSGraphDevice deviceWithMTLDevice:device::id{MTLDevice}]::id{MPSGraphDevice}
    MPSGraphDevice(obj)
end
