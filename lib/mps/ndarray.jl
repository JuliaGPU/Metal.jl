#
# ndarray descriptor
#

export MPSNDArrayDescriptor

# @objcwrapper managed = true MPSNDArrayDescriptor <: NSObject

function MPSNDArrayDescriptor(dataType::DataType, dimensionCount, dimensionSizes::Ptr)
    1 <= dimensionCount <= 16 || throw(ArgumentError("`dimensionCount` must be between 1 and 16 inclusive"))

    return @objc [MPSNDArrayDescriptor descriptorWithDataType:dataType::MPSDataType
                                               dimensionCount:dimensionCount::NSUInteger
                                               dimensionSizes:dimensionSizes::Ptr{NSUInteger}]::MPSNDArrayDescriptor
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

# @objcwrapper managed = true MPSNDArray <: NSObject

@static if Metal.is_macos(v"15")
    function userBuffer(ndarr::MPSNDArrayLike)::Union{Nothing, MTLBuffer}
        return @objc [ndarr::id{MPSNDArray} userBuffer]::Union{Nothing,MTLBuffer}
    end
end

function resourceSize(ndarr::MPSNDArrayLike)
    return @objc [ndarr::id{MPSNDArray} resourceSize]::NSUInteger
end

function descriptor(ndarr::MPSNDArrayLike)::Union{Nothing,MPSNDArrayDescriptor}
    return @objc [ndarr::id{MPSNDArray} descriptor]::Union{Nothing,MPSNDArrayDescriptor}
end

function Base.size(ndarr::MPSNDArrayLike)
    ndims = Int(ndarr.numberOfDimensions)
    Tuple([Int(lengthOfDimension(ndarr,i)) for i in 0:ndims-1])
end

# @objcwrapper managed = true MPSTemporaryNDArray <: MPSNDArray

function MPSTemporaryNDArray(cmdbuf::MTLCommandBufferLike, descriptor::MPSNDArrayDescriptor)
    return @objc [MPSTemporaryNDArray temporaryNDArrayWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                             descriptor:descriptor::id{MPSNDArrayDescriptor}]::MPSTemporaryNDArray
end

"""
    MPSNDArray([device::MTLDevice], arr::MtlArray)

Metal ndarray representation used in Performance Shaders.

May not contain more than 16 dimensions.
"""
function MPSNDArray(device::MTLDevice, desc::MPSNDArrayDescriptor)
    return @objc [[MPSNDArray alloc]::id{MPSNDArray} initWithDevice:device::id{MTLDevice}
                                               descriptor:desc::id{MPSNDArrayDescriptor}]::MPSNDArray
end

function MPSNDArray(device::MTLDevice, scalar)
    return @objc [[MPSNDArray alloc]::id{MPSNDArray} initWithDevice:device::id{MTLDevice}
                                               scalar:scalar::Float64]::MPSNDArray
end

@static if Metal.is_macos(v"15")
    function MPSNDArray(buffer::MTLBuffer, offset::UInt, descriptor::MPSNDArrayDescriptor)
        return @objc [[MPSNDArray alloc]::id{MPSNDArray} initWithBuffer:buffer::id{MTLBuffer}
                                                   offset:offset::NSUInteger
                                                   descriptor:descriptor::id{MPSNDArrayDescriptor}]::MPSNDArray
    end
else
    function MPSNDArray(_::MTLBuffer, _::UInt, _::MPSNDArrayDescriptor)
        @assert false "Creating an MPSNDArray that shares data with user-provided MTLBuffer is only supported in macOS v15+"
    end
end

function MPSNDArray(arr::MtlArray{T,N}) where {T,N}
    arrsize = size(arr)
    @assert arrsize[1] * sizeof(T) % 16 == 0 "First dimension of input MtlArray must have a byte size divisible by 16"
    desc = MPSNDArrayDescriptor(T, arrsize)
    return MPSNDArray(arr.data[], UInt(arr.offset), desc)
end

function Metal.MtlArray(ndarr::MPSNDArray; storage = Metal.DefaultStorageMode, async = false)
    arrsize = size(ndarr)
    T = convert(DataType, ndarr.dataType)
    arr = MtlArray{T,length(arrsize),storage}(undef, (arrsize)...)
    return exportToMtlArray!(arr, ndarr; async)
end

function exportToMtlArray!(arr::MtlArray{T}, ndarr::MPSNDArrayLike; async=false) where T
    dev = device(arr)

    cmdBuf = MTLCommandBuffer(global_queue(dev)) do cmdBuf
        exportDataWithCommandBuffer(ndarr, cmdBuf, arr.data[], T, arr.offset)
    end

    async || synchronize(cmdBuf)
    return arr
end

# rowStrides in Bytes
exportDataWithCommandBuffer(ndarr::MPSNDArrayLike, cmdbuf, toBuffer, destinationDataType, offset, rowStrides) =
    GC.@preserve rowStrides @objc [ndarr::MPSNDArray exportDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             toBuffer:toBuffer::id{MTLBuffer}
                             destinationDataType:destinationDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:pointer(rowStrides)::Ptr{NSInteger}]::Nothing
