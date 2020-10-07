/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_buffer_h
#define cmt_buffer_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
void
mtBufferRelease(MtBuffer* buf);

MT_EXPORT
void*
mtBufferContents(MtBuffer* buf);

MT_EXPORT
NsUInteger
mtBufferLength(MtBuffer* buf);

MT_EXPORT
void
mtBufferDidModifyRange(MtBuffer* buf, NsRange ran);

MT_EXPORT
void
mtBufferAddDebugMarkerRange(MtBuffer* buf, char* string, NsRange range);

MT_EXPORT
void
mtBufferRemoveAllDebugMarkers(MtBuffer* buf);

// Those exist only on osx 10.15
MT_EXPORT
MtBuffer*
mtBufferNewRemoteBufferViewForDevice(MtBuffer *buf, MtDevice *device);

MT_EXPORT
MtBuffer*
mtBufferRemoteStorageBuffer(MtBuffer *buf);
// end 10.15
#endif /* cmt_buffer_h */
