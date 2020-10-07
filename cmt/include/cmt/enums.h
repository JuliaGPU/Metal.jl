/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_enums_h
#define cmt_enums_h

#include "common.h"

typedef enum MtPrimitiveType {
  MtPrimitiveTypePoint         = 0,
  MtPrimitiveTypeLine          = 1,
  MtPrimitiveTypeLineStrip     = 2,
  MtPrimitiveTypeTriangle      = 3,
  MtPrimitiveTypeTriangleStrip = 4
} MtPrimitiveType;

typedef enum MtVisibilityResultMode {
  MtVisibilityResultModeDisabled = 0,
  MtVisibilityResultModeBoolean  = 1,
  MtVisibilityResultModeCounting = 2
} MtVisibilityResultMode;

typedef struct MtScissorRect {
  uint32_t x, y, width, height;
} MtScissorRect;

typedef struct MtViewport {
  double originX, originY, width, height, znear, zfar;
} MtViewport;

typedef enum MtCullMode {
  MtCullModeNone  = 0,
  MtCullModeFront = 1,
  MtCullModeBack  = 2
} MtCullMode;

typedef enum MtWinding {
  MtWindingClockwise        = 0,
  MtWindingCounterClockwise = 1
} MtWinding;

typedef enum MtDepthClipMode {
  MtDepthClipModeClip  = 0,
  MtDepthClipModeClamp = 1
} MtDepthClipMode;

typedef enum MtTriangleFillMode {
  MtTriangleFillModeFill  = 0,
  MtTriangleFillModeLines = 1
} MtTriangleFillMode;

typedef struct MtDrawPrimitivesIndirectArguments {
    uint32_t vertexCount;
    uint32_t instanceCount;
    uint32_t vertexStart;
    uint32_t baseInstance;
} MtDrawPrimitivesIndirectArguments;

typedef struct MtDrawIndexedPrimitivesIndirectArguments {
    uint32_t indexCount;
    uint32_t instanceCount;
    uint32_t indexStart;
    int32_t  baseVertex;
    uint32_t baseInstance;
} MtDrawIndexedPrimitivesIndirectArguments;

typedef struct MtDrawPatchIndirectArguments {
    uint32_t patchCount;
    uint32_t instanceCount;
    uint32_t patchStart;
    uint32_t baseInstance;
} MtDrawPatchIndirectArguments;

typedef struct MtQuadTessellationFactorsHalf {
    uint16_t edgeTessellationFactor[4];
    uint16_t insideTessellationFactor[2];
} MtQuadTessellationFactorsHalf;

typedef struct MtTriangleTessellationFactorsHalf {
  uint16_t edgeTessellationFactor[3];
  uint16_t insideTessellationFactor;
} MtTriangleTessellationFactorsHalf;

typedef enum MtRenderStages {
  MtRenderStageVertex   = (1UL << 0),
  MtRenderStageFragment = (1UL << 1)
} MtRenderStages;

typedef enum MtLoadAction {
  MtLoadActionDontCare = 0,
  MtLoadActionLoad     = 1,
  MtLoadActionClear    = 2,
} MtLoadAction;

typedef enum MtIndexType {
  MtIndexTypeUInt16 = 0,
  MtIndexTypeUInt32 = 1,
} MtIndexType;

typedef enum MtStoreAction {
  MtStoreActionDontCare                   = 0,
  MtStoreActionStore                      = 1,
  MtStoreActionMultisampleResolve         = 2,
  MtStoreActionStoreAndMultisampleResolve = 3,
  MtStoreActionUnknown                    = 4,
  MtStoreActionCustomSampleDepthStore     = 5,
} MtStoreAction;

typedef enum MtDeviceLocation {
	MtDeviceLocationBuiltIn = 0,
    MtDeviceLocationSlot = 1,
    MtDeviceLocationExternal = 2,
    MtDeviceLocationUnspecified = 100,
} MtDeviceLocation;

typedef enum MtLanguageVersion {
    MtLanguageVersion1_0  = (1 << 16),
    MtLanguageVersion1_1  = (1 << 16) + 1,
    MtLanguageVersion1_2  = (1 << 16) + 2,
    MtLanguageVersion2_0  = (2 << 16),
    MtLanguageVersion2_1  = (2 << 16) + 1,
    MtLanguageVersion2_2  = (2 << 16) + 2,
} MtLanguageVersion;

typedef enum MtFunctionType {
  MtFunctionTypeVertex = 1,
  MtFunctionTypeFragment = 2,
  MtFunctionTypeKernel = 3,
} MtFunctionType;

