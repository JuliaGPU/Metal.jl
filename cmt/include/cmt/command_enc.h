/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_commandenc_h
#define cmt_commandenc_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
void
mtCommandEncoderEndEncoding(MtCommandEncoder *ce);

MT_EXPORT
MtDevice*
mtCommandEncoderDevice(MtCommandEncoder *ce);

MT_EXPORT
const char*
mtCommandEncoderLabel(MtCommandEncoder *ce);

MT_EXPORT
void
mtCommandEncoderInsertDebugSignpost(MtCommandEncoder *ce, char* string);

MT_EXPORT
void
mtCommandEncoderPushDebugGroup(MtCommandEncoder *ce, char* string);

MT_EXPORT
void
mtCommandEncoderPopDebugGroup(MtCommandEncoder *ce);

#ifdef __cplusplus
}
#endif
#endif /* cmt_commandenc_h */
