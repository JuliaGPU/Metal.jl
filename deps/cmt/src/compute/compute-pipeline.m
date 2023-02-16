/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/compute/compute-pipeline.h"
#import "cmt/error.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
MtComputePipelineDescriptor*
mtNewComputePipelineDescriptor(void) {
    return [MTLComputePipelineDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
const char*
mtComputePipelineDescriptorLabel(MtComputePipelineDescriptor *desc) {
  return (const char*)Cstring([(MTLComputePipelineDescriptor*)desc label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorLabelSet(MtComputePipelineDescriptor *desc, const char *label) {
    [(MTLComputePipelineDescriptor*)desc setLabel: mtNSString(label)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
MtFunction*
mtComputePipelineDescriptorComputeFunction(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc computeFunction];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorComputeFunctionSet(MtComputePipelineDescriptor *desc, MtFunction *fun) {
    [(MTLComputePipelineDescriptor*)desc setComputeFunction: fun];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
bool
mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidth(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc threadGroupSizeIsMultipleOfThreadExecutionWidth];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorThreadGroupSizeIsMultipleOfThreadExecutionWidthSet(MtComputePipelineDescriptor *desc, bool val) {
    [(MTLComputePipelineDescriptor*)desc setThreadGroupSizeIsMultipleOfThreadExecutionWidth: val];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
uint32_t
mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroup(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc maxTotalThreadsPerThreadgroup];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
void
mtComputePipelineDescriptorMaxTotalThreadsPerThreadgroupSet(MtComputePipelineDescriptor *desc, uint32_t val) {
    [(MTLComputePipelineDescriptor*)desc setMaxTotalThreadsPerThreadgroup: val];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
uint32_t
mtComputePipelineDescriptorMaxCallStackDepth(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc maxCallStackDepth];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
void
mtComputePipelineDescriptorMaxCallStackDepthSet(MtComputePipelineDescriptor *desc, uint32_t val) {
    [(MTLComputePipelineDescriptor*)desc setMaxCallStackDepth: val];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(13.0))
bool
mtComputePipelineDescriptorSupportIndirectCommandBuffers(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc supportIndirectCommandBuffers];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(9.0))
void
mtComputePipelineDescriptorReset(MtComputePipelineDescriptor *desc) {
    [(MTLComputePipelineDescriptor*)desc reset];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.00), mt_ios(14.0))
bool
mtComputePipelineDescriptorSupportAddingBinaryFunctions(MtComputePipelineDescriptor *desc) {
    return [(MTLComputePipelineDescriptor*)desc supportAddingBinaryFunctions];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineState*
mtNewComputePipelineStateWithFunction(MtDevice *device, MtFunction* fun, NsError **error) {
    return[(id<MTLDevice>)device newComputePipelineStateWithFunction: fun error: (NSError **)error];
}

CF_RETURNS_RETAINED
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MT_EXPORT
MtComputePipelineState*
mtNewComputePipelineStateWithFunctionReflection(MtDevice *device, MtFunction* fun,MtPipelineOption opt,
                                        MtComputePipelineReflection **reflection, NsError **error) {
    return [(id<MTLDevice>)device
                newComputePipelineStateWithFunction: fun
                                            options: (MTLPipelineOption)opt
                                         reflection: (MTLAutoreleasedComputePipelineReflection*) reflection
                                              error: (NSError **)error];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineState*
mtNewComputePipelineStateWithDescriptor(MtDevice *device, MtComputePipelineDescriptor* desc,
                                        MtPipelineOption opt,
                                        MtComputePipelineReflection **reflection,
                                        NsError **error) {
    return [(id<MTLDevice>)device
        newComputePipelineStateWithDescriptor: (MTLComputePipelineDescriptor*)desc
                                      options: (MTLPipelineOption)opt
                                   reflection: (MTLAutoreleasedComputePipelineReflection*) reflection
                                        error: (NSError **)error];

}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtComputePipelineDevice(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
const char*
mtComputePipelineLabel(MtComputePipelineState *pip) {
    return Cstring([(id<MTLComputePipelineState>)pip label]);
}

// Properties
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtComputePipelineMaxTotalThreadsPerThreadgroup(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip maxTotalThreadsPerThreadgroup];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtComputePipelineThreadExecutionWidth(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip threadExecutionWidth];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtComputePipelineStaticThreadgroupMemoryLength(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip staticThreadgroupMemoryLength];
}

/*MT_EXPORT
NsUInteger
mtComputePipelineImageblockMemoryLengthForDimensions(MtComputePipelineState *pip, MtSize imageblockDimensions) {
    return [(id<MTLComputePipelineState>)pip imageblockMemoryLengthForDimensions: mtMTLSize(imageblockDimensions)];
} IOS 11*/