typedef enum MtDispatchType {
    MtDispatchTypeSerial,
    MtDispatchTypeConcurrent,
} MtDispatchType;

typedef enum MtCommandBufferStatus {
    MtCommandBufferStatusNotEnqueued = 0,
    MtCommandBufferStatusEnqueued = 1,
    MtCommandBufferStatusCommitted = 2,
    MtCommandBufferStatusScheduled = 3,
    MtCommandBufferStatusCompleted = 4,
    MtCommandBufferStatusError = 5,
} MtCommandBufferStatus;

typedef enum MtResourceUsage {
  MtResourceUsageRead   = 1 << 0,
  MtResourceUsageWrite  = 1 << 1,
  MtResourceUsageSample = 1 << 2
} MtResourceUsage;

typedef enum MtGPUFamily {
    MtGPUFamilyApple1 = 1001,
    MtGPUFamilyApple2 = 1002,
    MtGPUFamilyApple3 = 1003,
    MtGPUFamilyApple4 = 1004,
    MtGPUFamilyApple5 = 1005,

    MtGPUFamilyMac1 = 2001,
    MtGPUFamilyMac2 = 2002,

    MtGPUFamilyCommon1 = 3001,
    MtGPUFamilyCommon2 = 3002,
    MtGPUFamilyCommon3 = 3003,

    MtGPUFamilyMacCatalyst1 = 4001,
    MtGPUFamilyMacCatalyst2 = 4002,
} MtGPUFamily;

typedef enum MtFeatureSet {
    MtFeatureSet_macOS_GPUFamily1_v1 = 10000,
    MtFeatureSet_OSX_GPUFamily1_v1 = MtFeatureSet_macOS_GPUFamily1_v1, // deprecated

    MtFeatureSet_macOS_GPUFamily1_v2 = 10001,
    MtFeatureSet_OSX_GPUFamily1_v2 = MtFeatureSet_macOS_GPUFamily1_v2, // deprecated
    MtFeatureSet_macOS_ReadWriteTextureTier2 = 10002,
    MtFeatureSet_OSX_ReadWriteTextureTier2 = MtFeatureSet_macOS_ReadWriteTextureTier2, // deprecated

    MtFeatureSet_macOS_GPUFamily1_v3 = 10003,

    MtFeatureSet_macOS_GPUFamily1_v4 = 10004,
    MtFeatureSet_macOS_GPUFamily2_v1 = 10005,
} MtFeatureSet;

typedef enum MtPurgeableState {
    MtPurgeableStateKeepCurrent = 1,

    MtPurgeableStateNonVolatile = 2,
    MtPurgeableStateVolatile = 3,
    MtPurgeableStateEmpty = 4,
} MtPurgeableState;

typedef enum MtCommandBufferError {
    MtCommandBufferErrorNone = 0,
    MtCommandBufferErrorInternal = 1,
    MtCommandBufferErrorTimeout = 2,
    MtCommandBufferErrorPageFault = 3,
    MtCommandBufferErrorBlacklisted = 4,
    MtCommandBufferErrorNotPermitted = 7,
    MtCommandBufferErrorOutOfMemory = 8,
    MtCommandBufferErrorInvalidResource = 9,
    MtCommandBufferErrorMemoryless = 10,
    MtCommandBufferErrorDeviceRemoved = 11,
} MtCommandBufferError;

/*!
 @enum MTLHeapType
 @abstract Describes the mode of operation for an MTLHeap.
 @constant MTLHeapTypeAutomatic
 In this mode, resources are placed in the heap automatically.
 Automatically placed resources have optimal GPU-specific layout, and may perform better than MTLHeapTypePlacement.
 This heap type is recommended when the heap primarily contains temporary write-often resources.
 @constant MTLHeapTypePlacement
 In this mode, the app places resources in the heap.
 Manually placed resources allow the app to control memory usage and heap fragmentation directly.
 This heap type is recommended when the heap primarily contains persistent write-rarely resources.
 */
typedef enum MtHeapType {
  MtHeapTypeAutomatic = 0,
    MtHeapTypePlacement = 1,
} MtHeapType;


typedef enum MtBlitOption {
  MtBlitOptionNone                       = 0,
  MtBlitOptionDepthFromDepthStencil      = 1 << 0,
  MtBlitOptionStencilFromDepthStencil    = 1 << 1,
  } MtBlitOption;


