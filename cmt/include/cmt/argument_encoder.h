/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_argument_encoder_h
#define cmt_argument_encoder_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexFromFunction(MtFunction *function, NsUInteger bufferIndex); 

MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexReflectionFromFunction(MtFunction *function, NsUInteger bufferIndex, MtAutoreleasedArgument *reflection); 

MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer(MtArgumentEncoder *ae, NsUInteger bufferIndex); 

MT_EXPORT
MtArgumentEncoder*
mtNewArgumentEncoder(MtDevice *device, MtArgumentDescriptor **arguments, uint64_t count); 

MT_EXPORT 
NsUInteger
mtArgumentEncoderLength(MtArgumentEncoder *encoder);

MT_EXPORT
void
mtArgumentEncoderSetArgumentBufferWithOffset(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger offset);

MT_EXPORT
void
mtArgumentEncoderSetArgumentBufferWithOffsetForElement(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger startOffset, NsUInteger arrayElement);

MT_EXPORT
void
mtArgumentEncoderSetBufferOffsetAtIndex(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger offset, NsUInteger indx);

MT_EXPORT
void
mtArgumentEncoderSetBuffersOffsetsWithRange(MtArgumentEncoder *cce, MtBuffer **bufs, const NsUInteger *offsets, NsRange range);

MT_EXPORT
void
mtArgumentEncoderSetTextureAtIndex(MtArgumentEncoder *cce,  MtTexture *tex, NsUInteger indx);

MT_EXPORT
void
mtArgumentEncoderSetTexturesWithRange(MtArgumentEncoder *cce,  MtTexture **textures, NsRange range);

MT_EXPORT
void
mtArgumentEncoderSetSamplerStateAtIndex(MtArgumentEncoder *cce,  MtSamplerState *sampler, NsUInteger indx);

MT_EXPORT
void
mtArgumentEncoderSetSamplerStatesWithRange(MtArgumentEncoder *cce,  MtSamplerState **samplers, NsRange range);

/*MT_EXPORT
void
mtArgumentEncoderSetComputePipelineState(MtArgumentEncoder *cce, MtComputePipelineState *state, NsUInteger index);
IOS */

MT_EXPORT
void*
mtArgumentEncoderConstantDataAtIndex(MtArgumentEncoder *cce,  NsUInteger index);

MT_EXPORT
void
mtArgumentEncoderSetIndirectCommandBuffer(MtArgumentEncoder *cce,  MtIndirectCommandBuffer *cbuf, NsUInteger index);

MT_EXPORT
void
mtArgumentEncoderSetIndirectCommandBuffers(MtArgumentEncoder *cce,  MtIndirectCommandBuffer **cbufs, NsRange range);


MT_EXPORT
NsUInteger
mtArgumentEncoderAlignment(MtArgumentEncoder *cce);

#ifdef __cplusplus
}
#endif
#endif /* cmt_argument_encoder_h */
