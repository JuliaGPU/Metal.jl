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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtRenderDesc*
mtNewRenderPipeline(MtPixelFormat pixelFormat);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtSetFunc(MtRenderDesc *pipDesc,
          MtFunction   *func,
          MtFuncType    functype);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtRenderPipeline*
mtNewRenderState(MtDevice     *device,
                    MtRenderDesc *pipDesc, 
                      NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtColorPixelFormat(MtRenderDesc * __restrict renderdesc,
                   uint32_t                  index,
                   MtPixelFormat             pixelFormat);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtDepthPixelFormat(MtRenderDesc * __restrict renderdesc,
                   MtPixelFormat             pixelFormat);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtStencilPixelFormat(MtRenderDesc * __restrict renderdesc,
                     MtPixelFormat             pixelFormat);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtSampleCount(MtRenderDesc * __restrict renderdesc,
              uint32_t                  sampleCount);

#ifdef __cplusplus
}
#endif
#endif /* cmt_pipeline_h */
