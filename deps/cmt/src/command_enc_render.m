/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_enc_render.h"

/*MT_EXPORT
MtResourceStateCommandEncoder*
mtNewResourceStateCommandEncoder(MtCommandBuffer *cmdb) {
    return [(id<MTLCommandBuffer>)cmdb resourceStateCommandEncoder];
}*/ //IOS 13

CF_RETURNS_RETAINED
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MT_EXPORT
MtRenderCommandEncoder*
mtNewRenderCommandEncoder(MtCommandBuffer *cmdb, MtRenderPassDesc *pass) {
  id<MTLRenderCommandEncoder> encoder = [(id<MTLCommandBuffer>)cmdb renderCommandEncoderWithDescriptor: pass];
  // Per Apple's "Basic Memory Management Rules" the above invocation does not imply ownership.
  // To be consistent the name of the function and CF_RETURNS_RETAINED, we explicitly claim
  // ownership with an explicit `retain`
  [encoder retain];
  return encoder;
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtFrontFace(MtRenderCommandEncoder *rce, MtWinding winding) {
  [(id<MTLRenderCommandEncoder>)rce setFrontFacingWinding:(MTLWinding)winding];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCullMode(MtRenderCommandEncoder *rce, MtCullMode mode) {
  [(id<MTLRenderCommandEncoder>)rce setCullMode:(MTLCullMode)mode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtViewport(MtRenderCommandEncoder *rce, MtViewport *viewport) {
  [(id<MTLRenderCommandEncoder>)rce setViewport: *(MTLViewport *)viewport];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtEndEncoding(MtRenderCommandEncoder *rce) {
  [(id<MTLRenderCommandEncoder>)rce endEncoding];
}
