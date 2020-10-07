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
MtEvent*
mtDeviceNewEvent(MtDevice *dev);

MT_EXPORT
MtSharedEvent*
mtDeviceNewSharedEvent(MtDevice *dev);

MT_EXPORT
MtSharedEvent*
mtDeviceNewSharedEventWithHandle(MtDevice *dev, MtSharedEventHandle *handle);

MT_EXPORT
MtFence*
mtDeviceNewFence(MtDevice *dev);

MT_EXPORT
void
mtEventRelease(MtEvent *event);

//
MT_EXPORT
MtDevice*
mtEventDevice(MtEvent *event);

MT_EXPORT
const char*
mtEventLabel(MtEvent *event);

// shared
MT_EXPORT
uint64_t
mtSharedEventSignaledValue(MtSharedEvent *event);

MT_EXPORT
MtSharedEventHandle*
mtSharedEventNewHandle(MtSharedEvent *event);

MT_EXPORT
void
mtSharedEventHandleRelease(MtSharedEventHandle *handle);

MT_EXPORT
void
mtSharedEventNotifyListener(MtSharedEvent *event, MtSharedEventListener *listener, uint64_t val, MtSharedEventNotificationBlock block);


#ifdef __cplusplus
}
#endif
#endif /* cmt_event_h */
