export MTLResidencySet, MTLResidencySetDescriptor

function MTLResidencySetDescriptor()
    desc = @objc [MTLResidencySetDescriptor alloc]::id{MTLResidencySetDescriptor}
    obj = MTLResidencySetDescriptor(desc)
    return obj
end

function MTLResidencySet(device::MTLDevice, desc::MTLResidencySetDescriptor)
    err = Ref{id{NSError}}(nil)
    handle = @objc [device::id{MTLDevice} newResidencySetWithDescriptor:desc::id{MTLResidencySetDescriptor}
                                                                    error:err::Ptr{id{NSError}}]::id{MTLResidencySet}
    err[] == nil || throw(NSError(err[]))
    obj = MTLResidencySet(handle)
    finalizer(release, obj)
    return obj
end

# Buffer Arguments
function add_allocation!(resset::MTLResidencySet, allocation)
    @objc [resset::id{MTLResidencySet} addAllocation:allocation::id{MTLAllocation}]::Nothing
end
function add_allocations!(resset::MTLResidencySet, allocations, count=length(allocations))
    @objc [resset::id{MTLResidencySet} addAllocations:allocations::Ptr{id{MTLAllocation}}
                                         count:count::NSUInteger]::Nothing
end

function remove_all_allocations!(resset::MTLResidencySet)
    @objc [resset::id{MTLResidencySet} removeAllAllocations]::Nothing
end
function remove_allocation!(resset::MTLResidencySet, allocation)
    @objc [resset::id{MTLResidencySet} removeAllocation:allocation::id{MTLAllocation}]::Nothing
end
function remove_allocations!(resset::MTLResidencySet, allocations, count=length(allocations))
    @objc [resset::id{MTLResidencySet} removeAllocations:allocations::Ptr{id{MTLAllocation}}
                                         count:count::NSUInteger]::Nothing
end

function commit!(resset::MTLResidencySet)
    @objc [resset::id{MTLResidencySet} commit]::Nothing
end
function request_residency!(resset::MTLResidencySet)
    @objc [resset::id{MTLResidencySet} requestResidency]::Nothing
end
function end_residency!(resset::MTLResidencySet)
    @objc [resset::id{MTLResidencySet} endResidency]::Nothing
end
function contains_allocation(resset::MTLResidencySet, allocation)
    @objc [resset::id{MTLResidencySet} containsAllocation:allocation::id{MTLAllocation}]::Bool
end