typedef enum {
    MtLibraryErrorUnsupported      = 1,
    MtLibraryErrorInternal         = 2,
    MtLibraryErrorCompileFailure   = 3,
    MtLibraryErrorCompileWarning   = 4,
    MtLibraryErrorFunctionNotFound = 5,
    MtLibraryErrorFileNotFound     = 6,
} MtLibraryError;

typedef enum MtBarrierScope
{
    MtBarrierScopeBuffers        = 1 << 0,
    MtBarrierScopeTextures       = 1 << 1,
    MtBarrierScopeRenderTargets  = 1 << 2,
} MtBarrierScope;

typedef enum MtIndirectCommandType {
    MIndirectCommandTypeDraw                = (1 << 0),
    MIndirectCommandTypeDrawIndexed         = (1 << 1),
    MIndirectCommandTypeDrawPatches         = (1 << 2),
    MIndirectCommandTypeDrawIndexedPatches  = (1 << 3) ,
} MtIndirectCommandType;

typedef enum MtDataType {

    MtDataTypeNone = 0,

    MtDataTypeStruct = 1,
    MtDataTypeArray  = 2,

    MtDataTypeFloat  = 3,
    MtDataTypeFloat2 = 4,
    MtDataTypeFloat3 = 5,
    MtDataTypeFloat4 = 6,

    MtDataTypeFloat2x2 = 7,
    MtDataTypeFloat2x3 = 8,
    MtDataTypeFloat2x4 = 9,

    MtDataTypeFloat3x2 = 10,
    MtDataTypeFloat3x3 = 11,
    MtDataTypeFloat3x4 = 12,

    MtDataTypeFloat4x2 = 13,
    MtDataTypeFloat4x3 = 14,
    MtDataTypeFloat4x4 = 15,

    MtDataTypeHalf  = 16,
    MtDataTypeHalf2 = 17,
    MtDataTypeHalf3 = 18,
    MtDataTypeHalf4 = 19,

    MtDataTypeHalf2x2 = 20,
    MtDataTypeHalf2x3 = 21,
    MtDataTypeHalf2x4 = 22,

    MtDataTypeHalf3x2 = 23,
    MtDataTypeHalf3x3 = 24,
    MtDataTypeHalf3x4 = 25,

    MtDataTypeHalf4x2 = 26,
    MtDataTypeHalf4x3 = 27,
    MtDataTypeHalf4x4 = 28,

    MtDataTypeInt  = 29,
    MtDataTypeInt2 = 30,
    MtDataTypeInt3 = 31,
    MtDataTypeInt4 = 32,

    MtDataTypeUInt  = 33,
    MtDataTypeUInt2 = 34,
    MtDataTypeUInt3 = 35,
    MtDataTypeUInt4 = 36,

    MtDataTypeShort  = 37,
    MtDataTypeShort2 = 38,
    MtDataTypeShort3 = 39,
    MtDataTypeShort4 = 40,

    MtDataTypeUShort = 41,
    MtDataTypeUShort2 = 42,
    MtDataTypeUShort3 = 43,
    MtDataTypeUShort4 = 44,

    MtDataTypeChar  = 45,
    MtDataTypeChar2 = 46,
    MtDataTypeChar3 = 47,
    MtDataTypeChar4 = 48,

    MtDataTypeUChar  = 49,
    MtDataTypeUChar2 = 50,
    MtDataTypeUChar3 = 51,
    MtDataTypeUChar4 = 52,

    MtDataTypeBool  = 53,
    MtDataTypeBool2 = 54,
    MtDataTypeBool3 = 55,
    MtDataTypeBool4 = 56,

    MtDataTypeTexture  = 58,
    MtDataTypeSampler  = 59,
    MtDataTypePointer  = 60,

    MtDataTypeRenderPipeline         = 78,
    MtDataTypeIndirectCommandBuffer  = 80,
} MtDataType;

typedef enum MtArgumentAccess {
    MtArgumentAccessReadOnly   = 0,
    MtArgumentAccessReadWrite  = 1,
    MtArgumentAccessWriteOnly  = 2,
} MtArgumentAccess;

typedef enum MtArgumentBuffersTier
{
    MtArgumentBuffersTier1 = 0,
    MtArgumentBuffersTier2 = 1,
} MtArgumentBuffersTier;

typedef enum MtTextureType {
    MtTextureType1D = 0,
    MtTextureType1DArray = 1,
    MtTextureType2D = 2,
    MtTextureType2DArray = 3,
    MtTextureType2DMultisample = 4,
    MtTextureTypeCube = 5,
    MtTextureTypeCubeArray  = 6,
    MtTextureType3D = 7,
    MtTextureType2DMultisampleArray = 8,
    MtTextureTypeTextureBuffer  = 9
} MtTextureType;

