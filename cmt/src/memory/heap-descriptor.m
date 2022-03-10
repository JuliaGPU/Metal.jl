/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/common.h"
#import "cmt/memory/heap-descriptor.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtHeapDescriptor*
mtNewHeapDescriptor(void) {
	return [MTLHeapDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHeapType 
mtHeapDescriptorType(MtHeapDescriptor *heap) {
	return (MtHeapType)[(MTLHeapDescriptor*)heap type];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorTypeSet(MtHeapDescriptor *heap, MtHeapType type) {
	[(MTLHeapDescriptor*)heap setType:(MTLHeapType)type];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtStorageMode 
mtHeapDescriptorStorageMode(MtHeapDescriptor *heap) {
	return (MtStorageMode)[(MTLHeapDescriptor*)heap storageMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorStorageModeSet(MtHeapDescriptor *heap, MtStorageMode mode) {
	[(MTLHeapDescriptor*)heap setStorageMode: (MTLStorageMode)mode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtCPUCacheMode 
mtHeapDescriptorCPUCacheMode(MtHeapDescriptor *heap) {
	return (MtCPUCacheMode)[(MTLHeapDescriptor*)heap cpuCacheMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorCpuCacheModeSet(MtHeapDescriptor *heap, MtCPUCacheMode mode) {
	[(MTLHeapDescriptor*)heap setCpuCacheMode:(MTLCPUCacheMode)mode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode 
mtHeapDescriptorHazardTrackingMode(MtHeapDescriptor *heap) {
	return (MtHazardTrackingMode)[(MTLHeapDescriptor*)heap hazardTrackingMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorHazardTrackingModeSet(MtHeapDescriptor *heap, MtHazardTrackingMode mode) {
	[(MTLHeapDescriptor*)heap setHazardTrackingMode: (MTLHazardTrackingMode)mode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions 
mtHeapDescriptorResourceOptions(MtHeapDescriptor *heap) {
	return (MtResourceOptions)[(MTLHeapDescriptor*)heap resourceOptions];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorResourceOptionsSet(MtHeapDescriptor *heap, MtResourceOptions opts) {
	[(MTLHeapDescriptor*)heap setResourceOptions:(MTLResourceOptions)opts];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapDescriptorSize(MtHeapDescriptor *heap) {
	return [(MTLHeapDescriptor*)heap size];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorSizeSet(MtHeapDescriptor *heap, NsUInteger size) {
	[(MTLHeapDescriptor*)heap setSize:size];
}
