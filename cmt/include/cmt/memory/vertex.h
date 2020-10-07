/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_vertex_h
#define cmt_vertex_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

typedef enum MtVertexFormat {
  MtVertexFormatInvalid = 0,
  
  MtVertexFormatUChar2 = 1,
  MtVertexFormatUChar3 = 2,
  MtVertexFormatUChar4 = 3,
  
  MtVertexFormatChar2 = 4,
  MtVertexFormatChar3 = 5,
  MtVertexFormatChar4 = 6,
  
  MtVertexFormatUChar2Normalized = 7,
  MtVertexFormatUChar3Normalized = 8,
  MtVertexFormatUChar4Normalized = 9,
  
  MtVertexFormatChar2Normalized = 10,
  MtVertexFormatChar3Normalized = 11,
  MtVertexFormatChar4Normalized = 12,
  
  MtVertexFormatUShort2 = 13,
  MtVertexFormatUShort3 = 14,
  MtVertexFormatUShort4 = 15,
  
  MtVertexFormatShort2 = 16,
  MtVertexFormatShort3 = 17,
  MtVertexFormatShort4 = 18,
  
  MtVertexFormatUShort2Normalized = 19,
  MtVertexFormatUShort3Normalized = 20,
  MtVertexFormatUShort4Normalized = 21,
  
  MtVertexFormatShort2Normalized = 22,
  MtVertexFormatShort3Normalized = 23,
  MtVertexFormatShort4Normalized = 24,
  
  MtVertexFormatHalf2 = 25,
  MtVertexFormatHalf3 = 26,
  MtVertexFormatHalf4 = 27,
  
  MtVertexFormatFloat  = 28,
  MtVertexFormatFloat2 = 29,
  MtVertexFormatFloat3 = 30,
  MtVertexFormatFloat4 = 31,
  
  MtVertexFormatInt  = 32,
  MtVertexFormatInt2 = 33,
  MtVertexFormatInt3 = 34,
  MtVertexFormatInt4 = 35,
  
  MtVertexFormatUInt  = 36,
  MtVertexFormatUInt2 = 37,
  MtVertexFormatUInt3 = 38,
  MtVertexFormatUInt4 = 39,
  
  MtVertexFormatInt1010102Normalized  = 40,
  MtVertexFormatUInt1010102Normalized = 41,
  
  MtVertexFormatUChar4Normalized_BGRA = 42,

  MtVertexFormatUChar           = 45,
  MtVertexFormatChar            = 46,
  MtVertexFormatUCharNormalized = 47,
  MtVertexFormatCharNormalized  = 48,
  
  MtVertexFormatUShort           = 49,
  MtVertexFormatShort            = 50,
  MtVertexFormatUShortNormalized = 51,
  MtVertexFormatShortNormalized  = 52,
  
  MtVertexFormatHalf = 53
} MtVertexFormat;

typedef enum MtVertexStepFunction {
  MtVertexStepFunctionConstant             = 0,
  MtVertexStepFunctionPerVertex            = 1,
  MtVertexStepFunctionPerInstance          = 2,
  MtVertexStepFunctionPerPatch             = 3,
  MtVertexStepFunctionPerPatchControlPoint = 4
} MtVertexStepFunction;

/*
typedef struct MtVertexAttribDesc {
  MtVertexFormat format;
  uint32_t       offset;
  uint32_t       bufferIndex;
} MtVertexAttribDesc;

typedef struct MtVertexBufferLayoutDesc {
  MtVertexStepFunction stepFunction;
  uint32_t             stepRate;
  uint32_t             stride;
} MtVertexBufferLayoutDesc;
*/

MT_EXPORT
MtVertexDescriptor*
mtVertexDescNew(void);

MT_EXPORT
void
mtVertexAttrib(MtVertexDescriptor * __restrict vertex,
               uint32_t                        attribIndex,
               MtVertexFormat                  format,
               uint32_t                        offset,
               uint32_t                        bufferIndex);

MT_EXPORT
void
mtVertexLayout(MtVertexDescriptor * __restrict vertex,
               uint32_t                        layoutIndex,
               uint32_t                        stride,
               uint32_t                        stepRate,
               MtVertexStepFunction            stepFunction);

MT_EXPORT
void
mtSetVertexDesc(MtRenderPipeline   * __restrict pipeline,
                MtVertexDescriptor * __restrict vert);

#endif /* cmt_vertex_h */
