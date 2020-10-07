#import "impl/common.h"
#import "cmt/command_enc_blit.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtBlitCommandEncoder*
mtNewBlitCommandEncoder(MtCommandBuffer *cmdb) {
    return [(id<MTLCommandBuffer>)cmdb blitCommandEncoder];
}

MT_EXPORT void
mtBlitCommandEncoderCopyFromBufferToBuffer(MtBlitCommandEncoder *bce, 
	MtBuffer *src, NsUInteger src_offset, 
	MtBuffer *dst, NsUInteger dst_offset, 
	NsUInteger size) {
	[(id<MTLBlitCommandEncoder>)bce copyFromBuffer: (id<MTLBuffer>)src
							          sourceOffset: src_offset 
							              toBuffer: (id<MTLBuffer>)dst 
							     destinationOffset: dst_offset 
							                  size: size ];
}

MT_EXPORT
void
mtBlitCommandEncoderFillBuffer(MtBlitCommandEncoder *bce, 
	MtBuffer *buf, NsRange range, uint8_t val) {
	[(id<MTLBlitCommandEncoder>)bce fillBuffer: (id<MTLBuffer>)buf 
										 range: mtNSRange(range)
										 value: val];
}

MT_EXPORT
void
mtBlitCommandEncoderGenerateMipmaps(MtBlitCommandEncoder *bce, 
	MtTexture *texture) {
	[(id<MTLBlitCommandEncoder>)bce generateMipmapsForTexture:(id<MTLTexture>)texture];
}


MT_EXPORT
void
mtBlitCommandEncoderCopyIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *src, NsRange range,
	MtIndirectCommandBuffer *dst, NsUInteger dst_index) {
	[(id<MTLBlitCommandEncoder>)bce copyIndirectCommandBuffer: (id<MTLIndirectCommandBuffer>)src
							                      sourceRange: mtNSRange(range) 
					                       		  destination:(id<MTLIndirectCommandBuffer>)dst 
					                 		 destinationIndex: dst_index ];

}

MT_EXPORT
void
mtBlitCommandEncoderOptimizeIndirectCommandBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *buffer, NsRange range) {
	[(id<MTLBlitCommandEncoder>)bce 
			optimizeIndirectCommandBuffer: (id<MTLIndirectCommandBuffer>)buffer 
                            	withRange: mtNSRange(range)];

}

MT_EXPORT
void
mtBlitCommandEncoderResetCommandsInBuffer(MtBlitCommandEncoder *bce, 
	MtIndirectCommandBuffer *buffer, NsRange range) {
		[(id<MTLBlitCommandEncoder>)bce 
			resetCommandsInBuffer: (id<MTLIndirectCommandBuffer>)buffer 
                        withRange: mtNSRange(range)];

}

MT_EXPORT
void
mtBlitCommandEncoderSynchronizeResource(MtBlitCommandEncoder *bce, 
	MtResource *resource) {
	[(id<MTLBlitCommandEncoder>)bce synchronizeResource: (id<MTLResource>)resource];
}

MT_EXPORT
void
mtBlitCommandEncoderSynchronizeTexture(MtBlitCommandEncoder *bce, 
	MtTexture *texture, NsUInteger slice, NsUInteger level){
	[(id<MTLBlitCommandEncoder>)bce synchronizeTexture: (id<MTLTexture>)texture
				slice: slice level:level];
}

MT_EXPORT
void
mtBlitCommandEncoderUpdateFence(MtBlitCommandEncoder *icb, MtFence *fence) {
	[(id<MTLBlitCommandEncoder>)icb updateFence: (id<MTLFence>)fence];
}

MT_EXPORT
void
mtBlitCommandEncoderWaitForFence(MtBlitCommandEncoder *icb, MtFence *fence) {
	[(id<MTLBlitCommandEncoder>)icb waitForFence: (id<MTLFence>)fence];
}

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForGPUAccess(MtIndirectCommandBuffer *icb,
													MtTexture *tex) {
	[(id<MTLBlitCommandEncoder>)icb optimizeContentsForGPUAccess: (id<MTLTexture>)tex];
}

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level) {
	[(id<MTLBlitCommandEncoder>)icb optimizeContentsForGPUAccess: (id<MTLTexture>)tex
		slice:slice level:level];
}

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForCPUAccess(MtIndirectCommandBuffer *icb,
													MtTexture *tex) {
	[(id<MTLBlitCommandEncoder>)icb optimizeContentsForCPUAccess: (id<MTLTexture>)tex];
}

MT_EXPORT
void
mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(MtIndirectCommandBuffer *icb,
													MtTexture *tex, NsUInteger slice, NsUInteger level) {
	[(id<MTLBlitCommandEncoder>)icb optimizeContentsForCPUAccess: (id<MTLTexture>)tex
		slice:slice level:level];
}

MT_EXPORT
void
mtBlitCommandEncoderSampleCountersInBuffer(MtIndirectCommandBuffer *icb,
											MtCounterSampleBuffer *sbuf,
											NsUInteger sampleindex,
											bool barrier){
	[(id<MTLBlitCommandEncoder>)icb sampleCountersInBuffer: (id<MTLCounterSampleBuffer>) sbuf
		atSampleIndex: sampleindex 
		withBarrier: barrier];
}


MT_EXPORT
void
mtBlitCommandEncoderResolveCounters(MtIndirectCommandBuffer *icb,
									MtCounterSampleBuffer *sbuf,
									NsRange range,
									MtBuffer *dst,
									NsUInteger dst_offset) {
	[(id<MTLBlitCommandEncoder>)icb resolveCounters: (id<MTLCounterSampleBuffer>)sbuf 
							                inRange: mtNSRange(range) 
							      destinationBuffer: (id<MTLBuffer>)dst 
							      destinationOffset: dst_offset];
}
