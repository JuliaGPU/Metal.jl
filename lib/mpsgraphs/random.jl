# @objcwrapper managed = true MPSGraphRandomOpDescriptor <: MPSGraphObject

function MPSGraphRandomOpDescriptor(distribution::MPSGraphRandomDistribution, dataType)
    return @objc [MPSGraphRandomOpDescriptor descriptorWithDistribution:distribution::MPSGraphRandomDistribution
                    dataType:dataType::MPSDataType]::MPSGraphRandomOpDescriptor
end
