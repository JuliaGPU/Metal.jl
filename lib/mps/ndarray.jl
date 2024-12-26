#
# ndarray descriptor
#

export MPSNDArrayDescriptor

@objcwrapper immutable=false MPSNDArrayDescriptor <: NSObject

@objcproperties MPSNDArrayDescriptor begin
    @autoproperty dataType::MPSDataType setter=setDataType
    @autoproperty numberOfDimensions::NSUInteger setter=setNumberOfDimensions

    # Both are officially available starting macOS 15, but they work in macOS 13/14
    @autoproperty preferPackedRows::Bool setter=setPreferPackedRows # macOS 15+
    @autoproperty getShape::id{NSArray} # macOS 15+
end

function MPSNDArrayDescriptor(dataType::DataType, dimensionCount, dimensionSizes::Ptr)
    desc = @objc [MPSNDArrayDescriptor descriptorWithDataType:dataType::MPSDataType
                                      dimensionCount:dimensionCount::NSUInteger
                                      dimensionSizes:dimensionSizes::Ptr{NSUInteger}]::id{MPSNDArrayDescriptor}
    obj = MPSNDArrayDescriptor(desc)
    return obj
end

function MPSNDArrayDescriptor(dataType::DataType, shape::DenseVector{T}) where {T<:Union{Int,UInt}}
    obj = GC.@preserve shape begin
        shapeptr = pointer(shape)
        MPSNDArrayDescriptor(dataType, length(shape), shapeptr)
    end
    return obj
end
MPSNDArrayDescriptor(dataType::DataType, shape::Tuple) = MPSNDArrayDescriptor(dataType, collect(shape))

MPSNDArrayDescriptor(dataType::DataType, dimensionSizes...) = @inline MPSNDArrayDescriptor(dataType, collect(dimensionSizes))

lengthOfDimension(desc::MPSNDArrayDescriptor, dim) = @objc [desc::id{MPSNDArrayDescriptor} lengthOfDimension:dim::UInt]::UInt

function transposeDimensionwithDimension(desc::MPSNDArrayDescriptor, dim1, dim2)
    @objc [desc::id{MPSNDArrayDescriptor} transposeDimension:dim1::UInt
                                          withDimension:dim2::UInt]::Cvoid
end

#
# ndarray object
#

export MPSNDArray

@objcwrapper immutable=false MPSNDArray <: NSObject

@static if Metal._safe_minversion(v"15")
    @objcproperties MPSNDArray begin
        @autoproperty dataType::MPSDataType
        @autoproperty dataTypeSize::Csize_t
        @autoproperty device::id{MTLDevice}
        @autoproperty label::id{NSString} setter=setLabel
        @autoproperty numberOfDimensions::NSUInteger
        @autoproperty parent::id{MPSNDArray}

        #Instance methods that act like properties
        @autoproperty descriptor::id{MPSNDArrayDescriptor}
        @autoproperty resourceSize::NSUInteger
        @autoproperty userBuffer::id{MTLBuffer}
    end
else
    @objcproperties MPSNDArray begin
        @autoproperty dataType::MPSDataType
        @autoproperty dataTypeSize::Csize_t
        @autoproperty device::id{MTLDevice}
        @autoproperty label::id{NSString} setter=setLabel
        @autoproperty numberOfDimensions::NSUInteger
        @autoproperty parent::id{MPSNDArray}
    end
end

function Base.size(ndarr::MPSNDArray)
    ndims = Int(ndarr.numberOfDimensions)
    Tuple([Int(lengthOfDimension(ndarr,i)) for i in 0:ndims-1])
end

@objcwrapper immutable=false MPSTemporaryNDArray <: MPSNDArray

@objcproperties MPSTemporaryNDArray begin
    @autoproperty readCount::NSUInteger setter=setReadCount
end

