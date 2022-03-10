/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/reflection/descriptor.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtComputePipelineReflection*
mtNewComputePipelineReflection() {
    return [MTLComputePipelineReflection new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
