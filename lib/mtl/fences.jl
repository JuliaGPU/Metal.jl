export MtlFence

const MTLFence = Ptr{MtFence}

mutable struct MtlFence
	handle::MTLFence
	device::MTLDevice
end

Base.unsafe_convert(::Type{MTLFence}, fen::MtlFence) = fen.handle

Base.:(==)(a::MtlFence, b::MtlFence) = a.handle == b.handle
Base.hash(ev::MtlFence, h::UInt) = hash(ev.handle, h)

function MtlFence(dev::MTLDevice)
	handle = mtDeviceNewFence(dev)
	obj = MtlFence(handle, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(fen::MtlFence)
	mtRelease(fen.handle)
end
