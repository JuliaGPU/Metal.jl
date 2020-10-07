#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_enc_render.h"

/*MT_EXPORT
MtResourceStateCommandEncoder*
mtNewResourceStateCommandEncoder(MtCommandBuffer *cmdb) {
    return [(id<MTLCommandBuffer>)cmdb resourceStateCommandEncoder];
}*/ //IOS 13

CF_RETURNS_RETAINED
MT_EXPORT
MtRenderCommandEncoder*
mtNewRenderCommandEncoder(MtCommandBuffer *cmdb, MtRenderPassDesc *pass) {
  return [(id<MTLCommandBuffer>)cmdb renderCommandEncoderWithDescriptor: pass];
}

MT_EXPORT
void
mtFrontFace(MtRenderCommandEncoder *rce, MtWinding winding) {
  [(id<MTLRenderCommandEncoder>)rce setFrontFacingWinding:(MTLWinding)winding];
}

MT_EXPORT
void
mtCullMode(MtRenderCommandEncoder *rce, MtCullMode mode) {
  [(id<MTLRenderCommandEncoder>)rce setCullMode:(MTLCullMode)mode];
}

MT_EXPORT
void
mtViewport(MtRenderCommandEncoder *rce, MtViewport *viewport) {
  [(id<MTLRenderCommandEncoder>)rce setViewport: *(MTLViewport *)viewport];
}

MT_EXPORT
void
mtSetRenderState(MtRenderCommandEncoder *rce, MtRenderPipeline *pipline) {
  [(id<MTLRenderCommandEncoder>)rce setRenderPipelineState: pipline];
}

MT_EXPORT
void
mtSetDepthStencil(MtRenderCommandEncoder *rce, MtDepthStencil *ds) {
  [(id<MTLRenderCommandEncoder>)rce setDepthStencilState: ds];
}

MT_EXPORT
void
mtVertexBytes(MtRenderCommandEncoder *enc,
              void                   *bytes,
              size_t                  legth,
              uint32_t                atIndex) {
  [(id<MTLRenderCommandEncoder>)enc setVertexBytes: bytes
                                            length: legth
                                           atIndex: atIndex];
}

MT_EXPORT
void
mtVertexBuffer(MtRenderCommandEncoder *rce,
               MtBuffer               *buf,
               size_t                  off,
               uint32_t                index) {
  [(id<MTLRenderCommandEncoder>)rce setVertexBuffer: buf
                                             offset: off
                                            atIndex: index];
}

MT_EXPORT
void
mtFragmentBuffer(MtRenderCommandEncoder *rce,
                 MtBuffer               *buf,
                 size_t                  off,
                 uint32_t                index) {
  [(id<MTLRenderCommandEncoder>)rce setFragmentBuffer: buf
                                               offset: off
                                              atIndex: index];
}

MT_EXPORT
void
mtDrawPrims(MtRenderCommandEncoder *rce,
            MtPrimitiveType         type,
            size_t                  start,
            size_t                  count) {
  [(id<MTLRenderCommandEncoder>)rce drawPrimitives: (MTLPrimitiveType)type
                                       vertexStart: start
                                       vertexCount: count];
}

MT_EXPORT
void
mtDrawIndexedPrims(MtRenderCommandEncoder *rce,
                   MtPrimitiveType         type,
                   uint32_t                indexCount,
                   MtIndexType             indexType,
                   MtBuffer               *indexBuffer,
                   uint32_t                indexBufferOffset) {
  [(id<MTLRenderCommandEncoder>)rce
          drawIndexedPrimitives: (MTLPrimitiveType)type
                     indexCount: indexCount
                      indexType: (MTLIndexType)indexType
                    indexBuffer: indexBuffer
              indexBufferOffset: indexBufferOffset];
}

MT_EXPORT
void
mtEndEncoding(MtRenderCommandEncoder *rce) {
  [(id<MTLRenderCommandEncoder>)rce endEncoding];
}





