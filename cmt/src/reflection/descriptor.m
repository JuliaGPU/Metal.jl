#include "impl/common.h"
#include "cmt/reflection/descriptor.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtComputePipelineReflection*
mtNewComputePipelineReflection() {
    return [MTLComputePipelineReflection new];
}

MT_EXPORT
const MtArgument *
mtComputePipelinereflectionArguments(MtComputePipelineReflection *refl) {
    NSArray<MTLArgument*> *_args = [(MTLComputePipelineReflection*) refl arguments];
    
    int n = [_args count];
    MtArgument* *args = malloc(sizeof(MtArgument*) * (n+1)); 
        for (int i=0; i < n; i++) {
      args[i] = [_args objectAtIndex:i];
    }
    args[n] = NULL;

    return args;
}  
