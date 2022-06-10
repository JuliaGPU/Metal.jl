/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/rendering/depthstencil.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDepthStencil*
mtDepthStencil(MtCompareFunction depthCompareFunc, bool depthWriteEnabled) {
  MTLDepthStencilDescriptor *depthStateDesc;
  
  depthStateDesc                      = [MTLDepthStencilDescriptor new];
  depthStateDesc.depthCompareFunction = (MTLCompareFunction)depthCompareFunc;
  depthStateDesc.depthWriteEnabled    = depthWriteEnabled;
  
  return depthStateDesc;
}
