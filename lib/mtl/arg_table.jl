#
# command buffer
#

export MTL4ArgumentTable, MTL4ArgumentTableDescriptor

function MTL4ArgumentTableDescriptor()
    desc = @objc [MTL4ArgumentTableDescriptor alloc]::id{MTL4ArgumentTableDescriptor}
    obj = MTL4ArgumentTableDescriptor(desc)
    return obj
end

function MTL4ArgumentTable(device::MTLDevice, desc::MTL4ArgumentTableDescriptor)
    err = Ref{id{NSError}}(nil)
    handle = @objc [device::id{MTLDevice} newArgumentTableWithDescriptor:desc::id{MTL4ArgumentTableDescriptor}
                                                                    error:err::Ptr{id{NSError}}]::id{MTL4ArgumentTable}
    err[] == nil || throw(NSError(err[]))
    obj = MTL4ArgumentTable(handle)
    # finalizer(release, obj)
    return obj
end

# Buffer Arguments
function set_address!(argtab::MTL4ArgumentTable, address, bindingIndex)
    @objc [argtab::id{MTL4ArgumentTable} setAddress:address::NSUInteger
                                         atIndex:(bindingIndex)::NSUInteger]::Nothing
end

function set_address!(argtab::MTL4ArgumentTable, buf::MTLBuffer, bindingIndex)
    @objc [argtab::id{MTL4ArgumentTable} setAddress:contents(buf)::NSUInteger
                                         atIndex:(bindingIndex)::NSUInteger]::Nothing
end

function set_resource!(argtab::MTL4ArgumentTable, resourceID, bindingIndex)
    @objc [argtab::id{MTL4ArgumentTable} setResource:resourceID::NSUInteger
                                         atBufferIndex:bindingIndex::NSUInteger]::Nothing
end


function set_buffer!(argtab::MTL4ArgumentTable, buf::MTLBuffer, offset, index)
    @inline set_address!(argtab, contents(buf)+offset, index)
end
