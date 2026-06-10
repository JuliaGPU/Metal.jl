
function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shape::MPSShape, name="broadcast")
    obj = @objc [graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
                                toShape:shape::id{MPSShape}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
function broadcastTensor(graph::MPSGraph, tensor::MPSGraphTensor, shapeTensor::MPSGraphTensor, name="broadcast")
    obj = @objc [graph::id{MPSGraph} broadcastTensor:tensor::id{MPSGraphTensor}
                                toShapeTensor:shapeTensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function castTensor(graph::MPSGraph, tensor::MPSGraphTensor, toType, name = "cast")
    obj = @objc [graph::id{MPSGraph} castTensor:tensor::id{MPSGraphTensor}
                                toType:toType::MPSDataType
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

# uses the swift name
complexConstant(graph::MPSGraph, n::Number, dataType) = complexConstant(graph::MPSGraph, reim(n)..., dataType)
function complexConstant(graph::MPSGraph, realPart::Number, imaginaryPart::Number, dataType)
    obj = @objc [graph::id{MPSGraph} constantWithRealPart:realPart::Float64
                                    imaginaryPart:imaginaryPart::Float64
                                    dataType:dataType::MPSDataType]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function constantWithScalar(graph::MPSGraph, scalar::Number, dataType)
    obj = @objc [graph::id{MPSGraph} constantWithScalar:scalar::Float64
                                dataType:dataType::MPSDataType]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function matrixMultiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "matmul")
    obj = @objc [graph::id{MPSGraph} matrixMultiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function multiplicationWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "mul")
    obj = @objc [graph::id{MPSGraph} multiplicationWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
function additionWithPrimaryTensor(graph::MPSGraph, primary::MPSGraphTensor, secondary::MPSGraphTensor, name = "add")
    obj = @objc [graph::id{MPSGraph} additionWithPrimaryTensor:primary::id{MPSGraphTensor}
                                secondaryTensor:secondary::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function transposeTensor(graph::MPSGraph, tensor::MPSGraphTensor, dimension, withDimension, name = "transpose")
    obj = @objc [graph::id{MPSGraph} transposeTensor:tensor::id{MPSGraphTensor}
                                dimension:dimension::NSUInteger
                                withDimension:withDimension::NSUInteger
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function shapeOfTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "shapeOfTensor")
    obj = @objc [graph::id{MPSGraph} shapeOfTensor:tensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function identityWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "identity")
    obj = @objc [graph::id{MPSGraph} identityWithTensor:tensor::id{MPSGraphTensor}
                                name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function conjugateWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "conjugate")
    obj = @objc [graph::id{MPSGraph} conjugateWithTensor:tensor::id{MPSGraphTensor}
                                        name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function negativeWithTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "negate")
    obj = @objc [graph::id{MPSGraph} negativeWithTensor:tensor::id{MPSGraphTensor}
                                        name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function imaginaryPartOfTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "imaginarypart")
    obj = @objc [graph::id{MPSGraph} imaginaryPartOfTensor:tensor::id{MPSGraphTensor}
                                     name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function realPartOfTensor(graph::MPSGraph, tensor::MPSGraphTensor, name = "realpart")
    obj = @objc [graph::id{MPSGraph} realPartOfTensor:tensor::id{MPSGraphTensor}
                                     name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function complexTensorWithRealTensor(graph::MPSGraph, realTensor::MPSGraphTensor, imaginaryTensor::MPSGraphTensor, name="complex")
    obj = @objc [graph::id{MPSGraph} complexTensorWithRealTensor:realTensor::id{MPSGraphTensor}
                                     imaginaryTensor:imaginaryTensor::id{MPSGraphTensor}
                                     name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end

function scaledDotProductAttentionWithQueryTensor(graph::MPSGraph, Q::MPSGraphTensor,
                                                  K::MPSGraphTensor, V::MPSGraphTensor,
                                                  scale::Real, name = "sdpa")
    obj = @objc [graph::id{MPSGraph} scaledDotProductAttentionWithQueryTensor:Q::id{MPSGraphTensor}
                                                            keyTensor:K::id{MPSGraphTensor}
                                                          valueTensor:V::id{MPSGraphTensor}
                                                                scale:scale::Cfloat
                                                                 name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
function scaledDotProductAttentionWithQueryTensor(graph::MPSGraph, Q::MPSGraphTensor,
                                                  K::MPSGraphTensor, V::MPSGraphTensor,
                                                  mask::MPSGraphTensor, scale::Real,
                                                  name = "sdpa")
    obj = @objc [graph::id{MPSGraph} scaledDotProductAttentionWithQueryTensor:Q::id{MPSGraphTensor}
                                                            keyTensor:K::id{MPSGraphTensor}
                                                          valueTensor:V::id{MPSGraphTensor}
                                                           maskTensor:mask::id{MPSGraphTensor}
                                                                scale:scale::Cfloat
                                                                 name:name::id{NSString}]::id{MPSGraphTensor}
    MPSGraphTensor(obj)
end
