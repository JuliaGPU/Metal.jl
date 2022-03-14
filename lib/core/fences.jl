export MtlFence

const MTLFence = Ptr{MtFence}

mutable struct MtlFence
	handle::MTLFence
	device::MtlDevice
end

Base.unsafe_convert(::Type{MTLFence}, fen::MtlFence) = fen.handle

Base.:(==)(a::MtlFence, b::MtlFence) = a.handle == b.handle
Base.hash(ev::MtlFence, h::UInt) = hash(ev.handle, h)

function MtlFence(dev::MtlDevice)
	handle = mtDeviceNewFence(dev)
	obj = MtlFence(handle, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(fen::MtlFence)
	fen.handle !== C_NULL && mtRelease(fen.handle)
end
