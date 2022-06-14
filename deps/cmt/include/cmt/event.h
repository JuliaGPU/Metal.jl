/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_event_h
#define cmt_event_h
#ifdef __cplusplus
extern "C" {
#endif

#include "common.h"

#include "types_foundation.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtEvent*
mtDeviceNewEvent(MtDevice *dev);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEvent*
mtDeviceNewSharedEvent(MtDevice *dev);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEvent*
mtDeviceNewSharedEventWithHandle(MtDevice *dev, MtSharedEventHandle *handle);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtFence*
mtDeviceNewFence(MtDevice *dev);

//
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtDevice*
mtEventDevice(MtEvent *event);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
const char*
mtEventLabel(MtEvent *event);

// shared
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
uint64_t
mtSharedEventSignaledValue(MtSharedEvent *event);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtSharedEventHandle*
mtSharedEventNewHandle(MtSharedEvent *event);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtSharedEventNotifyListener(MtSharedEvent *event, MtSharedEventListener *listener, uint64_t val, MtSharedEventNotificationBlock block);


#ifdef __cplusplus
}
#endif
#endif /* cmt_event_h */
