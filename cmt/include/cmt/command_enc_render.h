/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_command_enc_render_h
#define cmt_command_enc_render_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"


MT_EXPORT
MtRenderCommandEncoder*
mtNewRenderCommandEncoder(MtCommandBuffer *cmdb, MtRenderPassDesc *pass);

MT_EXPORT
void
mtFrontFace(MtRenderCommandEncoder *rce, MtWinding winding);

MT_EXPORT
void
mtCullMode(MtRenderCommandEncoder *rce, MtCullMode mode);

MT_EXPORT
void
mtViewport(MtRenderCommandEncoder *rce, MtViewport *viewport);

MT_EXPORT
void
mtSetRenderState(MtRenderCommandEncoder *rce, MtRenderPipeline *pipline);

MT_EXPORT
void
mtSetDepthStencil(MtRenderCommandEncoder *rce, MtDepthStencil *ds);

MT_EXPORT
void
mtVertexBytes(MtRenderCommandEncoder *rce,
              void                   *bytes,
              size_t                  legth,
              uint32_t                atIndex);

MT_EXPORT
void
mtVertexBuffer(MtRenderCommandEncoder *rce,
               MtBuffer                *buf,
               size_t                  off,
               uint32_t                index);

MT_EXPORT
void
mtFragmentBuffer(MtRenderCommandEncoder *rce,
                 MtBuffer               *buf,
                 size_t                  off,
                 uint32_t                index);

MT_EXPORT
void
mtDrawPrims(MtRenderCommandEncoder *rce,
            MtPrimitiveType         type,
            size_t                  start,
            size_t                  count);

MT_EXPORT
void
mtDrawIndexedPrims(MtRenderCommandEncoder *rce,
                   MtPrimitiveType         type,
                   uint32_t                indexCount,
                   MtIndexType             indexType,
                   MtBuffer               *indexBuffer,
                   uint32_t                indexBufferOffset);

#ifdef __cplusplus
}
#endif
#endif /* cmt_command_enc_render_h */