function MPSTemporaryNDArray(cmdbuf::MTLCommandBuffer, descriptor::MPSNDArrayDescriptor)
    @objc [MPSTemporaryNDArray temporaryNDArrayWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                 descriptor:descriptor::id{MPSNDArrayDescriptor}]::id{MPSTemporaryNDArray}
    return obj
end

"""
    MPSNDArray([device::MTLDevice], arr::MtlArray)

Metal ndarray representation used in Performance Shaders.

May not contain more than 16 dimensions.
"""
function MPSNDArray(device::MTLDevice, desc::MPSNDArrayDescriptor)
    arrayaddr = @objc [MPSNDArray alloc]::id{MPSNDArray}
    obj = MPSNDArray(arrayaddr)
    finalizer(release, obj)
    @objc [obj::MPSNDArray initWithDevice:device::id{MTLDevice}
                                 descriptor:desc::id{MPSNDArrayDescriptor}]::id{MPSNDArray}
    return obj
end

function MPSNDArray(device::MTLDevice, scalar)
    arrayaddr = @objc [MPSNDArray alloc]::id{MPSNDArray}
    obj = MPSNDArray(arrayaddr)
    finalizer(release, obj)
    @objc [obj::MPSNDArray initWithDevice:device::id{MTLDevice}
                                 scalar:scalar::Float64]::id{MPSNDArray}
    return obj
end

@static if Metal._safe_minversion(v"15")
    function MPSNDArray(buffer::MTLBuffer, offset::UInt, descriptor::MPSNDArrayDescriptor)
        arrayaddr = @objc [MPSNDArray alloc]::id{MPSNDArray}
        obj = MPSNDArray(arrayaddr)
        finalizer(release, obj)
        @objc [obj::MPSNDArray initWithBuffer:buffer::id{MTLBuffer}
                                offset:offset::NSUInteger
                                descriptor:descriptor::id{MPSNDArrayDescriptor}]::id{MPSNDArray}
        return obj
    end
else
    function MPSNDArray(_::MTLBuffer, _::UInt, _::MPSNDArrayDescriptor)
        @assert false "Creating an MPSNDArray that shares data with user-provided MTLBuffer is only supported in macOS v15+"
    end
end

function MPSNDArray(arr::MtlArray{T,N}) where {T,N}
    arrsize = size(arr)
    @assert arrsize[1]*sizeof(T) % 16 == 0 "First dimension of arr must have a byte size divisible by 16"
    desc = MPSNDArrayDescriptor(T, arrsize)
    return MPSNDArray(arr.data[], UInt(arr.offset), desc)
end

function Metal.MtlArray(ndarr::MPSNDArray; storage = Metal.DefaultStorageMode, async = false)
    arrsize = size(ndarr)
    T = convert(DataType, ndarr.dataType)
    arr = MtlArray{T,length(arrsize),storage}(undef, (arrsize)...)
    return exportToMtlArray!(arr, ndarr; async)
end

function exportToMtlArray!(arr::MtlArray{T}, ndarr::MPSNDArray; async=false) where T
    dev = device(arr)

    cmdBuf = MTLCommandBuffer(global_queue(dev)) do cmdBuf
        exportDataWithCommandBuffer(ndarr, cmdBuf, arr.data[], T, arr.offset)
    end

    async || wait_completed(cmdBuf)
    return arr
end

# rowStrides in Bytes
exportDataWithCommandBuffer(ndarr::MPSNDArray, cmdbuf::MTLCommandBuffer, toBuffer, destinationDataType, offset, rowStrides) =
    GC.@preserve rowStrides @objc [ndarr::MPSNDArray exportDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             toBuffer:toBuffer::id{MTLBuffer}
                             destinationDataType:destinationDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:pointer(rowStrides)::Ptr{NSInteger}]::Nothing
exportDataWithCommandBuffer(ndarr::MPSNDArray, cmdbuf::MTLCommandBuffer, toBuffer, destinationDataType, offset) =
    @objc [ndarr::MPSNDArray exportDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             toBuffer:toBuffer::id{MTLBuffer}
                             destinationDataType:destinationDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:nil::id{ObjectiveC.Object}]::Nothing

