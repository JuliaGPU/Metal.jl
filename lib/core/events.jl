export MtlEvent, MtlSharedEvent

abstract type MtlAbstractEvent end

const MTLEvent = Ptr{MtEvent}
const MTLSharedEvent = Ptr{MtSharedEvent}
const MTLSharedEventHandle = Ptr{MtSharedEventHandle}

mutable struct MtlEvent <: MtlAbstractEvent
	handle::MTLEvent
	device::MtlDevice
end

mutable struct MtlSharedEvent <: MtlAbstractEvent
	handle::MTLEvent
	device::MtlDevice
end

Base.convert(::Type{MTLEvent}, ev::MtlAbstractEvent) = ev.handle
Base.unsafe_convert(::Type{MTLEvent}, ev::MtlAbstractEvent) = convert(MTLEvent, ev.handle)

Base.:(==)(a::MtlAbstractEvent, b::MtlAbstractEvent) = a.handle == b.handle
Base.hash(ev::MtlAbstractEvent, h::UInt) = hash(ev.handle, h)

function unsafe_destroy!(fun::MtlAbstractEvent)
	fun.handle !== C_NULL && mtRelease(fun)
end

function MtlEvent(dev::MtlDevice)
	handle = mtDeviceNewEvent(dev)
	obj = MtlEvent(handle, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function MtlSharedEvent(dev::MtlDevice)
	handle = mtDeviceNewSharedEvent(dev)
	obj = MtlSharedEvent(handle, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

device(ev::MtlAbstractEvent) = ev.device
function label(l::MtlAbstractEvent)
	ptr = mtEventLabel(l)
	return ptr == C_NULL ? "" : unsafe_string(ptr)
end

# shared event
value(ev::MtlSharedEvent) = mtSharedEventSignaledValue(ev)

mutable struct MtlSharedEventHandle
	handle::MTLSharedEventHandle
	event::MtlSharedEvent
end
function MtlSharedEventHandle(event::MtlSharedEvent)
	handle = mtSharedEventNewHandle(event)
	obj = MtlSharedEventHandle(handle, event)
	finalizer(unsafe_destroy!, obj)
	return obj
end
function unsafe_destroy!(fun::MtlSharedEventHandle)
	fun.handle !== C_NULL && mtRelease(fun)
end
Base.convert(::Type{MTLSharedEventHandle}, lib::MtlSharedEventHandle) = lib.handle
Base.unsafe_convert(::Type{MTLSharedEventHandle}, lib::MtlSharedEventHandle) = convert(MTLSharedEventHandle, lib.handle)

Base.:(==)(a::MtlSharedEventHandle, b::MtlSharedEventHandle) = a.handle == b.handle
Base.hash(lib::MtlSharedEventHandle, h::UInt) = hash(lib.handle, h)



## FENCES
const MTLFence = Ptr{MtFence}

mutable struct MtlFence
	handle::MTLFence
	device::MtlDevice
end

Base.convert(::Type{MTLFence}, fen::MtlFence) = fen.handle
Base.unsafe_convert(::Type{MTLFence}, fen::MtlFence) = convert(MTLFence, fen.handle)

Base.:(==)(a::MtlFence, b::MtlFence) = a.handle == b.handle
Base.hash(ev::MtlFence, h::UInt) = hash(ev.handle, h)


function MtlFence(dev::MtlDevice)
	handle = mtDeviceNewFence(dev)
	obj = MtlFence(handle, dev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

device(fen::MtlFence) = fen.device
