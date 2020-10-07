#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_buf.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtCommandBuffer*
mtNewCommandBuffer(MtCommandQueue *cmdq) {
  return [(id<MTLCommandQueue>)cmdq commandBuffer];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtCommandBuffer*
mtNewCommandBufferWithUnretainedReferences(MtCommandQueue *cmdq) {
  return [(id<MTLCommandQueue>)cmdq commandBufferWithUnretainedReferences];
}

MT_EXPORT
void
mtCommandBufferRelease(MtCommandBuffer *cmdbuf) {
  [(id<MTLCommandBuffer>)cmdbuf release];
}

MT_EXPORT
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
void
mtCommandBufferPresentDrawable(MtCommandBuffer *cmdb, MtDrawable *drawable) {
  [(id<MTLCommandBuffer>)cmdb presentDrawable: drawable];
}

MT_EXPORT
void
mtCommandBufferEqueue(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb enqueue];
}

MT_EXPORT
void
mtCommandBufferCommit(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb commit];
}

MT_EXPORT
void
mtCommandBufferAddScheduledHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler) {
  [(id<MTLCommandBuffer>)cmdb addScheduledHandler:(MTLCommandBufferHandler)handler];
}

typedef void (^MtCommandBufferHandlerBlock)(id<MTLCommandBuffer>);

MT_EXPORT
void
mtCommandBufferAddCompletedHandler(MtCommandBuffer *cmdb, MtCommandBufferHandlerFun handler) {
  MTLCommandBufferHandler block = ^(id<MTLCommandBuffer> buf){
    MtCommandBuffer *_cmdb = buf;
    (*handler)(_cmdb);
  };

  [(id<MTLCommandBuffer>)cmdb addCompletedHandler:block];
}

MT_EXPORT
void
mtCommandBufferWaitUntilScheduled(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb waitUntilScheduled];
}

MT_EXPORT
void
mtCommandBufferWaitUntilCompleted(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb waitUntilCompleted];
}

MT_EXPORT
MtCommandBufferStatus
mtCommandBufferStatus(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb status];
}

MT_EXPORT
NsError*
mtCommandBufferError(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb error];
}


MT_EXPORT
CfTimeInterval
mtCommandBufferKernelStartTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb kernelStartTime];
}

MT_EXPORT
CfTimeInterval
mtCommandBufferKernelEndTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb kernelEndTime];
}

MT_EXPORT
CfTimeInterval
mtCommandBufferGPUStartTime(MtCommandBuffer *cmdb){
  return [(id<MTLCommandBuffer>)cmdb GPUStartTime];
}

MT_EXPORT
CfTimeInterval
mtCommandBufferGPUEndTime(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb GPUEndTime];
}

// Events
MT_EXPORT
void
mtCommandBufferEncodeSignalEvent(MtCommandBuffer *cmdb, MtEvent *event, uint64_t val) {
  [(id<MTLCommandBuffer>)cmdb encodeSignalEvent:(id<MTLEvent>)event value: val];
}

MT_EXPORT
void
mtCommandBufferEncodeWaitForEvent(MtCommandBuffer *cmdb,  MtEvent *event, uint64_t val) {
  [(id<MTLCommandBuffer>)cmdb encodeWaitForEvent:(id<MTLEvent>)event value: val];
}

// retained references ?
MT_EXPORT
bool
mtCommandBufferRetainedReferences(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb retainedReferences];
}

// identifying
MT_EXPORT
MtDevice*
mtCommandBufferDevice(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb device];
}

MT_EXPORT
MtCommandQueue*
mtCommandBufferCommandQueue(MtCommandBuffer *cmdb) {
  return [(id<MTLCommandBuffer>)cmdb commandQueue];
}

MT_EXPORT
const char*
mtCommandBufferLabel(MtCommandBuffer *cmdb) {
  return Cstring([(id<MTLCommandBuffer>)cmdb label]);
}

MT_EXPORT
void
mtCommandBufferPushDebugGroup(MtCommandBuffer *cmdb, char* str) {
  return [(id<MTLCommandBuffer>)cmdb pushDebugGroup: mtNSString(str)];  
}

MT_EXPORT
void
mtCommandBufferPopDebugGroup(MtCommandBuffer *cmdb) {
  [(id<MTLCommandBuffer>)cmdb popDebugGroup];
}

