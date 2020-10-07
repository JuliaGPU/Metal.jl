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

typedef void (*MtCommandBufferOnCompleteFn)(void            * __restrict sender,
                                            MtCommandBuffer * __restrict cmdb);

typedef void (*MtCommandBufferOnCompleteFnNoSender)( MtCommandBuffer * __restrict cmdb);

MT_EXPORT
MtCommandBuffer*
mtNewCommandBuffer(MtCommandQueue *cmdq); 

MT_EXPORT
MtCommandBuffer*
mtNewCommandBufferWithUnretainedReferences(MtCommandQueue *cmdq); 

MT_EXPORT
void
mtCommandBufferOnComplete(MtCommandQueue * __restrict cmdb,
                          void           * __restrict sender,
                          MtCommandBufferOnCompleteFn oncomplete);

MT_EXPORT
void
mtCommandBufferOnCompleteNoSender(MtCommandQueue * __restrict cmdb,
                          MtCommandBufferOnCompleteFnNoSender oncomplete);

MT_EXPORT
void
mtCommandBufferRelease(MtCommandBuffer *cmdbuf);

MT_EXPORT
void
mtCommandBufferPresentDrawable(MtCommandBuffer *cmdb,
          MtDrawable      *drawable);

/*MT_EXPORT
MtResourceStateCommandEncoder*
mtNewResourceStateCommandEncoder(MtCommandBuffer *cmdb); IOS 13*/

// Scheduling and Executing Commands

MT_EXPORT
void
mtCommandBufferEqueue(MtCommandBuffer *cmdb);

MT_EXPORT
void
mtCommandBufferCommit(MtCommandBuffer *cmdb);

MT_EXPORT
void
mtCommandBufferAddScheduledHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler);

MT_EXPORT
void
mtCommandBufferAddCompletedHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler);

MT_EXPORT
void
mtCommandBufferWaitUntilScheduled(MtCommandBuffer *cmdb);

MT_EXPORT
void
mtCommandBufferWaitUntilCompleted(MtCommandBuffer *cmdb);

MT_EXPORT
MtCommandBufferStatus
mtCommandBufferStatus(MtCommandBuffer *cmdb);

MT_EXPORT
NsError*
mtCommandBufferError(MtCommandBuffer *cmdb);

MT_EXPORT
CfTimeInterval
mtCommandBufferKernelStartTime(MtCommandBuffer *cmdb);

MT_EXPORT
CfTimeInterval
mtCommandBufferKernelEndTime(MtCommandBuffer *cmdb);

MT_EXPORT
CfTimeInterval
mtCommandBufferGPUStartTime(MtCommandBuffer *cmdb);

MT_EXPORT
CfTimeInterval
mtCommandBufferGPUEndTime(MtCommandBuffer *cmdb);

// Events
MT_EXPORT
void
mtCommandBufferEncodeSignalEvent(MtCommandBuffer *cmdb, MtEvent *event, uint64_t val);

MT_EXPORT
void
mtCommandBufferEncodeWaitForEvent(MtCommandBuffer *cmdb,  MtEvent *event, uint64_t val);

// retained references ?
MT_EXPORT
bool
mtCommandBufferRetainedReferences(MtCommandBuffer *cmdb);

// identifying
MT_EXPORT
MtDevice*
mtCommandBufferDevice(MtCommandBuffer *cmdb);

MT_EXPORT
MtCommandQueue*
mtCommandBufferCommandQueue(MtCommandBuffer *cmdb);

MT_EXPORT
const char*
mtCommandBufferLabel(MtCommandBuffer *cmdb);

// debug
MT_EXPORT
void
mtCommandBufferPushDebugGroup(MtCommandBuffer *cmdb, char* str);

MT_EXPORT
void
mtCommandBufferPopDebugGroup(MtCommandBuffer *cmdb);

#ifdef __cplusplus
}
#endif
#endif /* cmt_commandbuff_h */
