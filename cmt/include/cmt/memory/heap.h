/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_heap_h
#define cmt_heap_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtHeap*
mtDeviceNewHeapWithDescriptor(MtDevice *dev, MtHeapDescriptor *descriptor);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtDevice*
mtHeapDevice(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
const char*
mtHeapLabel(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtHeapType 
mtHeapType(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtStorageMode 
mtHeapStorageMode(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtCPUCacheMode 
mtHeapCPUCacheMode(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode 
mtHeapHazardTrackingMode(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions 
mtHeapResourceOptions(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapSize(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapUsedSize(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapCurrentAllocatedSize(MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger 
mtHeapMaxAvailableSizeWithAlignment(MtHeap *heap, NsUInteger alignment);

//
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtPurgeableState 
mtHeapSetPurgeableState(MtHeap *heap, MtPurgeableState state);

// Creating Resources on the Heap
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtBuffer* 
mtHeapNewBufferWithLength(MtHeap *heap, NsUInteger len, MtResourceOptions opt);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtBuffer*  
mtHeapNewBufferWithLengthOffset(MtHeap *heap, NsUInteger len, MtResourceOptions opt, NsUInteger offset);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtTexture* 
mtHeapNewTextureWithDescriptor(MtHeap *heap, MtTextureDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtTexture* 
mtHeapNewTextureWithDescriptorOffset(MtHeap *heap, MtTextureDescriptor *desc, NsUInteger offset);

#ifdef __cplusplus
}
#endif
#endif /* cmt_heap_h */
