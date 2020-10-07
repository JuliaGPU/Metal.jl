/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/rendering/depthstencil.h"

MT_EXPORT
MtDepthStencil*
mtDepthStencil(MtCompareFunction depthCompareFunc, bool depthWriteEnabled) {
  MTLDepthStencilDescriptor *depthStateDesc;
  
  depthStateDesc                      = [MTLDepthStencilDescriptor new];
  depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
  depthStateDesc.depthWriteEnabled    = YES;
  
  return depthStateDesc;
}
