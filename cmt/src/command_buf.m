#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_buf.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBuffer(MtCommandQueue *cmdq) {
  return [(id<MTLCommandQueue>)cmdq commandBuffer];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBufferWithUnretainedReferences(MtCommandQueue *cmdq) {
  return [(id<MTLCommandQueue>)cmdq commandBufferWithUnretainedReferences];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferOnComplete(MtCommandQueue * __restrict cmdb,
                          void           * __restrict sender,
                          MtCommandBufferOnCompleteFn oncomplete) {
  [(id<MTLCommandBuffer>)cmdb addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    oncomplete(sender, buffer);
  }];
}

MT_EXPORT
void
mtCommandBufferOnCompleteNoSender(MtCommandQueue * __restrict cmdb,
                          MtCommandBufferOnCompleteFnNoSender oncomplete) {
  [(id<MTLCommandBuffer>)cmdb addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    oncomplete(buffer);
  }];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferPresentDrawable(MtCommandBuffer *cmdb, MtDrawable *drawable) {
  [(id<MTLCommandBuffer>)cmdb presentDrawable: drawable];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferEqueue(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb enqueue];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferCommit(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb commit];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferAddScheduledHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler) {
  [(id<MTLCommandBuffer>)cmdb addScheduledHandler:(MTLCommandBufferHandler)handler];
}

typedef void (^MtCommandBufferHandlerBlock)(id<MTLCommandBuffer>);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferAddCompletedHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler) {
  MTLCommandBufferHandler block = ^(id<MTLCommandBuffer> buf){
    MtCommandBuffer *_cmdb = buf;
    (*handler)(_cmdb);
  };

  [(id<MTLCommandBuffer>)cmdb addCompletedHandler:block];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferWaitUntilScheduled(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb waitUntilScheduled];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferWaitUntilCompleted(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb waitUntilCompleted];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferStatus
mtCommandBufferStatus(MtCommandBuffer *cmdb) {
  return (MtCommandBufferStatus)[(id<MTLCommandBuffer>)cmdb status];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsError*
mtCommandBufferError(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb error];
}


MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferKernelStartTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb kernelStartTime];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferKernelEndTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb kernelEndTime];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferGPUStartTime(MtCommandBuffer *cmdb){
  return [(id<MTLCommandBuffer>)cmdb GPUStartTime];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
CfTimeInterval
mtCommandBufferGPUEndTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb GPUEndTime];
}

// Events
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCommandBufferEncodeSignalEvent(MtCommandBuffer *cmdb, MtEvent *event, uint64_t val) {
  [(id<MTLCommandBuffer>)cmdb encodeSignalEvent:(id<MTLEvent>)event value: val];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCommandBufferEncodeWaitForEvent(MtCommandBuffer *cmdb,  MtEvent *event, uint64_t val) {
  [(id<MTLCommandBuffer>)cmdb encodeWaitForEvent:(id<MTLEvent>)event value: val];
}

// retained references ?
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCommandBufferRetainedReferences(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb retainedReferences];
}

// identifying
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtCommandBufferDevice(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandQueue*
mtCommandBufferCommandQueue(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb commandQueue];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtCommandBufferLabel(MtCommandBuffer *cmdb) {
  return Cstring([(id<MTLCommandBuffer>)cmdb label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCommandBufferPushDebugGroup(MtCommandBuffer *cmdb, char* str) {
  return [(id<MTLCommandBuffer>)cmdb pushDebugGroup: mtNSString(str)];  
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCommandBufferPopDebugGroup(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb popDebugGroup];
}
