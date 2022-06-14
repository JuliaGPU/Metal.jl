/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_command_enc_blit_h
#define cmt_command_enc_blit_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtBlitCommandEncoder*
mtNewBlitCommandEncoder(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBlitCommandEncoderCopyFromBufferToBuffer(MtBlitCommandEncoder *bce, 
                                           MtBuffer *src, NsUInteger src_offset,
                                           MtBuffer *dst, NsUInteger dst_offset,
                                           NsUInteger size);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBlitCommandEncoderFillBuffer(MtBlitCommandEncoder *bce, 
                               MtBuffer *src, NsRange range, uint8_t val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBlitCommandEncoderGenerateMipmaps(MtBlitCommandEncoder *bce, 
                                    MtTexture *texture);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderCopyIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
                                              MtIndirectCommandBuffer *src, NsRange range,
                                              MtIndirectCommandBuffer *dst, NsUInteger dst_index);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderOptimizeIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
                                                  MtIndirectCommandBuffer *buffer, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderResetCommandsInBuffer(MtBlitCommandEncoder *bce, 
                                          MtIndirectCommandBuffer *buffer, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBlitCommandEncoderSynchronizeResource(MtBlitCommandEncoder *bce, 
                                        MtResource *resource);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtBlitCommandEncoderSynchronizeTexture(MtBlitCommandEncoder *bce, 
                                       MtTexture *texture, NsUInteger slice, NsUInteger level);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtBlitCommandEncoderUpdateFence(MtIndirectCommandBuffer *icb, MtFence *fence);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtBlitCommandEncoderWaitForFence(MtIndirectCommandBuffer *icb, MtFence *fence);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderOptimizeContentsForGPUAccess(MtIndirectCommandBuffer *icb,
                                                 MtTexture *tex);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderOptimizeContentsForCPUAccess(MtIndirectCommandBuffer *icb,
                                                 MtTexture *tex);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level);

// GPU Execution data
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
void
mtBlitCommandEncoderSampleCountersInBuffer(MtIndirectCommandBuffer *icb,
											MtCounterSampleBuffer *sbuf,
											NsUInteger sampleindex,
											bool barrier);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
void
mtBlitCommandEncoderResolveCounters(MtIndirectCommandBuffer *icb,
									MtCounterSampleBuffer *sbuf,
									NsRange range,
									MtBuffer *dst,
									NsUInteger dst_offset);

#ifdef __cplusplus
}
#endif
#endif /* cmt_command_enc_blit_h */
