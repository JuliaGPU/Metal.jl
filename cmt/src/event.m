/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/common.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtEvent*
mtDeviceNewEvent(MtDevice *dev) {
	return [(id<MTLDevice>)dev newEvent];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEvent*
mtDeviceNewSharedEvent(MtDevice *dev) {
	return [(id<MTLDevice>)dev newSharedEvent];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEvent*
mtDeviceNewSharedEventWithHandle(MtDevice *dev, MtSharedEventHandle *handle) {
	return [(id<MTLDevice>)dev newSharedEventWithHandle: (MTLSharedEventHandle*)handle];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtFence*
mtDeviceNewFence(MtDevice *dev) {
	return [(id<MTLDevice>)dev newFence];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtDevice*
mtEventDevice(MtEvent *event) {
	return [(id<MTLEvent>)event device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
const char*
mtEventLabel(MtEvent *event) {
	return Cstring([(id<MTLEvent>)event label]);
}

// shared
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
uint64_t
mtSharedEventSignaledValue(MtSharedEvent *event) {
	return [(id<MTLSharedEvent>)event signaledValue];
}

// shared
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEventHandle*
mtSharedEventNewHandle(MtSharedEvent *event) {
	return [(id<MTLSharedEvent>)event newSharedEventHandle];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtSharedEventNotifyListener(MtSharedEvent *event, MtSharedEventListener *listener, uint64_t val, MtSharedEventNotificationBlock block) {
	[(id<MTLSharedEvent>)event notifyListener: (MTLSharedEventListener*)listener
										atValue:val
										block: (MTLSharedEventNotificationBlock) block];
}
