 /*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_compute_pipeline_h
#define cmt_compute_pipeline_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

// Create Pipeline
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineState*
mtNewComputePipelineStateWithFunction(MtDevice *device, MtFunction* fun, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineState*
mtNewComputePipelineStateWithFunctionReflection(MtDevice *device, MtFunction* fun,MtPipelineOption opt, 
                                        MtComputePipelineReflection **reflection, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineState*
mtNewComputePipelineStateWithDescriptor(MtDevice *device, MtComputePipelineDescriptor* desc, 
										MtPipelineOption opt, 
										MtComputePipelineReflection **reflection,
										NsError **error);

// properties
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtComputePipelineDevice(MtComputePipelineState *pip);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
const char*
mtComputePipelineLabel(MtComputePipelineState *pip);

// attributes
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtComputePipelineMaxTotalThreadsPerThreadgroup(MtComputePipelineState *pip);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtComputePipelineThreadExecutionWidth(MtComputePipelineState *pip);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtComputePipelineStaticThreadgroupMemoryLength(MtComputePipelineState *pip);

// imageblock attri
/*MT_EXPORT
NsUInteger
mtComputePipelineImageblockMemoryLengthForDimensions(MtComputePipelineState *pip, MtSize imageblockDimensions); IOS 11*/

#ifdef __cplusplus
}
#endif
#endif /* cmt_compute_pipeline_h */
