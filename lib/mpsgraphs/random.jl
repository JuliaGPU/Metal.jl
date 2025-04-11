# @objcwrapper immutable=false MPSGraphRandomOpDescriptor <: MPSGraphObject

function MPSGraphRandomOpDescriptor(distribution::MPSGraphRandomDistribution, dataType)
    desc = @objc [MPSGraphRandomOpDescriptor descriptorWithDistribution:distribution::MPSGraphRandomDistribution
                    dataType:dataType::MPSDataType]::id{MPSGraphRandomOpDescriptor}
    obj = MPSGraphRandomOpDescriptor(desc)
    return obj
end
