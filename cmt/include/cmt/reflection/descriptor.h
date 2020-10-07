#ifndef cmt_descriptor_h
#define cmt_descriptor_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MtComputePipelineReflection*
mtNewComputePipelineReflection();

MT_EXPORT
const MtArgument *
mtComputePipelinereflectionArguments(MtComputePipelineReflection *refl);

#ifdef __cplusplus
}
#endif
#endif /* cmt_descriptor_h */ 
