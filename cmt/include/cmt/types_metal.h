/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_types_metal_h
#define cmt_types_metal_h

#include "cmt/common.h"
#include "cmt/types_foundation.h"
#include "cmt/enums.h"

typedef struct {
    NsUInteger width, height, depth;
} MtSize;

typedef struct {
    NsUInteger x, y, z;
} MtOrigin;

typedef struct {
    NsUInteger size;
    NsUInteger align;
} MtSizeAndAlign;

typedef void MtDevice;
typedef void MtRenderDesc;
typedef void MtRenderPipeline;
typedef void MtCommandQueue;
typedef void MtCommandEncoder;
typedef void MtBlitCommandEncoder;
typedef void MtLibrary;
typedef void MtRenderPassDesc;
typedef void MtTexture;
typedef void MtCommandBuffer;
typedef void MtDrawable;
typedef void MtVertexDescriptor;
typedef void MtTextureDescriptor;
typedef void MtIndirectCommandBufferDescriptor;
typedef void MtIndirectCommandBuffer;
typedef void MtIndirectComputeCommand;
typedef void MtIndirectRenderCommand;
typedef void MtDepthStencil;
typedef void MtBuffer;
typedef void MtCompileOptions;

typedef void MtFunction;
typedef void MtFunctionConstant;
typedef void MtFunctionConstantValues;

typedef void MtEvent;
typedef void MtSharedEvent;
typedef void MtSharedEventHandle;
typedef void MtFence;
typedef void (^MtSharedEventNotificationBlock)(MtSharedEvent *ev, uint64_t value);
typedef void (*MtCommandBufferHandlerFun)(MtCommandBuffer * buf);
typedef void MtSharedEventListener;

typedef void MtResource;
typedef void MtHeap;
typedef void MtHeapDescriptor;

typedef void MtAttribute;
typedef void MtVertexAttribute;

typedef void MtComputePipelineState;
typedef void MtSamplerState;

typedef void MtRenderCommandEncoder;
typedef void MtComputeCommandEncoder;
typedef void MtBlitCommandEncoder;
typedef void MtResourceStateCommandEncoder;

typedef void MtCounterSampleBuffer;

typedef void MtArgumentEncoder;
typedef void MtAutoreleasedArgument;
typedef void MtArgument;
typedef void MtArgumentDescriptor;

typedef void MtComputePipelineDescriptor;
typedef void MtPointerType;
typedef void MtArrayType;
typedef void MtStructType;

typedef void MtComputePipelineReflection;
typedef void MtRenderPipelineReflection;


typedef struct {
    uint32_t threadgroupsPerGrid[3];
} MtDispatchThreadgroupsIndirectArguments;

typedef struct {
	uint32_t  stageInOrigin[3];
	uint32_t  stageInSize[3];
} MtStageInRegionIndirectArguments;

typedef struct
{
    MtOrigin origin;
    MtSize   size;
} MtRegion;

typedef struct
{
    uint32_t location;
    uint32_t length;
}  MtIndirectCommandBufferExecutionRange;

typedef struct
{
    MtTextureSwizzle red;
    MtTextureSwizzle green;
    MtTextureSwizzle blue;
    MtTextureSwizzle alpha;
} MtTextureSwizzleChannels;

#endif /* cmt_types_metal_h */
