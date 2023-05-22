export MPSVectorDescriptor

@objcwrapper MPSVectorDescriptor <: NSObject

@objcproperties MPSVectorDescriptor begin
    @autoproperty length::NSUInteger setter=setLength
    @autoproperty vectors::NSUInteger
    @autoproperty dataType::MPSDataType setter=setDataType
    @autoproperty vectorBytes::NSUInteger
end


function MPSVectorDescriptor(length, dataType)
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      dataType:jl_typ_to_mps[dataType]::MPSDataType]::id{MPSVectorDescriptor}
    obj = MPSVectorDescriptor(desc)
    # XXX: who releases this object?
    return obj
end

function MPSVectorDescriptor(length, vectors, vectorBytes, dataType)
    desc = @objc [MPSVectorDescriptor vectorDescriptorWithLength:length::NSUInteger
                                      vectors:vectors::NSUInteger
                                      vectorBytes:vectorBytes::NSUInteger
                                      dataType:jl_typ_to_mps[dataType]::MPSDataType]::id{MPSVectorDescriptor}
    obj = MPSVectorDescriptor(desc)
    # XXX: who releases this object?
    return obj
end


export MPSVector

@objcwrapper immutable=false MPSVector <: NSObject

@objcproperties MPSVector begin
    @autoproperty device::id{MTLDevice}
    @autoproperty length::NSUInteger
    @autoproperty vectors::NSUInteger
    @autoproperty dataType::MPSDataType
    @autoproperty vectorBytes::NSUInteger
    @autoproperty offset::NSUInteger
    @autoproperty data::id{MtlBuffer}
end

"""
    MPSVector(arr::MtlVector)

Metal vector representation used in Performance Shaders.
"""
function MPSVector(arr::MtlVector{T}) where T
    length = length(arr)
    desc = MPSVectorDescriptor(length, sizeof(T)*length, T)
    vec = @objc [MPSVector alloc]::id{MPSVector}
    obj = MPSVector(vec)
    finalizer(release, obj)
    @objc [obj::id{MPSVector} initWithBuffer:arr.buffer::id{MTLBuffer}
                              descriptor:desc::id{MPSVectorDescriptor}]::id{MPSVector}
    return obj
end
