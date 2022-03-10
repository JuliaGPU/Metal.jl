/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/common.h"
#import "cmt/pixelformat.h"

#import "cmt/rendering/pass.h"
#import "cmt/rendering/pipeline.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtRenderDesc*
mtNewRenderPipeline(MtPixelFormat pixelFormat) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = [MTLRenderPipelineDescriptor new];
  mpipDesc.colorAttachments[0].pixelFormat = (MTLPixelFormat)pixelFormat;
  return mpipDesc;
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtRenderPipeline*
mtNewRenderState(MtDevice *device, MtRenderDesc *pipDesc, NsError **error) {
  return [(id<MTLDevice>)device
          newRenderPipelineStateWithDescriptor: (MTLRenderPipelineDescriptor *)pipDesc
          error: (NSError**)&error];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtSetFunc(MtRenderDesc *pipDesc,
          MtFunction   *func,
          MtFuncType    functype) {
  MTLRenderPipelineDescriptor *mpip;

  mpip = pipDesc;

  switch (functype) {
    case MT_FUNC_VERT:
      mpip.vertexFunction   = func;
      break;
    case MT_FUNC_FRAG:
      mpip.fragmentFunction = func;
      break;
    default: break;
  }
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtColorPixelFormat(MtRenderDesc * __restrict renderdesc,
                   uint32_t                  index,
                   MtPixelFormat             pixelFormat) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = renderdesc;
  mpipDesc.colorAttachments[index].pixelFormat = (MTLPixelFormat)pixelFormat;
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtDepthPixelFormat(MtRenderDesc * __restrict renderdesc,
                   MtPixelFormat             pixelFormat) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = renderdesc;
  mpipDesc.depthAttachmentPixelFormat = (MTLPixelFormat)pixelFormat;
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtStencilPixelFormat(MtRenderDesc * __restrict renderdesc,
                     MtPixelFormat             pixelFormat) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = renderdesc;
  mpipDesc.stencilAttachmentPixelFormat = (MTLPixelFormat)pixelFormat;
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtSampleCount(MtRenderDesc * __restrict renderdesc,
              uint32_t                  sampleCount) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = renderdesc;
  mpipDesc.sampleCount = sampleCount;
}
