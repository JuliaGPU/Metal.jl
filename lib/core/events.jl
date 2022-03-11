export MtlEvent, MtlSharedEvent, MtlSharedEventHandle

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


## properties

Base.propertynames(::MtlAbstractEvent) = (:device, :label, :signaledValue)

function Base.getproperty(ev::MtlAbstractEvent, f::Symbol)
    if f == :label
        ptr = mtEventLabel(ev)
        ptr == C_NULL ? "" : unsafe_string(ptr)
    elseif ev isa MtlSharedEvent && f == :signaledValue
        mtSharedEventSignaledValue(ev)
    else
        getfield(ev, f)
    end
end


## shared event handle

mutable struct MtlSharedEventHandle
	handle::MTLSharedEventHandle
	event::MtlSharedEvent
end

function MtlSharedEventHandle(ev::MtlSharedEvent)
	handle = mtSharedEventNewHandle(ev)
	obj = MtlSharedEventHandle(handle, ev)
	finalizer(unsafe_destroy!, obj)
	return obj
end

function unsafe_destroy!(evh::MtlSharedEventHandle)
	evh.handle !== C_NULL && mtRelease(evh)
end

Base.convert(::Type{MTLSharedEventHandle}, evh::MtlSharedEventHandle) = evh.handle
Base.unsafe_convert(::Type{MTLSharedEventHandle}, evh::MtlSharedEventHandle) = convert(MTLSharedEventHandle, evh.handle)

Base.:(==)(a::MtlSharedEventHandle, b::MtlSharedEventHandle) = a.handle == b.handle
Base.hash(evh::MtlSharedEventHandle, h::UInt) = hash(evh.handle, h)
