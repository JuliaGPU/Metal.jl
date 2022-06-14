/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_depthstencil_h
#define cmt_depthstencil_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

typedef enum MtCompareFunction {
  MtCompareFunctionNever = 0,
  MtCompareFunctionLess = 1,
  MtCompareFunctionEqual = 2,
  MtCompareFunctionLessEqual = 3,
  MtCompareFunctionGreater = 4,
  MtCompareFunctionNotEqual = 5,
  MtCompareFunctionGreaterEqual = 6,
  MtCompareFunctionAlways = 7,
} MtCompareFunction;

typedef enum MtStencilOperation {
  MtStencilOperationKeep = 0,
  MtStencilOperationZero = 1,
  MtStencilOperationReplace = 2,
  MtStencilOperationIncrementClamp = 3,
  MtStencilOperationDecrementClamp = 4,
  MtStencilOperationInvert = 5,
  MtStencilOperationIncrementWrap = 6,
  MtStencilOperationDecrementWrap = 7,
} MtStencilOperation;

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDepthStencil*
mtDepthStencil(MtCompareFunction depthCompareFunc, bool depthWriteEnabled);

#ifdef __cplusplus
}
#endif
#endif /* cmt_depthstencil_h */
