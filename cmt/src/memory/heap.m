#include "impl/common.h"
#include "cmt/common.h"
#include "cmt/memory/heap.h"

MT_EXPORT
MtHeap*
mtDeviceNewHeapWithDescriptor(MtDevice *dev, MtHeapDescriptor *descriptor) {
	return [(id<MTLDevice>)dev newHeapWithDescriptor:(MTLHeapDescriptor*)descriptor];
}

MT_EXPORT
void
mtHeapRelease(MtHeap *heap) {
	return [(id<MTLHeap>)heap release];
}

MT_EXPORT
MtDevice*
mtHeapDevice(MtHeap *heap) {
	return [(id<MTLHeap>)heap device];
}

MT_EXPORT
const char*
mtHeapLabel(MtHeap *heap) {
	return Cstring([(id<MTLHeap>)heap label]);
}

MT_EXPORT
MtStorageMode 
mtHeapStorageMode(MtHeap *heap) {
	return [(id<MTLHeap>)heap storageMode];
}

MT_EXPORT
MtCPUCacheMode 
mtHeapCPUCacheMode(MtHeap *heap) {
	return [(id<MTLHeap>)heap cpuCacheMode];
}

MT_EXPORT
MtHazardTrackingMode 
mtHeapHazardTrackingMode(MtHeap *heap) {
	return [(id<MTLHeap>)heap hazardTrackingMode];
}

MT_EXPORT
MtResourceOptions 
mtHeapResourceOptions(MtHeap *heap) {
	return [(id<MTLHeap>)heap resourceOptions];
}

MT_EXPORT
NsUInteger 
mtHeapSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap size];
}

MT_EXPORT
NsUInteger 
mtHeapUsedSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap usedSize];
}

MT_EXPORT
NsUInteger 
mtHeapCurrentAllocatedSize(MtHeap *heap) {
	return [(id<MTLHeap>)heap currentAllocatedSize];
}

MT_EXPORT
NsUInteger 
mtHeapMaxAvailableSizeWithAlignment(MtHeap *heap, NsUInteger alignment) {
	return [(id<MTLHeap>)heap maxAvailableSizeWithAlignment: alignment];
}

MT_EXPORT
MtPurgeableState 
mtHeapSetPurgeableState(MtHeap *heap, MtPurgeableState state) {
	return [(id<MTLHeap>)heap setPurgeableState: (MTLPurgeableState)state];
}

MT_EXPORT
MtBuffer* 
mtHeapNewBufferWithLength(MtHeap *heap, NsUInteger len, MtResourceOptions opt) {
	return [(id<MTLHeap>)heap newBufferWithLength:len
							  options:(MTLResourceOptions)opt];
}

MT_EXPORT
MtBuffer* 
mtHeapNewBufferWithLengthOffset(MtHeap *heap, NsUInteger len, MtResourceOptions opt, NsUInteger offset) {
	return [(id<MTLHeap>)heap newBufferWithLength: len
							  options: (MTLResourceOptions)opt
							  offset: offset];
}

MT_EXPORT
MtTexture* 
mtHeapNewTextureWithDescriptor(MtHeap *heap, MtTextureDescriptor *desc) {
	return [(id<MTLHeap>)heap newTextureWithDescriptor: (MTLTextureDescriptor*)desc];
}

MT_EXPORT
MtTexture* 
mtHeapNewTextureWithDescriptorOffset(MtHeap *heap, MtTextureDescriptor *desc, NsUInteger offset) {
	return [(id<MTLHeap>)heap newTextureWithDescriptor: (MTLTextureDescriptor*)desc 
							  offset: offset];
}




