/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_pipeline_h
#define cmt_pipeline_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/error.h"
#include "cmt/pixelformat.h"

typedef enum MtFuncType {
  MT_FUNC_VERT = 1,
  MT_FUNC_FRAG = 2
} MtFuncType;

MT_EXPORT
MtRenderDesc*
mtNewRenderPipeline(MtPixelFormat pixelFormat);

MT_EXPORT
void
mtSetFunc(MtRenderDesc *pipDesc,
          MtFunction   *func,
          MtFuncType    functype);

MT_EXPORT
MtRenderPipeline*
mtNewRenderState(MtDevice     *device,
                    MtRenderDesc *pipDesc, 
                      NsError **error);

MT_EXPORT
void
mtColorPixelFormat(MtRenderDesc * __restrict renderdesc,
                   uint32_t                  index,
                   MtPixelFormat             pixelFormat);

MT_EXPORT
void
mtDepthPixelFormat(MtRenderDesc * __restrict renderdesc,
                   MtPixelFormat             pixelFormat);

MT_EXPORT
void
mtStencilPixelFormat(MtRenderDesc * __restrict renderdesc,
                     MtPixelFormat             pixelFormat);

MT_EXPORT
void
mtSampleCount(MtRenderDesc * __restrict renderdesc,
              uint32_t                  sampleCount);

#ifdef __cplusplus
}
#endif
#endif /* cmt_pipeline_h */
