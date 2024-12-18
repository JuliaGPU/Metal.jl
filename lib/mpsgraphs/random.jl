# @objcwrapper immutable=false MPSGraphRandomOpDescriptor <: MPSGraphObject

function MPSMatrixRandomOpDescriptor(distribution::MPSGraphRandomDistribution, dataType::MPSDataType)
    desc = @objc [MPSMatrixRandomOpDescriptor descriptorWithDistribution:distribution::MPSGraphRandomDistribution
                    dataType:dataType::MPSDataType]::id{MPSGraphRandomOpDescriptor}
    obj = MPSGraphRandomOpDescriptor(desc)
    return obj
end
