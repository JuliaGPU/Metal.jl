#import "impl/common.h"
#import "cmt/common.h"
#import "cmt/memory/heap-descriptor.h"


MT_EXPORT
MtHeapDescriptor*
mtNewHeapDescriptor(void);

MT_EXPORT
void
mtHeapDescriptorRelease(MtHeapDescriptor *desc) {
	return [(MTLHeapDescriptor*)desc release];
}

MT_EXPORT
MtHeapType 
mtHeapDescriptorType(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap type];
}

MT_EXPORT
void
mtHeapDescriptorTypeSet(MtHeapDescriptor *heap, MtHeapType type) {
	[(MTLHeapDescriptor*)heap setType:(MTLHeapType)type];
}

MT_EXPORT
MtStorageMode 
mtHeapDescriptorStorageMode(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap storageMode];
}

MT_EXPORT
void
mtHeapDescriptorStorageModeSet(MtHeapDescriptor *heap, MtStorageMode mode) {
	[(MTLHeapDescriptor*)heap setStorageMode: (MTLStorageMode)mode];
}

MT_EXPORT
MtCPUCacheMode 
mtHeapDescriptorCPUCacheMode(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap cpuCacheMode];
}

MT_EXPORT
void
mtHeapDescriptorCpuCacheModeSet(MtHeapDescriptor *heap, MtCPUCacheMode mode) {
	[(MTLHeapDescriptor*)heap setCpuCacheMode:(MTLCPUCacheMode)mode];
}

MT_EXPORT
MtHazardTrackingMode 
mtHeapDescriptorHazardTrackingMode(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap hazardTrackingMode];
}

MT_EXPORT
void
mtHeapDescriptorHazardTrackingModeSet(MtHeapDescriptor *heap, MtHazardTrackingMode mode) {
	[(MTLHeapDescriptor*)heap setHazardTrackingMode: (MTLHazardTrackingMode)mode];
}

MT_EXPORT
MtResourceOptions 
mtHeapDescriptorResourceOptions(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap resourceOptions];
}

MT_EXPORT
void
mtHeapDescriptorResourceOptionsSet(MtHeapDescriptor *heap, MtResourceOptions opts) {
	[(MTLHeapDescriptor*)heap setResourceOptions:(MTLResourceOptions)opts];
}

MT_EXPORT
NsUInteger 
mtHeapDescriptorSize(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap size];
}

MT_EXPORT
void
mtHeapDescriptorSizeSet(MtHeapDescriptor *heap, NsUInteger size) {
	[(MTLHeapDescriptor*)heap setSize:size];
}
