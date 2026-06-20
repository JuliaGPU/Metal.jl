export MTLLogLevel

export MTLLogStateDescriptor

# @objcwrapper managed = true MTLLogStateDescriptor <: NSObject

function MTLLogStateDescriptor()
    return @objc [[MTLLogStateDescriptor alloc]::id{MTLLogStateDescriptor} init]::MTLLogStateDescriptor
end


export MTLLogState

# @objcwrapper MTLLogState <: NSObject

function MTLLogState(dev::MTLDevice, descriptor::MTLLogStateDescriptor)
    err = Ref{id{NSError}}(nil)
    handle = @objc [dev::id{MTLDevice} newLogStateWithDescriptor:descriptor::id{MTLLogStateDescriptor}
        error:err::Ptr{id{NSError}}]::id{MTLLogState}
    err[] == nil || throw_error(err[])
    MTLLogState(handle)
end
