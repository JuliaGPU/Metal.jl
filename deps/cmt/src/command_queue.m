/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/command_queue.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtCommandQueue*
mtNewCommandQueue(MtDevice *device) {
  return [(id<MTLDevice>)device newCommandQueue];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtCommandQueue*
mtNewCommandQueueWithMaxCommandBufferCount(MtDevice *device, NsUInteger count) {
  return [(id<MTLDevice>)device newCommandQueueWithMaxCommandBufferCount: count];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtCommandQueueDevice(MtCommandQueue *cmdq) {
	return [(id<MTLCommandQueue>)cmdq device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtCommandQueueLabel(MtCommandQueue *cmdq) {
	return Cstring([(id<MTLCommandQueue>)cmdq label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCommandQueueLabelSet(MtCommandQueue *cmdq, const char* label) {
	((id<MTLCommandQueue>)cmdq).label = mtNSString(label);
}
