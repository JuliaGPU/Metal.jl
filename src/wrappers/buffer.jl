#	This wraps the low level Metal Buffer in a
# 	MtlBuffer object.
# 	Probably you are more interested in memory.jl

export
	MtlBuffer, contents

const MTLBuffer = Ptr{MtBuffer}

mutable struct MtlBuffer <: MtlResource
	ptr::MTLBuffer
	bytesize::Int
	ctx::Union{MtlDevice, MtlHeap}
end

Base.convert(::Type{MTLBuffer}, lib::MtlBuffer) = lib.ptr
Base.unsafe_convert(::Type{MTLBuffer}, lib::MtlBuffer) = convert(MTLBuffer, lib.ptr)

Base.:(==)(a::MtlBuffer, b::MtlBuffer) = a.ptr == b.ptr
Base.hash(lib::MtlBuffer, h::UInt) = hash(lib.ptr, h)

function unsafe_destroy!(buf::MtlBuffer)
	if buf.ptr !== C_NULL
		mtBufferRelease(buf)
	end
end
## Constructors from device
function MtlBuffer(dev::MtlDevice, bytesize::Integer, opts::MtResourceOptions)
	ptr = mtDeviceNewBufferWithLength(dev, bytesize, opts)
	obj = MtlBuffer(ptr, bytesize, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end
MtlBuffer(dev::MtlDevice, T::Type, len::Integer, opts::MtResourceOptions) =
	MtlBuffer(dev, sizeof(T)*len, opts)

## constructors from heap
function MtlBuffer(heap::MtlHeap, bytesize::Integer, opts::MtResourceOptions)
	ptr = mtHeapNewBufferWithLength(heap, bytesize, opts)
	ptr == C_NULL && error("The heap's type must be MTLHeapTypeAutomatic.")
	obj = MtlBuffer(ptr, bytesize, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end
function MtlBuffer(heap::MtlHeap, bytesize::Integer, opts::MtResourceOptions, offset::Integer)
	ptr = mtHeapNewBufferWithLengthOffset(heap, bytesize, opts, offset)
	ptr == C_NULL && error("The heap's type must be MTLHeapTypePlacement.")
	obj = MtlBuffer(ptr, bytesize, dev, offset)
	finalizer(unsafe_destroy!, obj)
	return obj
end
MtlBuffer(heap::MtlHeap, T::Type, len::Integer, opts::MtResourceOptions) =
	MtlBuffer(heap, sizeof(T)*len, opts)
MtlBuffer(heap::MtlHeap, T::Type, len::Integer, opts::MtResourceOptions, offset::Integer) =
	MtlBuffer(heap, sizeof(T)*len, opts, offset)


Base.length(d::MtlBuffer) = mtBufferLength(d)
contents(d::MtlBuffer) = mtBufferContents(d)
DidModifyRange!(buf::MtlBuffer, range) = mtBufferDidModifyRange(buf, range)


# Views on different device
NewBuffer(buf::MtlBuffer, d::MtlDevice) =
	mtBufferNewRemoteBufferViewForDevice(buf, d);

function ParentBuffer(buf::MtlBuffer)
	orig = mtBufferRemoteStorageBuffer(buf);
	if orig == C_NULL
		return nothing
	else
		return MtlBuffer(orig)
	end
end