exportDataWithCommandBuffer(ndarr::MPSNDArrayLike, cmdbuf, toBuffer, destinationDataType, offset) =
    @objc [ndarr::MPSNDArray exportDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             toBuffer:toBuffer::id{MTLBuffer}
                             destinationDataType:destinationDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:nil::id{ObjectiveC.Object}]::Nothing

# rowStrides in Bytes
importDataWithCommandBuffer!(ndarr::MPSNDArrayLike, cmdbuf, fromBuffer, sourceDataType, offset, rowStrides) =
    GC.@preserve rowStrides @objc [ndarr::MPSNDArray importDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             fromBuffer:fromBuffer::id{MTLBuffer}
                             sourceDataType:sourceDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:pointer(rowStrides)::Ptr{NSInteger}]::Nothing
importDataWithCommandBuffer!(ndarr::MPSNDArrayLike, cmdbuf, fromBuffer, sourceDataType, offset) =
     @objc [ndarr::MPSNDArray importDataWithCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                             fromBuffer:fromBuffer::id{MTLBuffer}
                             sourceDataType:sourceDataType::MPSDataType
                             offset:offset::NSUInteger
                             rowStrides:nil::id{ObjectiveC.Object}]::Nothing

# TODO
# exportDataWithCommandBuffer(toImages, offset)
# importDataWithCommandBuffer(fromImages, offset)

# 0-indexed
lengthOfDimension(ndarr::MPSNDArrayLike, dimensionIndex) =
    @objc [ndarr::MPSNDArray lengthOfDimension:dimensionIndex::NSUInteger]::UInt

# TODO
# readBytes(strideBytes)
# writeBytes(strideBytes)

synchronizeOnCommandBuffer(ndarr::MPSNDArrayLike, q) =
    @objc [ndarr::MPSNDArray synchronizeOnCommandBuffer:q::id{MTLCommandBuffer}]::Nothing


export MPSNDArrayMultiaryBase

# @objcwrapper managed = true MPSNDArrayMultiaryBase <: MPSKernel

export MPSNDArrayMultiaryKernel

# @objcwrapper managed = true MPSNDArrayMultiaryKernel <: MPSNDArrayMultiaryBase

function MPSNDArrayMultiaryKernel(device, sourceCount)
    return @objc [[MPSNDArrayMultiaryKernel alloc]::id{MPSNDArrayMultiaryKernel} initWithDevice:device::id{MTLDevice}
                                                                           sourceCount:sourceCount::NSUInteger]::MPSNDArrayMultiaryKernel
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayMultiaryKernelLike, sourceArrays)
    @objc [kernel::id{MPSNDArrayMultiaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                          sourceArrays:sourceArrays::id{NSArray}]::MPSNDArray
end
function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayMultiaryKernelLike, sourceArrays, destinationArray)
    @objc [kernel::id{MPSNDArrayMultiaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
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

# @objcwrapper managed = true MPSNDArrayUnaryKernel <: MPSNDArrayMultiaryKernel

function MPSNDArrayUnaryKernel(device)
    return @objc [[MPSNDArrayUnaryKernel alloc]::id{MPSNDArrayUnaryKernel} initWithDevice:device::id{MTLDevice}]::MPSNDArrayUnaryKernel
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayUnaryKernelLike, sourceArray)
    @objc [kernel::id{MPSNDArrayUnaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                       sourceArray:sourceArray::id{MPSNDArray}]::MPSNDArray
end
function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayUnaryKernelLike, sourceArray, destinationArray)
    @objc [kernel::id{MPSNDArrayUnaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
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

# @objcwrapper managed = true MPSNDArrayBinaryKernel <: MPSNDArrayMultiaryKernel

function MPSNDArrayBinaryKernel(device)
    return @objc [[MPSNDArrayBinaryKernel alloc]::id{MPSNDArrayBinaryKernel} initWithDevice:device::id{MTLDevice}]::MPSNDArrayBinaryKernel
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayBinaryKernelLike, primarySourceArray, secondarySourceArray)
    @objc [kernel::id{MPSNDArrayBinaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                               secondarySourceArray:secondarySourceArray::id{MPSNDArray}
                                                 primarySourceArray:primarySourceArray::id{MPSNDArray}]::MPSNDArray
end
function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSNDArrayBinaryKernelLike, primarySourceArray, secondarySourceArray, destinationArray)
    @objc [kernel::id{MPSNDArrayBinaryKernel} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
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

# @objcwrapper managed = true MPSNDArrayMatrixMultiplication <: MPSNDArrayMultiaryKernel

function MPSNDArrayMatrixMultiplication(device, sourceCount)
    return @objc [[MPSNDArrayMatrixMultiplication alloc]::id{MPSNDArrayMatrixMultiplication} initWithDevice:device::id{MTLDevice}
                                                                                       sourceCount:sourceCount::NSUInteger]::MPSNDArrayMatrixMultiplication
end