typedef enum MtTextureSwizzle {
    MtTextureSwizzleZero = 0,
    MtTextureSwizzleOne = 1,
    MtTextureSwizzleRed = 2,
    MtTextureSwizzleGreen = 3,
    MtTextureSwizzleBlue = 4,
    MtTextureSwizzleAlpha = 5,
} MtTextureSwizzle;

typedef enum MtAttributeFormat
{
    MtAttributeFormatInvalid = 0,

    MtAttributeFormatUChar2 = 1,
    MtAttributeFormatUChar3 = 2,
    MtAttributeFormatUChar4 = 3,

    MtAttributeFormatChar2 = 4,
    MtAttributeFormatChar3 = 5,
    MtAttributeFormatChar4 = 6,

    MtAttributeFormatUChar2Normalized = 7,
    MtAttributeFormatUChar3Normalized = 8,
    MtAttributeFormatUChar4Normalized = 9,

    MtAttributeFormatChar2Normalized = 10,
    MtAttributeFormatChar3Normalized = 11,
    MtAttributeFormatChar4Normalized = 12,

    MtAttributeFormatUShort2 = 13,
    MtAttributeFormatUShort3 = 14,
    MtAttributeFormatUShort4 = 15,

    MtAttributeFormatShort2 = 16,
    MtAttributeFormatShort3 = 17,
    MtAttributeFormatShort4 = 18,

    MtAttributeFormatUShort2Normalized = 19,
    MtAttributeFormatUShort3Normalized = 20,
    MtAttributeFormatUShort4Normalized = 21,

    MtAttributeFormatShort2Normalized = 22,
    MtAttributeFormatShort3Normalized = 23,
    MtAttributeFormatShort4Normalized = 24,

    MtAttributeFormatHalf2 = 25,
    MtAttributeFormatHalf3 = 26,
    MtAttributeFormatHalf4 = 27,

    MtAttributeFormatFloat = 28,
    MtAttributeFormatFloat2 = 29,
    MtAttributeFormatFloat3 = 30,
    MtAttributeFormatFloat4 = 31,

    MtAttributeFormatInt = 32,
    MtAttributeFormatInt2 = 33,
    MtAttributeFormatInt3 = 34,
    MtAttributeFormatInt4 = 35,

    MtAttributeFormatUInt = 36,
    MtAttributeFormatUInt2 = 37,
    MtAttributeFormatUInt3 = 38,
    MtAttributeFormatUInt4 = 39,

    MtAttributeFormatInt1010102Normalized = 40,
    MtAttributeFormatUInt1010102Normalized = 41,

    MtAttributeFormatUChar4Normalized_BGRA = 42,

    MtAttributeFormatUChar             = 45,
    MtAttributeFormatChar              = 46,
    MtAttributeFormatUCharNormalized   = 47,
    MtAttributeFormatCharNormalized    = 48,

    MtAttributeFormatUShort            = 49,
    MtAttributeFormatShort             = 50,
    MtAttributeFormatUShortNormalized  = 51,
    MtAttributeFormatShortNormalized   = 52,

    MtAttributeFormatHalf              = 53,

} MtAttributeFormat;


typedef enum MtStepFunction
{
    MtStepFunctionConstant = 0,

    // vertex functions only
    MtStepFunctionPerVertex = 1,
    MtStepFunctionPerInstance = 2,
    MtStepFunctionPerPatch  = 3,
    MtStepFunctionPerPatchControlPoint  = 4,

    // compute functions only
    MtStepFunctionThreadPositionInGridX = 5,
    MtStepFunctionThreadPositionInGridY = 6,
    MtStepFunctionThreadPositionInGridXIndexed = 7,
    MtStepFunctionThreadPositionInGridYIndexed = 8,
} MtStepFunction;

typedef enum MtPipelineOption
{
    MtPipelineOptionNone               = 0,
    MtPipelineOptionArgumentInfo       = 1 << 0,
    MtPipelineOptionBufferTypeInfo     = 1 << 1,
} MtPipelineOption;

typedef enum MtArgumentType {
    MtArgumentTypeBuffer = 0,
    MtArgumentTypeThreadgroupMemory= 1,
    MtArgumentTypeTexture = 2,
    MtArgumentTypeSampler = 3,
} MtArgumentType;


#endif /* cmt_enums_h */
