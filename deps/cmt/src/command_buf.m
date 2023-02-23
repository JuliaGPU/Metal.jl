#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_buf.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferDescriptor*
mtNewCommandBufferDescriptor() {
  return [MTLCommandBufferDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCommandBufferDescriptorRetainedReferences(MtCommandBufferDescriptor *desc) {
  return (bool)[(MTLCommandBufferDescriptor*)desc retainedReferences];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferDescriptorRetainedReferencesSet(MtCommandBufferDescriptor *desc, bool retain) {
    [(MTLCommandBufferDescriptor*)desc setRetainedReferences: retain];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtCommandBufferDescriptorErrorOptions(MtCommandBufferDescriptor *desc) {
  return (NsUInteger)[(MTLCommandBufferDescriptor*)desc errorOptions];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferDescriptorErrorOptionsSet(MtCommandBufferDescriptor *desc, NsUInteger errorOption) {
    [(MTLCommandBufferDescriptor*)desc setErrorOptions: errorOption];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBuffer(MtCommandQueue *cmdq) {
    id<MTLCommandBuffer> commandBuffer = [(id <MTLCommandQueue>) cmdq commandBuffer];
    // Per Apple's "Basic Memory Management Rules" the above invocation does not imply ownership.
    // To be consistent the name of the function and CF_RETURNS_RETAINED, we explicitly claim
    // ownership with an explicit `retain`
    [commandBuffer retain];
    return commandBuffer;
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBuffer*
mtNewCommandBufferWithDescriptor(MtCommandQueue *cmdq, MtCommandBufferDescriptor *desc) {
  id<MTLCommandBuffer>  commandBuffer = [(id<MTLCommandQueue>)cmdq commandBufferWithDescriptor:(MtCommandBufferDescriptor *)desc];
  // Per Apple's "Basic Memory Management Rules" the above invocation does not imply ownership.
  // To be consistent the name of the function and CF_RETURNS_RETAINED, we explicitly claim
  // ownership with an explicit `retain`
  [commandBuffer retain];
  return commandBuffer;
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
mtCommandBufferOnCompleted(MtCommandBuffer * __restrict cmdb,
                           void            * __restrict data,
                           MtCommandBufferOnCompletedFn fn) {
  [(id<MTLCommandBuffer>)cmdb addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    fn(buffer, data);
  }];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferOnScheduled(MtCommandBuffer * __restrict cmdb,
                           void            * __restrict data,
                           MtCommandBufferOnScheduledFn fn) {
  [(id<MTLCommandBuffer>)cmdb addScheduledHandler:^(id<MTLCommandBuffer> buffer) {
    fn(buffer, data);
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
mtCommandBufferEnqueue(MtCommandBuffer *cmdb) {
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCommandBufferErrorOption
mtCommandBufferErrorOptions(MtCommandBuffer *cmdb) {
  return (MtCommandBufferErrorOption)[(id<MTLCommandBuffer>)cmdb errorOptions];
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandBufferLabelSet(MtCommandBuffer *cmdb, const char* label) {
	((id<MTLCommandBuffer>)cmdb).label = mtNSString(label);
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
