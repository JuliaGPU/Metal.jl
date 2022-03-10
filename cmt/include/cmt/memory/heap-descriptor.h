/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_heap_descriptor_h
#define cmt_heap_descriptor_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"


MT_EXPORT
MtHeapDescriptor*
mtNewHeapDescriptor(void);

MT_EXPORT
void
mtHeapDescriptorRelease(MtHeapDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHeapType 
mtHeapDescriptorType(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorTypeSet(MtHeapDescriptor *heap, MtHeapType type);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtStorageMode 
mtHeapDescriptorStorageMode(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorStorageModeSet(MtHeapDescriptor *heap, MtStorageMode mode);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtCPUCacheMode 
mtHeapDescriptorCPUCacheMode(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorCpuCacheModeSet(MtHeapDescriptor *heap, MtCPUCacheMode mode);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode 
mtHeapDescriptorHazardTrackingMode(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorHazardTrackingModeSet(MtHeapDescriptor *heap, MtHazardTrackingMode mode);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions 
mtHeapDescriptorResourceOptions(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtHeapDescriptorResourceOptionsSet(MtHeapDescriptor *heap, MtResourceOptions mode);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapDescriptorSize(MtHeapDescriptor *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtHeapDescriptorSizeSet(MtHeapDescriptor *heap, NsUInteger size);

#ifdef __cplusplus
}
#endif
#endif /* cmt_heap_descriptor_h */
