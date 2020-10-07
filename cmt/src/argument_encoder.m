#include "cmt/argument_encoder.h"
#include "impl/common.h"

CF_RETURNS_RETAINED
MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexFromFunction(MtFunction *function, NsUInteger bufferIndex) {
	return [(id<MTLFunction>)function newArgumentEncoderWithBufferIndex: bufferIndex];	
} 

// TODO : the reflection info is an autoreleased pointer that will be populated with
// info on reflection information. Should probably look at retaining it.
CF_RETURNS_RETAINED
MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexReflectionFromFunction(MtFunction *function, NsUInteger bufferIndex, MtAutoreleasedArgument *reflection) {
	return [(id<MTLFunction>)function newArgumentEncoderWithBufferIndex: bufferIndex
														reflection: (MTLAutoreleasedArgument *)reflection];	
} 

CF_RETURNS_RETAINED
MT_EXPORT 
MtArgumentEncoder*
mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer(MtArgumentEncoder *ae, NsUInteger idx) {
	return [(id<MTLArgumentEncoder>)ae newArgumentEncoderForBufferAtIndex: idx];
}

MT_EXPORT
MtArgumentEncoder*
mtNewArgumentEncoder(MtDevice *device, MtArgumentDescriptor **arguments, uint64_t count) {
    NSMutableArray<MTLArgumentDescriptor*>  *array = [[NSMutableArray<MTLArgumentDescriptor*> alloc] initWithCapacity: count];
    for (uint64_t i=0; i < count; i++) {
        [array addObject: (MTLArgumentDescriptor*)arguments[i]];
    }
    return [(id<MTLDevice>)device newArgumentEncoderWithArguments:array];
}

MT_EXPORT 
NsUInteger
mtArgumentEncoderLength(MtArgumentEncoder *encoder) {
	return [(id<MTLArgumentEncoder>)encoder encodedLength];
}

MT_EXPORT
void
mtArgumentEncoderSetArgumentBufferWithOffset(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger offset) {
    [(id<MTLArgumentEncoder>)cce setArgumentBuffer: (id<MTLBuffer>)buf
                                            offset: offset];
}

MT_EXPORT
void
mtArgumentEncoderSetArgumentBufferWithOffsetForElement(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger startOffset, NsUInteger arrayElement) {
    [(id<MTLArgumentEncoder>)cce setArgumentBuffer: (id<MTLBuffer>)buf
                                       startOffset: startOffset
                                      arrayElement: arrayElement];
}

MT_EXPORT
void
mtArgumentEncoderSetBufferOffsetAtIndex(MtArgumentEncoder *cce, MtBuffer *buf, NsUInteger offset, NsUInteger indx) {
    [(id<MTLArgumentEncoder>)cce setBuffer: (id<MTLBuffer>)buf
                                    offset: offset
                                   atIndex: indx];
}

MT_EXPORT
void
mtArgumentSetBuffersOffsetsWithRange(MtArgumentEncoder *cce, MtBuffer **bufs, const NsUInteger *offsets, NsRange range) {
    [(id<MTLArgumentEncoder>)cce setBuffers: (id<MTLBuffer>*)bufs
                                    offsets: offsets
                                  withRange: mtNSRange(range)];
}

MT_EXPORT
void
mtArgumentEncoderSetTextureAtIndex(MtArgumentEncoder *cce,  MtTexture *tex, NsUInteger indx) {
    [(id<MTLArgumentEncoder>)cce setTexture: (id<MTLTexture>)tex
                                    atIndex: indx];
}

MT_EXPORT
void
mtArgumentEncoderSetTexturesWithRange(MtArgumentEncoder *cce,  MtTexture **textures, NsRange range) {
    [(id<MTLArgumentEncoder>)cce setTextures: (id<MTLTexture>*)textures
                                   withRange: mtNSRange(range)];
}

MT_EXPORT
void
mtArgumentEncoderSetSamplerStateAtIndex(MtArgumentEncoder *cce,  MtSamplerState *sampler, NsUInteger indx) {
    [(id<MTLArgumentEncoder>)cce setSamplerState: (id<MTLSamplerState>)sampler 
    	  								 atIndex: indx];
}


MT_EXPORT
void
mtArgumentEncoderSetSamplerStatesWithRange(MtArgumentEncoder *cce,  MtSamplerState **samplers, NsRange range) {
    [(id<MTLArgumentEncoder>)cce setSamplerStates: (id<MTLSamplerState>*)samplers 
                                        withRange: mtNSRange(range)];
}

/*MT_EXPORT
void
mtArgumentEncoderSetComputePipelineState(MtArgumentEncoder *cce, MtComputePipelineState *state, NsUInteger index) {
    [(id<MTLArgumentEncoder>)cce setComputePipelineState: (id<MTLComputePipelineState>)state
    											 atIndex: index]; 
} */

MT_EXPORT
void*
mtArgumentEncoderConstantDataAtIndex(MtArgumentEncoder *cce,  NsUInteger index) {
	return [(id<MTLArgumentEncoder>)cce constantDataAtIndex: index];
}

MT_EXPORT
void
mtArgumentEncoderSetIndirectCommandBuffer(MtArgumentEncoder *cce,  MtIndirectCommandBuffer *cbuf, NsUInteger index) {
	[(id<MTLArgumentEncoder>)cce setIndirectCommandBuffer: (id<MTLIndirectCommandBuffer>)cbuf
												  atIndex: index];
}

MT_EXPORT
void
mtArgumentEncoderSetIndirectCommandBuffers(MtArgumentEncoder *cce,  MtIndirectCommandBuffer **cbufs, NsRange range) {
	[(id<MTLArgumentEncoder>)cce setIndirectCommandBuffers: (id<MTLIndirectCommandBuffer>*)cbufs
											     withRange: mtNSRange(range)];
}





MT_EXPORT
NsUInteger
mtArgumentEncoderAlignment(MtArgumentEncoder *cce) {
	return [(id<MTLArgumentEncoder>)cce alignment];
}
