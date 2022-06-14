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
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtIndirectCommandBuffer*
mtNewIndirectCommandBuffer(MtDevice *device, MtIndirectCommandBufferDescriptor *desc,
                           NsUInteger maxCount, MtResourceOptions options);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtIndirectCommandBufferSize(MtIndirectCommandBuffer *icb); 

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtIndirectComputeCommand*
mtIndirectCommandBufferComputeCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                             NsUInteger index);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtIndirectRenderCommand*
mtIndirectCommandBufferRenderCommandAtIndex(MtIndirectCommandBuffer *icb, 
                                            NsUInteger index);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtIndirectCommandBufferResetWithRange(MtIndirectCommandBuffer *icb, NsRange range);

#ifdef __cplusplus
}
#endif
#endif /* cmt_indirect_comm_buff_h */