# rowStrides in Bytes
importDataWithCommandBuffer!(ndarr::MPSNDArray, cmdbuf::MTLCommandBuffer, fromBuffer, sourceDataType, offset, rowStrides) =
    GC.@preserve rowStrides @objc [ndarr::MPSNDArray importDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             fromBuffer:fromBuffer::id{MTLBuffer}
                             sourceDataType:sourceDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:pointer(rowStrides)::Ptr{NSInteger}]::Nothing
importDataWithCommandBuffer!(ndarr::MPSNDArray, cmdbuf::MTLCommandBuffer, fromBuffer, sourceDataType, offset) =
     @objc [ndarr::MPSNDArray importDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             fromBuffer:fromBuffer::id{MTLBuffer}
                             sourceDataType:sourceDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:nil::id{ObjectiveC.Object}]::Nothing

# TODO
# exportDataWithCommandBuffer(toImages, offset)
# importDataWithCommandBuffer(fromImages, offset)

# 0-indexed
lengthOfDimension(ndarr::MPSNDArray, dimensionIndex) =
    @objc [ndarr::MPSNDArray lengthOfDimension:dimensionIndex::NSUInteger]::UInt

# TODO
# readBytes(strideBytes)
# writeBytes(strideBytes)

synchronizeOnCommandBuffer(ndarr::MPSNDArray, q::MTLCommandBuffer) =
    @objc [ndarr::MPSNDArray synchronizeOnCommandBuffer:q::id{MTLCommandBuffer}]::Nothing


export MPSNDArrayMultiaryBase

@objcwrapper immutable=false MPSNDArrayMultiaryBase <: MPSKernel

export MPSNDArrayMultiaryKernel

@objcwrapper immutable=false MPSNDArrayMultiaryKernel <: MPSNDArrayMultiaryBase

function MPSNDArrayMultiaryKernel(device, sourceCount)
    kernel = @objc [MPSNDArrayMultiaryKernel alloc]::id{MPSNDArrayMultiaryKernel}
    obj = MPSNDArrayMultiaryKernel(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSNDArrayMultiaryKernel} initWithDevice:device::id{MTLDevice}
                                  sourceCount:sourceCount::NSUInteger]::id{MPSNDArrayMultiaryKernel}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArrays) where {K<:MPSNDArrayMultiaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     sourceArrays:sourceArrays::id{NSArray}]::id{MPSNDArray}
end
function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArrays, destinationArray) where {K<:MPSNDArrayMultiaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     sourceArrays:sourceArrays::id{NSArray}
                                     destinationArray:destinationArray::id{MPSNDArray}]::Nothing
end
# TODO: MPSState is not implemented yet, so these don't work
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArrays, resultState, destinationArray) where {K<:MPSNDArrayMultiaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      sourceArrays:sourceArrays::id{NSArray}
#                                      resultState:resultState::id{MPSState}
#                                      destinationArray:destinationArray::id{MPSNDArray}]::Nothing
# end
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArrays, resultState, outputStateIsTemporary::Bool) where {K<:MPSNDArrayMultiaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      sourceArrays:sourceArrays::id{NSArray}
#                                      resultState:resultState::id{MPSState}
#                                      outputStateIsTemporary:outputStateIsTemporary::Bool]::MPSNDArray
# end

export MPSNDArrayUnaryKernel

@objcwrapper immutable=false MPSNDArrayUnaryKernel <: MPSNDArrayMultiaryBase

function MPSNDArrayUnaryKernel(device)
    kernel = @objc [MPSNDArrayUnaryKernel alloc]::id{MPSNDArrayUnaryKernel}
    obj = MPSNDArrayUnaryKernel(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSNDArrayUnaryKernel} initWithDevice:device::id{MTLDevice}]::id{MPSNDArrayUnaryKernel}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArray) where {K<:MPSNDArrayUnaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     sourceArray:sourceArray::id{MPSNDArray}]::id{MPSNDArray}
