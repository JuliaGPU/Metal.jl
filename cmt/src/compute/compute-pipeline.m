#import "impl/common.h"
#import "cmt/compute/compute-pipeline.h"
#import "cmt/error.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtComputePipelineState*
mtNewComputePipelineStateWithFunction(MtDevice *device, MtFunction* fun, NsError **error) {
    return[(id<MTLDevice>)device newComputePipelineStateWithFunction: fun error: (NSError **)error];
}

CF_RETURNS_RETAINED
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
MtDevice*
mtComputePipelineDevice(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip device];
}

MT_EXPORT
void
mtComputePipelineRelease(MtComputePipelineState *pip) {
    [(id<MTLComputePipelineState>)pip release];
}

MT_EXPORT
const char*
mtComputePipelineLabel(MtComputePipelineState *pip) {
    return Cstring([(id<MTLComputePipelineState>)pip label]);
}

// Properties
MT_EXPORT
NsUInteger
mtComputePipelineMaxTotalThreadsPerThreadgroup(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip maxTotalThreadsPerThreadgroup];
}

MT_EXPORT
NsUInteger
mtComputePipelineThreadExecutionWidth(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip threadExecutionWidth];
}

MT_EXPORT
NsUInteger
mtComputePipelineStaticThreadgroupMemoryLength(MtComputePipelineState *pip) {
    return [(id<MTLComputePipelineState>)pip staticThreadgroupMemoryLength];
}

/*MT_EXPORT
NsUInteger
mtComputePipelineImageblockMemoryLengthForDimensions(MtComputePipelineState *pip, MtSize imageblockDimensions) {
    return [(id<MTLComputePipelineState>)pip imageblockMemoryLengthForDimensions: mtMTLSize(imageblockDimensions)];
} IOS 11*/
