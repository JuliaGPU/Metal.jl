/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_pass_h
#define cmt_pass_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtRenderPassDesc*
mtNewPass(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtPassTexture(MtRenderPassDesc *pass,
              int               colorAttch,
              MtTexture        *tex);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtPassLoadAction(MtRenderPassDesc *pass,
                 int               colorAttch,
                 MtLoadAction      action);
#ifdef __cplusplus
}
#endif
#endif /* cmt_pass_h */
