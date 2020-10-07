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
MtHeap*
mtDeviceNewHeapWithDescriptor(MtDevice *dev, MtHeapDescriptor *descriptor);

MT_EXPORT
void
mtHeapRelease(MtHeap *heap);

MT_EXPORT
MtDevice*
mtHeapDevice(MtHeap *heap);

MT_EXPORT
const char*
mtHeapLabel(MtHeap *heap);

MT_EXPORT
MtHeapType 
mtHeapType(MtHeap *heap);

MT_EXPORT
MtStorageMode 
mtHeapStorageMode(MtHeap *heap);

MT_EXPORT
MtCPUCacheMode 
mtHeapCPUCacheMode(MtHeap *heap);

MT_EXPORT
MtHazardTrackingMode 
mtHeapHazardTrackingMode(MtHeap *heap);

MT_EXPORT
MtResourceOptions 
mtHeapResourceOptions(MtHeap *heap);

MT_EXPORT
NsUInteger 
mtHeapSize(MtHeap *heap);

MT_EXPORT
NsUInteger 
mtHeapUsedSize(MtHeap *heap);

MT_EXPORT
NsUInteger 
mtHeapCurrentAllocatedSize(MtHeap *heap);

MT_EXPORT
NsUInteger 
mtHeapMaxAvailableSizeWithAlignment(MtHeap *heap, NsUInteger alignment);

//
MT_EXPORT
MtPurgeableState 
mtHeapSetPurgeableState(MtHeap *heap, MtPurgeableState state);

// Creating Resources on the Heap
MT_EXPORT
MtBuffer* 
mtHeapNewBufferWithLength(MtHeap *heap, NsUInteger len, MtResourceOptions opt);

MT_EXPORT
MtBuffer*  
mtHeapNewBufferWithLengthOffset(MtHeap *heap, NsUInteger len, MtResourceOptions opt, NsUInteger offset);

MT_EXPORT
MtTexture* 
mtHeapNewTextureWithDescriptor(MtHeap *heap, MtTextureDescriptor *desc);

MT_EXPORT
MtTexture* 
mtHeapNewTextureWithDescriptorOffset(MtHeap *heap, MtTextureDescriptor *desc, NsUInteger offset);

#ifdef __cplusplus
}
#endif
#endif /* cmt_heap_h */
