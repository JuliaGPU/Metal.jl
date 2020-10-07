
#ifndef cmt_command_enc_blit_h
#define cmt_command_enc_blit_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MtBlitCommandEncoder*
mtNewBlitCommandEncoder(MtCommandBuffer *cmdb);

MT_EXPORT
void
mtBlitCommandEncoderCopyFromBufferToBuffer(MtBlitCommandEncoder *bce, 
	MtBuffer *src, NsUInteger src_offset, 
	MtBuffer *dst, NsUInteger dst_offset, 
	NsUInteger size);

MT_EXPORT
void
mtBlitCommandEncoderFillBuffer(MtBlitCommandEncoder *bce, 
	MtBuffer *src, NsRange range, uint8_t val);

MT_EXPORT
void
mtBlitCommandEncoderGenerateMipmaps(MtBlitCommandEncoder *bce, 
	MtTexture *texture);

MT_EXPORT
void
mtBlitCommandEncoderCopyIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *src, NsRange range,
	MtIndirectCommandBuffer *dst, NsUInteger dst_index);

MT_EXPORT
void
mtBlitCommandEncoderOptimizeIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *buffer, NsRange range);

MT_EXPORT
void
mtBlitCommandEncoderResetCommandsInBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *buffer, NsRange range);

MT_EXPORT
void
mtBlitCommandEncoderSynchronizeResource(MtBlitCommandEncoder *bce, 
	MtResource *resource);

MT_EXPORT
void
mtBlitCommandEncoderSynchronizeTexture(MtBlitCommandEncoder *bce, 
	MtTexture *texture, NsUInteger slice, NsUInteger level);

MT_EXPORT
void
mtBlitCommandEncoderUpdateFence(MtIndirectCommandBuffer *icb, MtFence *fence);

MT_EXPORT
void
mtBlitCommandEncoderWaitForFence(MtIndirectCommandBuffer *icb, MtFence *fence);

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForGPUAccess(MtIndirectCommandBuffer *icb,
													MtTexture *tex);

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level);


MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForCPUAccess(MtIndirectCommandBuffer *icb,
													MtTexture *tex);

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level);

// GPU Execution data
MT_EXPORT
void
mtBlitCommandEncoderSampleCountersInBuffer(MtIndirectCommandBuffer *icb,
											MtCounterSampleBuffer *sbuf,
											NsUInteger sampleindex,
											bool barrier);

MT_EXPORT void
mtBlitCommandEncoderResolveCounters(MtIndirectCommandBuffer *icb,
									MtCounterSampleBuffer *sbuf,
									NsRange range,
									MtBuffer *dst,
									NsUInteger dst_offset);


#ifdef __cplusplus
}
#endif
#endif /* cmt_command_enc_blit_h */
