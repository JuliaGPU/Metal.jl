export MTLResidencySet, MTLResidencySetDescriptor

function MTLResidencySetDescriptor()
    return @objc [MTLResidencySetDescriptor alloc]::MTLResidencySetDescriptor
end

function MTLResidencySet(device::MTLDevice, desc::MTLResidencySetDescriptor)
    err = Ref{id{NSError}}(nil)
    resset = @objc [device::id{MTLDevice} newResidencySetWithDescriptor:desc::id{MTLResidencySetDescriptor}
                                                                    error:err::Ptr{id{NSError}}]::Union{Nothing,MTLResidencySet}
    resset === nothing && throw_error(err[])
    return resset
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
