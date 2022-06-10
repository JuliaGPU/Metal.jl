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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void*
mtBufferContents(MtBuffer* buf);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtBufferLength(MtBuffer* buf);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBufferDidModifyRange(MtBuffer* buf, NsRange ran);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtBufferAddDebugMarkerRange(MtBuffer* buf, char* string, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtBufferRemoveAllDebugMarkers(MtBuffer* buf);

// Those exist only on osx 10.15
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
MtBuffer*
mtBufferNewRemoteBufferViewForDevice(MtBuffer *buf, MtDevice *device);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
MtBuffer*
mtBufferRemoteStorageBuffer(MtBuffer *buf);

#ifdef __cplusplus
}
#endif

// end 10.15
#endif /* cmt_buffer_h */
