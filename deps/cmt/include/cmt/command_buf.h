/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_commandbuff_h
#define cmt_commandbuff_h
#ifdef __cplusplus
extern "C" {
#endif

#include "common.h"
#include "types.h"
#include "enums.h"

typedef void (*MtCommandBufferOnCompletedFn)(MtCommandBuffer * __restrict cmdb,
                                             void            * __restrict data);

typedef void (*MtCommandBufferOnScheduledFn)(MtCommandBuffer * __restrict cmdb,
                                             void            * __restrict data);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferDescriptor*
mtNewCommandBufferDescriptor(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCommandBufferDescriptorRetainedReferences(MtCommandBufferDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferDescriptorRetainedReferencesSet(MtCommandBufferDescriptor *desc, bool retain);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtCommandBufferDescriptorErrorOptions(MtCommandBufferDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferDescriptorErrorOptionsSet(MtCommandBufferDescriptor *desc, NsUInteger errorOption);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBuffer(MtCommandQueue *cmdq);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBufferWithDescriptor(MtCommandQueue *cmdq, MtCommandBufferDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBufferWithUnretainedReferences(MtCommandQueue *cmdq);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferOnCompleted(MtCommandBuffer * __restrict cmdb,
                           void            * __restrict data,
                           MtCommandBufferOnCompletedFn fn);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferOnScheduled(MtCommandBuffer * __restrict cmdb,
                           void            * __restrict data,
                           MtCommandBufferOnScheduledFn fn);

MT_EXPORT
void
mtCommandBufferPresentDrawable(MtCommandBuffer *cmdb,
          MtDrawable      *drawable);

/*MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtResourceStateCommandEncoder*
mtNewResourceStateCommandEncoder(MtCommandBuffer *cmdb); IOS 13*/

// Scheduling and Executing Commands

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferEnqueue(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferCommit(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferAddScheduledHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferAddCompletedHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferWaitUntilScheduled(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferWaitUntilCompleted(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferStatus
mtCommandBufferStatus(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferErrorOption
mtCommandBufferErrorOptions(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsError*
mtCommandBufferError(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferKernelStartTime(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferKernelEndTime(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferGPUStartTime(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferGPUEndTime(MtCommandBuffer *cmdb);

// Events
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCommandBufferEncodeSignalEvent(MtCommandBuffer *cmdb, MtEvent *event, uint64_t val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCommandBufferEncodeWaitForEvent(MtCommandBuffer *cmdb,  MtEvent *event, uint64_t val);

// retained references ?
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCommandBufferRetainedReferences(MtCommandBuffer *cmdb);

// identifying
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtCommandBufferDevice(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandQueue*
mtCommandBufferCommandQueue(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtCommandBufferLabel(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferLabelSet(MtCommandBuffer *cmdb, const char* label);

// debug
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCommandBufferPushDebugGroup(MtCommandBuffer *cmdb, char* str);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCommandBufferPopDebugGroup(MtCommandBuffer *cmdb);

#ifdef __cplusplus
}
#endif
#endif /* cmt_commandbuff_h */
