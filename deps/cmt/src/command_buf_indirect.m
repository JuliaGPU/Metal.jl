/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/command_buf_indirect.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtIndirectCommandBuffer*
mtNewIndirectCommandBuffer(MtDevice *device, MtIndirectCommandBufferDescriptor *desc,
    NsUInteger maxCount, MtResourceOptions options) {
    return [(id<MTLDevice>)device 
        newIndirectCommandBufferWithDescriptor: (MTLIndirectCommandBufferDescriptor *)desc 
                               maxCommandCount: maxCount 
                                       options: (MTLResourceOptions)options];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtIndirectCommandBufferSize(MtIndirectCommandBuffer *icb) {
    return [(id<MTLIndirectCommandBuffer>)icb size];
}

/* IOS Only atm
MT_EXPORT
MtIndirectComputeCommand*
mtIndirectCommandBufferComputeCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                                NsUInteger index) {
    return [(id<MTLIndirectCommandBuffer>)icb indirectComputeCommandAtIndex:index];
}*/

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtIndirectRenderCommand*
mtIndirectCommandBufferRenderCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                                NsUInteger index) {
    return [(id<MTLIndirectCommandBuffer>)icb indirectRenderCommandAtIndex:index];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtIndirectCommandBufferResetWithRange(MtIndirectCommandBuffer *icb, NsRange range) {
    return [(id<MTLIndirectCommandBuffer>)icb resetWithRange:mtNSRange(range)];
}