/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/common.h"
#include "cmt/memory/heap.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtHeap*
mtDeviceNewHeapWithDescriptor(MtDevice *dev, MtHeapDescriptor *descriptor) {
	return [(id<MTLDevice>)dev newHeapWithDescriptor:(MTLHeapDescriptor*)descriptor];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtDevice*
mtHeapDevice(MtHeap *heap) {
	return [(id<MTLHeap>)heap device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
const char*
mtHeapLabel(MtHeap *heap) {
	return Cstring([(id<MTLHeap>)heap label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtStorageMode 
mtHeapStorageMode(MtHeap *heap) {
	return (MtStorageMode)[(id<MTLHeap>)heap storageMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtCPUCacheMode 
mtHeapCPUCacheMode(MtHeap *heap) {
	return (MtCPUCacheMode)[(id<MTLHeap>)heap cpuCacheMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode 
mtHeapHazardTrackingMode(MtHeap *heap) {
	return (MtHazardTrackingMode)[(id<MTLHeap>)heap hazardTrackingMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions 
mtHeapResourceOptions(MtHeap *heap) {
	return (MtResourceOptions)[(id<MTLHeap>)heap resourceOptions];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap size];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapUsedSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap usedSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger
mtHeapCurrentAllocatedSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap currentAllocatedSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger
mtHeapMaxAvailableSizeWithAlignment(MtHeap *heap, NsUInteger alignment) {
	return [(id<MTLHeap>)heap maxAvailableSizeWithAlignment: alignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtPurgeableState 
mtHeapSetPurgeableState(MtHeap *heap, MtPurgeableState state) {
	return (MtPurgeableState)[(id<MTLHeap>)heap setPurgeableState: (MTLPurgeableState)state];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtBuffer* 
mtHeapNewBufferWithLength(MtHeap *heap, NsUInteger len, MtResourceOptions opt) {
	return [(id<MTLHeap>)heap newBufferWithLength:len
							  options:(MTLResourceOptions)opt];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtBuffer* 
mtHeapNewBufferWithLengthOffset(MtHeap *heap, NsUInteger len, MtResourceOptions opt, NsUInteger offset) {
	return [(id<MTLHeap>)heap newBufferWithLength: len
							  options: (MTLResourceOptions)opt
							  offset: offset];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtTexture* 
mtHeapNewTextureWithDescriptor(MtHeap *heap, MtTextureDescriptor *desc) {
	return [(id<MTLHeap>)heap newTextureWithDescriptor: (MTLTextureDescriptor*)desc];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtTexture* 
mtHeapNewTextureWithDescriptorOffset(MtHeap *heap, MtTextureDescriptor *desc, NsUInteger offset) {
	return [(id<MTLHeap>)heap newTextureWithDescriptor: (MTLTextureDescriptor*)desc 
							  offset: offset];
}
