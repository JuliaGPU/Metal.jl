/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_descriptor_h
#define cmt_descriptor_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineReflection*
mtNewComputePipelineReflection(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const MtArgument *
mtComputePipelinereflectionArguments(MtComputePipelineReflection *refl);

#ifdef __cplusplus
}
#endif
#endif /* cmt_descriptor_h */ 
