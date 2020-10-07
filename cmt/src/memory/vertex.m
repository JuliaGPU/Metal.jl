/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/common.h"
#import "impl/common.h"
#import "cmt/memory/vertex.h"

MT_EXPORT
MtVertexDescriptor*
mtVertexDescNew() {
  MTLVertexDescriptor *mvertDesc;
  mvertDesc = [MTLVertexDescriptor vertexDescriptor];
  return mvertDesc;
}

MT_EXPORT
void
mtVertexAttrib(MtVertexDescriptor * __restrict vertex,
               uint32_t                        attribIndex,
               MtVertexFormat                  format,
               uint32_t                        offset,
               uint32_t                        bufferIndex) {
  MTLVertexDescriptor          *mvert;
  MTLVertexAttributeDescriptor *mattrib;

  mvert               = vertex;
  mattrib             = mvert.attributes[attribIndex];
  
  mattrib.format      = (MTLVertexFormat)format;
  mattrib.offset      = offset;
  mattrib.bufferIndex = bufferIndex;
}

MT_EXPORT
void
mtVertexLayout(MtVertexDescriptor * __restrict vertex,
               uint32_t                        layoutIndex,
               uint32_t                        stride,
               uint32_t                        stepRate,
               MtVertexStepFunction            stepFunction) {
  MTLVertexDescriptor             *mvert;
  MTLVertexBufferLayoutDescriptor *mlay;

  mvert             = vertex;
  mlay              = mvert.layouts[layoutIndex];
  
  mlay.stride       = stride;
  mlay.stepRate     = stepRate;
  mlay.stepFunction = (MTLVertexStepFunction)stepFunction;
}

MT_EXPORT
void
mtSetVertexDesc(MtRenderPipeline   * __restrict pipeline,
                MtVertexDescriptor * __restrict vert) {
  MTLRenderPipelineDescriptor *mpip;
  
  mpip = pipeline;

  mpip.vertexDescriptor = vert;
}
