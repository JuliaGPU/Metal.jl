export MTLLogLevel

export MTLLogStateDescriptor

# @objcwrapper managed = true MTLLogStateDescriptor <: NSObject

function MTLLogStateDescriptor()
    return @objc [[MTLLogStateDescriptor alloc]::id{MTLLogStateDescriptor} init]::MTLLogStateDescriptor
end


export MTLLogState

# @objcwrapper MTLLogState <: NSObject

function MTLLogState(dev::MTLDevice, descriptor::MTLLogStateDescriptor)
    err = Out{NSError}()
    handle = @objc [dev::id{MTLDevice} newLogStateWithDescriptor:descriptor::id{MTLLogStateDescriptor}
        error:err::Out{NSError}]::Union{Nothing,MTLLogState}
    handle === nothing && throw_error(err)
    return handle
end
