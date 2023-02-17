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

// Compute Pipeline Descriptor
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
MtComputePipelineDescriptor*
mtNewComputePipelineDescriptor(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
const char*
mtComputePipelineDescriptorLabel(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorLabelSet(MtComputePipelineDescriptor *desc, const char *label);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
MtFunction*
mtComputePipelineDescriptorComputeFunction(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorComputeFunctionSet(MtComputePipelineDescriptor *desc, MtFunction *fun);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
bool
mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidth(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidthSet(MtComputePipelineDescriptor *desc, bool val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
uint32_t
mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroup(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroupSet(MtComputePipelineDescriptor *desc, uint32_t val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
uint32_t
mtComputePipelineDescriptorMaxCallStackDepth(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
void
mtComputePipelineDescriptorMaxCallStackDepthSet(MtComputePipelineDescriptor *desc, uint32_t val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(13.0))
bool
mtComputePipelineDescriptorSupportIndirectCommandBuffers(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorReset(MtComputePipelineDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
bool
mtComputePipelineDescriptorSupportAddingBinaryFunctions(MtComputePipelineDescriptor *desc);

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
