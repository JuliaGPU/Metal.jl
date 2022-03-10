/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_command_enc_compute_h
#define cmt_command_enc_compute_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

// Creating Command Encoders
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputeCommandEncoder*
mtNewComputeCommandEncoder(MtCommandBuffer *cmdb);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtComputeCommandEncoder*
mtNewComputeCommandEncoderWithDispatchType(MtCommandBuffer *cmdb, MtDispatchType dtype);

// Could be removed because in base class
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderEndEncoding(MtComputeCommandEncoder *cce);

// Specifying the Compute Pipeline State

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetComputePipelineState(MtComputeCommandEncoder *cce, MtComputePipelineState *state);

// Specifying Arguments for a Compute Function

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetBufferOffsetAtIndex(MtComputeCommandEncoder *cce, MtBuffer *buf, NsUInteger offset, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetBuffersOffsetsWithRange(MtComputeCommandEncoder *cce, MtBuffer **bufs, const NsUInteger *offsets, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderBufferSetOffsetAtIndex(MtComputeCommandEncoder *cce, NsUInteger offset, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetBytesLengthAtIndex(MtComputeCommandEncoder *cce, const void* ptr, NsUInteger length, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetSamplerStateAtIndex(MtComputeCommandEncoder *cce,  MtSamplerState *sampler, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetSamplerStatesWithRange(MtComputeCommandEncoder *cce,  MtSamplerState **samplers, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex(MtComputeCommandEncoder *cce,  MtSamplerState *sampler, float lodMinClamp, float lodMaxClamp, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetTextureAtIndex(MtComputeCommandEncoder *cce,  MtTexture *tex, NsUInteger indx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetTexturesWithRange(MtComputeCommandEncoder *cce,  MtTexture **textures, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex(MtComputeCommandEncoder *cce,  NsUInteger length, NsUInteger indx);

// Executing a Compute Function Directly

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(MtComputeCommandEncoder *cce, MtSize threadgroupsPerGrid, MtSize threadsPerThreadgroup);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup(MtComputeCommandEncoder *cce, MtSize threadsPerGrid, MtSize threadsPerThreadgroup);

// Executing a Compute Function Indirectly
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup(MtComputeCommandEncoder *cce, MtBuffer *indirectBuffer, NsUInteger indirectBufferOffset, MtSize threadsPerThreadgroup);

// Specifying Resource Usage for Argument Buffers
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtComputeCommandEncoderUseResourceUsage(MtComputeCommandEncoder *cce, MtResource *res, MtResourceUsage usage);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtComputeCommandEncoderUseResourcesCountUsage(MtComputeCommandEncoder *cce, MtResource **res, NsUInteger count, MtResourceUsage usage);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtComputeCommandEncoderUseHeap(MtComputeCommandEncoder *cce, MtHeap *heap);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtComputeCommandEncoderUseHeaps(MtComputeCommandEncoder *cce, MtHeap **heaps, NsUInteger count);

//Specifying the Stage-In Region
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtComputeCommandEncoderSetStageInRegion(MtComputeCommandEncoder *cce, MtRegion region);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer(MtComputeCommandEncoder *cce, MtBuffer *buf, NsUInteger offset);

// Executing Commands Concurrently or Serially
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
MtDispatchType
mtComputeCommandEncoderDispatchType(MtComputeCommandEncoder *cce);

// Executing Commands Concurrently or Serially
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtComputeCommandEncoderMemoryBarrierWithScope(MtComputeCommandEncoder *cce, MtBarrierScope scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtComputeCommandEncoderMemoryBarrierWithResource(MtComputeCommandEncoder *cce, MtResource **resources, NsUInteger count);

MT_EXPORT
void
mtComputeCommandEncoderExecuteCommandInBuffer(MtComputeCommandEncoder *cce, MtResource **resources, NsUInteger count);

#ifdef __cplusplus
}
#endif
#endif /* cmt_command_enc_compute_h */
