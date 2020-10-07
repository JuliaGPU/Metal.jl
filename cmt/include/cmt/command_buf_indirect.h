/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_indirect_comm_buff_h
#define cmt_indirect_comm_buff_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MtIndirectCommandBuffer*
mtNewIndirectCommandBuffer(MtDevice *device, MtIndirectCommandBufferDescriptor *desc,
    NsUInteger maxCount, MtResourceOptions options); 

MT_EXPORT
NsUInteger
mtIndirectCommandBufferSize(MtIndirectCommandBuffer *icb); 

MT_EXPORT
MtIndirectComputeCommand*
mtIndirectCommandBufferComputeCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                                NsUInteger index); 

MT_EXPORT
MtIndirectRenderCommand*
mtIndirectCommandBufferRenderCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                                NsUInteger index); 

MT_EXPORT
void
mtIndirectCommandBufferResetWithRange(MtIndirectCommandBuffer *icb, NsRange range);

#ifdef __cplusplus
}
#endif
#endif /* cmt_indirect_comm_buff_h */