end
function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArray, destinationArray) where {K<:MPSNDArrayUnaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     sourceArray:sourceArray::id{MPSNDArray}
                                     destinationArray:destinationArray::id{MPSNDArray}]::Nothing
end
# TODO: MPSState is not implemented yet, so these don't work
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArray, resultState, destinationArray) where {K<:MPSNDArrayUnaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      sourceArray:sourceArray::id{MPSNDArray}
#                                      resultState:resultState::id{MPSState}
#                                      destinationArray:destinationArray::id{MPSNDArray}]::Nothing
# end
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, sourceArray, resultState, outputStateIsTemporary::Bool) where {K<:MPSNDArrayUnaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      sourceArray:sourceArrays::id{MPSNDArray}
#                                      resultState:resultState::id{MPSState}
#                                      outputStateIsTemporary:outputStateIsTemporary::Bool]::MPSNDArray
# end

export MPSNDArrayBinaryKernel

@objcwrapper immutable=false MPSNDArrayBinaryKernel <: MPSNDArrayMultiaryBase

function MPSNDArrayBinaryKernel(device)
    kernel = @objc [MPSNDArrayBinaryKernel alloc]::id{MPSNDArrayBinaryKernel}
    obj = MPSNDArrayBinaryKernel(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSNDArrayBinaryKernel} initWithDevice:device::id{MTLDevice}]::id{MPSNDArrayBinaryKernel}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::K, primarySourceArray, secondarySourceArray) where {K<:MPSNDArrayBinaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     secondarySourceArray:secondarySourceArray::id{MPSNDArray}
                                     primarySourceArray:primarySourceArray::id{MPSNDArray}]::id{MPSNDArray}
end
function encode!(cmdbuf::MTLCommandBuffer, kernel::K, primarySourceArray, secondarySourceArray, destinationArray) where {K<:MPSNDArrayBinaryKernel}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     primarySourceArray:primarySourceArray::id{MPSNDArray}
                                     secondarySourceArray:secondarySourceArray::id{MPSNDArray}
                                     destinationArray:destinationArray::id{MPSNDArray}]::Nothing
end
# TODO: MPSState is not implemented yet, so these don't work
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, primarySourceArray, secondarySourceArray, resultState, destinationArray) where {K<:MPSNDArrayBinaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      primarySourceArray:primarySourceArray::id{MPSNDArray}
#                                      secondarySourceArray:secondarySourceArray::id{MPSNDArray}
#                                      resultState:resultState::id{MPSState}
#                                      destinationArray:destinationArray::id{MPSNDArray}]::Nothing
# end
# function encode!(cmdbuf::MTLCommandBuffer, kernel::K, primarySourceArray, secondarySourceArray, resultState, outputStateIsTemporary::Bool) where {K<:MPSNDArrayBinaryKernel}
#     @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
#                                      primarySourceArray:primarySourceArrays::id{MPSNDArray}
#                                      secondarySourceArray:secondarySourceArray::id{MPSNDArray}
#                                      resultState:resultState::id{MPSState}
#                                      outputStateIsTemporary:outputStateIsTemporary::Bool]::MPSNDArray
# end

@objcwrapper immutable=false MPSNDArrayMatrixMultiplication <: MPSNDArrayMultiaryKernel

@objcproperties MPSNDArrayMatrixMultiplication begin
    @autoproperty alpha::Float64 setter=setAlpha
    @autoproperty beta::Float64  setter=setBeta
end

function MPSNDArrayMatrixMultiplication(device, sourceCount)
    kernel = @objc [MPSNDArrayMatrixMultiplication alloc]::id{MPSNDArrayMatrixMultiplication}
    obj = MPSNDArrayMatrixMultiplication(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSNDArrayMatrixMultiplication} initWithDevice:device::id{MTLDevice}
                    sourceCount:sourceCount::NSUInteger]::id{MPSNDArrayMatrixMultiplication}
    return obj
end
