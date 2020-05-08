export 
	MtlHeapDescriptor, MtlHeap

const MTLHeapDescriptor = Ptr{MtHeapDescriptor}

mutable struct MtlHeapDescriptor
	handle::MTLHeapDescriptor
end

function MtlHeapDescriptor()
	handle = mtNewHeapDescriptor()
	obj = MtlHeapDescriptor(handle)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(desc::MtlHeapDescriptor)
	desc.handle !== C_NULL && mtHeapDescriptorRelease(desc)
end

Base.convert(::Type{MTLHeapDescriptor}, dev::MtlHeapDescriptor) = dev.handle
Base.unsafe_convert(::Type{MTLHeapDescriptor}, d::MtlHeapDescriptor) = convert(MTLHeapDescriptor, d.handle) 

Base.:(==)(a::MtlHeapDescriptor, b::MtlHeapDescriptor) = a.handle == b.handle
Base.hash(dev::MtlHeapDescriptor, h::UInt) = hash(dev.handle, h)

Base.propertynames(::MtlHeapDescriptor) = 
	(:handle, :type, :storageMode, :cpuCacheMode, :hazardTrackingMode, :resourceOptions, :size)

function Base.getproperty(o::MtlHeapDescriptor, f::Symbol)
	if f === :handle
		return getfield(o, :handle)
	elseif f === :type 
		return mtHeapDescriptorType(o)
	elseif f === :storageMode
		return mtHeapDescriptorStorageMode(o)
	elseif f === :cpuCacheMode
		return mtHeapDescriptorCPUCacheMode(o)
	elseif f === :hazardTrackingMode
		return mtHeapDescriptorHazardTrackingMode(o)
	elseif f === :resourceOptions
		return mtHeapDescriptorResourceOptions(o)
	elseif f === :size
		return mtHeapDescriptorSize(o)
	end
end

function Base.setproperty!(o::MtlHeapDescriptor, f::Symbol, val)
	if f === :type 
		return mtHeapDescriptorTypeSet(o, val)
	elseif f === :storageMode
		return mtHeapDescriptorStorageModeSet(o, val)
	elseif f === :cpuCacheMode
		return mtHeapDescriptorCPUCacheModeSet(o, val)
	elseif f === :hazardTrackingMode
		return mtHeapDescriptorHazardTrackingModeSet(o, val)
	elseif f === :resourceOptions
		return mtHeapDescriptorResourceOptionsSet(o, val)
	elseif f === :size
		return mtHeapDescriptorSizeSet(o, val)
	end
end

function Base.show(io::IO, ::MIME"text/plain", o::MtlHeapDescriptor)
	print(io, "MtlHeapDescriptor: ")
	for f = propertynames(o)
		print(io, "\n $f : $(getproperty(o, f))")
	end
end

###
const MTLHeap = Ptr{MtHeap}

mutable struct MtlHeap
	handle::MTLHeap
	device::MtlDevice
end

Base.convert(::Type{MTLHeap}, dev::MtlHeap) = dev.handle
Base.unsafe_convert(::Type{MTLHeap}, d::MtlHeap) = convert(MTLHeap, d.handle) 

Base.:(==)(a::MtlHeap, b::MtlHeap) = a.handle == b.handle
Base.hash(dev::MtlHeap, h::UInt) = hash(dev.handle, h)

function MtlHeap(device::MtlDevice, opts::MtlHeapDescriptor)
	handle = mtDeviceNewHeapWithDescriptor(device, opts)
	obj = MtlHeap(handle, device)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(desc::MtlHeap)
	desc.handle !== C_NULL && mtHeapRelease(desc)
end


function label(l::MtlHeap)
	ptr = mtResourceLabel(l)
	return ptr == C_NULL ? "" : unsafe_string(ptr) 
end

Base.propertynames(::MtlHeap) = 
	(:handle, :device, :label, :type, :storageMode, :cpuCacheMode, :hazardTrackingMode, 
		:resourceOptions, :size, :usedSize, :currentAllocatedSize, :maxAvailableSizeWithAlignment)

function Base.getproperty(o::MtlHeap, f::Symbol)
	if f === :handle || f === :device 
		return getfield(o, f)
	elseif f === :label
		return label(o, f)
	elseif f === :type 
		return mtHeapType(o)
	elseif f === :storageMode
		return mtHeapStorageMode(o)
	elseif f === :cpuCacheMode
		return mtHeapCPUCacheMode(o)
	elseif f === :hazardTrackingMode
		return mtHeapHazardTrackingMode(o)
	elseif f === :resourceOptions
		return mtHeapResourceOptions(o)
	elseif f === :size
		return mtHeapSize(o)
	elseif f === :usedSize
		return mtHeapUsedSize(o)
	elseif f === :currentAllocatedSize
		return mtHeapCurrentAllocatedSize(o)
	elseif f === :maxAvailableSizeWithAlignment
		return maxAvailableSizeWithAlignment(o)
	end
end

function Base.show(io::IO, ::MIME"text/plain", o::MtlHeap)
	print(io, "MtlHeap: ")
	for f = propertynames(o)
		print(io, "\n $f : $(getproperty(o, f))")
	end
end



