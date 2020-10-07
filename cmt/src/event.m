#include "impl/common.h"
#include "cmt/common.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtEvent*
mtDeviceNewEvent(MtDevice *dev) {
	return [(id<MTLDevice>)dev newEvent];
}

MT_EXPORT
MtSharedEvent*
mtDeviceNewSharedEvent(MtDevice *dev) {
	return [(id<MTLDevice>)dev newSharedEvent];
}

MT_EXPORT
MtSharedEvent*
mtDeviceNewSharedEventWithHandle(MtDevice *dev, MtSharedEventHandle *handle) {
	return [(id<MTLDevice>)dev newSharedEventWithHandle: (MTLSharedEventHandle*)handle];
}

MT_EXPORT
MtFence*
mtDeviceNewFence(MtDevice *dev) {
	return [(id<MTLDevice>)dev newFence];
}

MT_EXPORT
void
mtEventRelease(MtEvent *event) {
	return [(id<MTLEvent>)event release];
}

MT_EXPORT
MtDevice*
mtEventDevice(MtEvent *event) {
	return [(id<MTLEvent>)event device];
}

MT_EXPORT
const char*
mtEventLabel(MtEvent *event) {
	return Cstring([(id<MTLEvent>)event label]);
}

// shared
MT_EXPORT
uint64_t
mtSharedEventSignaledValue(MtSharedEvent *event) {
	return [(id<MTLSharedEvent>)event signaledValue];
}

// shared
MT_EXPORT
MtSharedEventHandle*
mtSharedEventNewHandle(MtSharedEvent *event) {
	return [(id<MTLSharedEvent>)event newSharedEventHandle];
}

MT_EXPORT
void
mtSharedEventHandleRelease(MtSharedEventHandle *handle) {
	return [(MTLSharedEventHandle*)handle release];
}

MT_EXPORT
void
mtSharedEventNotifyListener(MtSharedEvent *event, MtSharedEventListener *listener, uint64_t val, MtSharedEventNotificationBlock block) {
	[(id<MTLSharedEvent>)event notifyListener: (MTLSharedEventListener*)listener
										atValue:val
										block: (MTLSharedEventNotificationBlock) block];
}
