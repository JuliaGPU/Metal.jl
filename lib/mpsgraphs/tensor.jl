# Contains definitions for api from MPSGraphTensor.h, MPSGraphTensorData.h, MPSGraphOperation.h

## MPSGraphTensor.h
# @objcwrapper MPSGraphTensor <: MPSGraphObject

# Define MPSGraphOperation here to define the MPSGraphTensor properties
# @objcwrapper MPSGraphOperation <: MPSGraphObject

function Base.size(td::MPSGraphTensor)
    temp = map(td.shape) do nsnum
        NSNumber(reinterpret(id{NSNumber}, nsnum)).unsignedIntegerValue |> Int
    end
    Tuple(temp)
end

function placeholderTensor(graph::MPSGraph, shape::Union{Vector, Tuple}, args...)
    mpsshape = convert(MPSShape, reverse(shape))
    return placeholderTensor(graph, mpsshape, args...)
end
function placeholderTensor(graph::MPSGraph, shape::MPSShape, dataType::Type, name = "placeholder tensor")
    return @objc [graph::id{MPSGraph} placeholderWithShape:shape::id{MPSShape}
                                 dataType:dataType::MPSDataType
                                     name:name::id{NSString}]::MPSGraphTensor
end

## MPSGraphTensorData.h
# @objcwrapper managed = true MPSGraphTensorData <: MPSGraphObject

function Base.size(td::MPSGraphTensorData)
    temp = map(td.shape) do nsnum
        NSNumber(reinterpret(id{NSNumber}, nsnum)).unsignedIntegerValue |> Int
    end
    Tuple(temp)
end

function MPSGraphTensorData(buffer::MTLBuffer, shape::MPSShape, dataType)
    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMTLBuffer:buffer::id{MTLBuffer}
                                                                  shape:shape::id{MPSShape}
                                                                  dataType:dataType::MPSDataType]::MPSGraphTensorData
end
function MPSGraphTensorData(buffer::MTLBuffer, shape::MPSShape, dataType, rowBytes)
    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMTLBuffer:buffer::id{MTLBuffer}
                                                                  shape:shape::id{MPSShape}
                                                                  dataType:dataType::MPSDataType
                                                                  rowBytes:rowBytes::NSUInteger]::MPSGraphTensorData
end
MPSGraphTensorData(matrix::MtlArray{T}) where T = MPSGraphTensorData(matrix.data[], convert(MPSShape, reverse(size(matrix))), T)

function MPSGraphTensorData(matrix::MPSMatrixLike)
    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSMatrix:matrix::id{MPSMatrix}]::MPSGraphTensorData
end

function MPSGraphTensorData(matrix::MPSMatrixLike, rank)
    1 <= rank <= 16 || throw(ArgumentError("`rank` must be between 1 and 16 inclusive"))

    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSMatrix:matrix::id{MPSMatrix}
                                                                  rank:rank::NSUInteger]::MPSGraphTensorData
end

function MPSGraphTensorData(vector::MPSVectorLike)
    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSVector:vector::id{MPSVector}]::MPSGraphTensorData
end

function MPSGraphTensorData(vector::MPSVectorLike, rank)
    1 <= rank <= 16 || throw(ArgumentError("`rank` must be between 1 and 16 inclusive"))

    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSMatrix:vector::id{MPSVector}
                                                                  rank:rank::NSUInteger]::MPSGraphTensorData
end

function MPSGraphTensorData(ndarr::MPSNDArray)
    return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSNDArray:ndarr::id{MPSNDArray}]::MPSGraphTensorData
end
# TODO: MPSImage is not yet implemented
# function MPSGraphTensorData(imgbatch::MPSImageBatch)
#     return @objc [[MPSGraphTensorData alloc]::id{MPSGraphTensorData} initWithMPSImageBatch:imgbatch::id{MPSImageBatch}]::MPSGraphTensorData
# end

"""
    MPSNDArray(tens::MPSGraphTensorData)

Return an MPSNDArray object.

Will copy contents if the contents are not stored in an MPS ndarray.
"""
function MPS.MPSNDArray(tensor::MPSGraphTensorData)
    @objc [tensor::id{MPSGraphTensorData} mpsndarray]::MPSNDArray
end
