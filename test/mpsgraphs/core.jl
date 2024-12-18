# # Contains definitions for api from MPSGraphCore.h, MPSGraphDevice.h

# const MPSGraphTensorDataDictionary = NSDictionary#<MPSGraphTensor *,MPSGraphTensorData *>

# ## MPSGraphCore.h
# @objcwrapper MPSGraphObject <: NSObject

# @objcwrapper MPSGraph <: MPSGraphObject

# function MPSGraph()
#     MPSGraph(@objc [MPSGraph new]::id{MPSGraph})
# end

# @objcwrapper MPSGraphType <: MPSGraphObject

# @objcwrapper MPSGraphShapedType <: MPSGraphType

# @objcproperties MPSGraphShapedType begin
#     @autoproperty shape::id{MPSShape} setter=setShape
#     @autoproperty dataType::MPSDataType setter=setDataType
# end

# function MPSGraphShapedType(shape::MPSShape, dataType)
#     tmp = @objc [MPSGraphShapedType alloc]::id{MPSGraphShapedType}
#     obj = MPSGraphShapedType(tmp)
#     finalizer(release, obj)
#     @objc [obj::id{MPSGraphShapedType} initWithShape:shape::id{MPSShape}
#                                        dataType:dataType::MPSDataType]::id{MPSGraphShapedType}

#    return obj
# end

# ## MPSGraphDevice.h
# @objcwrapper MPSGraphDevice <: MPSGraphType

# @objcproperties MPSGraphDevice begin
#     @autoproperty type::MPSGraphDeviceType
#     @autoproperty metalDevice::id{MTLDevice}
# end

# function MPSGraphDevice(device::MTLDevice)
#     obj = @objc [MPSGraphDevice deviceWithMTLDevice:device::id{MTLDevice}]::id{MPSGraphDevice}
#     MPSGraphDevice(obj)
# end
