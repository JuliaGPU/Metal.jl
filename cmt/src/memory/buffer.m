#import "impl/common.h"


MT_EXPORT
void
mtBufferRelease(MtBuffer* buf) {
	return [(id<MTLBuffer>)buf release];
}

MT_EXPORT
void*
mtBufferContents(MtBuffer* buf) {
	return [(id<MTLBuffer>)buf contents];
}

MT_EXPORT
NsUInteger
mtBufferLength(MtBuffer* buf) {
	return [(id<MTLBuffer>)buf length];
}

MT_EXPORT
void
mtBufferDidModifyRange(MtBuffer* buf, NsRange ran) {
	[(id<MTLBuffer>)buf didModifyRange: mtNSRange(ran)];
}


MT_EXPORT
void
mtBufferAddDebugMarkerRange(MtBuffer* buf, char* string, NsRange range) {
	[(id<MTLBuffer>)buf addDebugMarker: mtNSString(string) range:mtNSRange(range)];
}

MT_EXPORT
void
mtBufferRemoveAllDebugMarkers(MtBuffer* buf) {
	[(id<MTLBuffer>)buf removeAllDebugMarkers];
}

MT_EXPORT
MtBuffer*
mtBufferNewRemoteBufferViewForDevice(MtBuffer *buf, MtDevice *device) {
	return [(id<MTLBuffer>)buf newRemoteBufferViewForDevice: (id<MTLDevice>)device];
}

MT_EXPORT
MtBuffer*
mtBufferRemoteStorageBuffer(MtBuffer *buf) {
	return [(id<MTLBuffer>)buf remoteStorageBuffer];
}


