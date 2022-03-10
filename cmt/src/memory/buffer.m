/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void*
mtBufferContents(MtBuffer* buf) {
	return [(id<MTLBuffer>)buf contents];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtBufferLength(MtBuffer* buf) {
	return [(id<MTLBuffer>)buf length];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBufferDidModifyRange(MtBuffer* buf, NsRange ran) {
	[(id<MTLBuffer>)buf didModifyRange: mtNSRange(ran)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtBufferAddDebugMarkerRange(MtBuffer* buf, char* string, NsRange range) {
	[(id<MTLBuffer>)buf addDebugMarker: mtNSString(string) range:mtNSRange(range)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtBufferRemoveAllDebugMarkers(MtBuffer* buf) {
	[(id<MTLBuffer>)buf removeAllDebugMarkers];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
MtBuffer*
mtBufferNewRemoteBufferViewForDevice(MtBuffer *buf, MtDevice *device) {
	return [(id<MTLBuffer>)buf newRemoteBufferViewForDevice: (id<MTLDevice>)device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
MtBuffer*
mtBufferRemoteStorageBuffer(MtBuffer *buf) {
	return [(id<MTLBuffer>)buf remoteStorageBuffer];
}
