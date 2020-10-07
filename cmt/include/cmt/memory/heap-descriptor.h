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
MtHeapType 
mtHeapDescriptorType(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorTypeSet(MtHeapDescriptor *heap, MtHeapType type);

MT_EXPORT
MtStorageMode 
mtHeapDescriptorStorageMode(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorStorageModeSet(MtHeapDescriptor *heap, MtStorageMode mode);

MT_EXPORT
MtCPUCacheMode 
mtHeapDescriptorCPUCacheMode(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorCpuCacheModeSet(MtHeapDescriptor *heap, MtCPUCacheMode mode);

MT_EXPORT
MtHazardTrackingMode 
mtHeapDescriptorHazardTrackingMode(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorHazardTrackingModeSet(MtHeapDescriptor *heap, MtHazardTrackingMode mode);

MT_EXPORT
MtResourceOptions 
mtHeapDescriptorResourceOptions(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorResourceOptionsSet(MtHeapDescriptor *heap, MtResourceOptions mode);

MT_EXPORT
NsUInteger 
mtHeapDescriptorSize(MtHeapDescriptor *heap);

MT_EXPORT
void
mtHeapDescriptorSizeSet(MtHeapDescriptor *heap, NsUInteger size);

#ifdef __cplusplus
}
#endif
#endif /* cmt_heap_descriptor_h */
