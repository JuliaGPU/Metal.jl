using CEnum

const NsUInteger = Culong

const NsInteger = Clong

const CfTimeInterval = Cdouble

struct NsRange
    location::NsUInteger
    length::NsUInteger
end

struct NsError
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct NsDictionaryStringString
    keys::Ptr{Cstring}
    values::Ptr{Cstring}
end

@cenum MtPrimitiveType::UInt32 begin
    MtPrimitiveTypePoint = 0
    MtPrimitiveTypeLine = 1
    MtPrimitiveTypeLineStrip = 2
    MtPrimitiveTypeTriangle = 3
    MtPrimitiveTypeTriangleStrip = 4
end

@cenum MtVisibilityResultMode::UInt32 begin
    MtVisibilityResultModeDisabled = 0
    MtVisibilityResultModeBoolean = 1
    MtVisibilityResultModeCounting = 2
end

struct MtScissorRect
    x::UInt32
    y::UInt32
    width::UInt32
    height::UInt32
end

struct MtViewport
    originX::Cdouble
    originY::Cdouble
    width::Cdouble
    height::Cdouble
    znear::Cdouble
    zfar::Cdouble
end

@cenum MtCullMode::UInt32 begin
    MtCullModeNone = 0
    MtCullModeFront = 1
    MtCullModeBack = 2
end

@cenum MtWinding::UInt32 begin
    MtWindingClockwise = 0
    MtWindingCounterClockwise = 1
end

@cenum MtDepthClipMode::UInt32 begin
    MtDepthClipModeClip = 0
    MtDepthClipModeClamp = 1
end

@cenum MtTriangleFillMode::UInt32 begin
    MtTriangleFillModeFill = 0
    MtTriangleFillModeLines = 1
end

struct MtDrawPrimitivesIndirectArguments
    vertexCount::UInt32
    instanceCount::UInt32
    vertexStart::UInt32
    baseInstance::UInt32
end

struct MtDrawIndexedPrimitivesIndirectArguments
    indexCount::UInt32
    instanceCount::UInt32
    indexStart::UInt32
    baseVertex::Int32
    baseInstance::UInt32
end

struct MtDrawPatchIndirectArguments
    patchCount::UInt32
    instanceCount::UInt32
    patchStart::UInt32
    baseInstance::UInt32
end

struct MtQuadTessellationFactorsHalf
    edgeTessellationFactor::NTuple{4, UInt16}
    insideTessellationFactor::NTuple{2, UInt16}
end

struct MtTriangleTessellationFactorsHalf
    edgeTessellationFactor::NTuple{3, UInt16}
    insideTessellationFactor::UInt16
end

@cenum MtRenderStages::UInt32 begin
    MtRenderStageVertex = 1
    MtRenderStageFragment = 2
end

@cenum MtLoadAction::UInt32 begin
    MtLoadActionDontCare = 0
    MtLoadActionLoad = 1
    MtLoadActionClear = 2
end

@cenum MtIndexType::UInt32 begin
    MtIndexTypeUInt16 = 0
    MtIndexTypeUInt32 = 1
end

@cenum MtStoreAction::UInt32 begin
    MtStoreActionDontCare = 0
    MtStoreActionStore = 1
    MtStoreActionMultisampleResolve = 2
    MtStoreActionStoreAndMultisampleResolve = 3
    MtStoreActionUnknown = 4
    MtStoreActionCustomSampleDepthStore = 5
end

@cenum MtDeviceLocation::UInt32 begin
    MtDeviceLocationBuiltIn = 0
    MtDeviceLocationSlot = 1
    MtDeviceLocationExternal = 2
    MtDeviceLocationUnspecified = 100
end

@cenum MtLanguageVersion::UInt32 begin
    MtLanguageVersion1_0 = 65536
    MtLanguageVersion1_1 = 65537
    MtLanguageVersion1_2 = 65538
    MtLanguageVersion2_0 = 131072
    MtLanguageVersion2_1 = 131073
    MtLanguageVersion2_2 = 131074
    MtLanguageVersion2_3 = 131075
    MtLanguageVersion2_4 = 131076
end

@cenum MtFunctionType::UInt32 begin
    MtFunctionTypeVertex = 1
    MtFunctionTypeFragment = 2
    MtFunctionTypeKernel = 3
end

@cenum MtDispatchType::UInt32 begin
    MtDispatchTypeSerial = 0
    MtDispatchTypeConcurrent = 1
end

@cenum MtCommandBufferStatus::UInt32 begin
    MtCommandBufferStatusNotEnqueued = 0
    MtCommandBufferStatusEnqueued = 1
    MtCommandBufferStatusCommitted = 2
    MtCommandBufferStatusScheduled = 3
    MtCommandBufferStatusCompleted = 4
    MtCommandBufferStatusError = 5
end

@cenum MtResourceUsage::UInt32 begin
    MtResourceUsageRead = 1
    MtResourceUsageWrite = 2
    MtResourceUsageSample = 4
end

@cenum MtGPUFamily::UInt32 begin
    MtGPUFamilyApple1 = 1001
    MtGPUFamilyApple2 = 1002
    MtGPUFamilyApple3 = 1003
    MtGPUFamilyApple4 = 1004
    MtGPUFamilyApple5 = 1005
    MtGPUFamilyMac1 = 2001
    MtGPUFamilyMac2 = 2002
    MtGPUFamilyCommon1 = 3001
    MtGPUFamilyCommon2 = 3002
    MtGPUFamilyCommon3 = 3003
    MtGPUFamilyMacCatalyst1 = 4001
    MtGPUFamilyMacCatalyst2 = 4002
end

@cenum MtFeatureSet::UInt32 begin
    MtFeatureSet_macOS_GPUFamily1_v1 = 10000
    MtFeatureSet_OSX_GPUFamily1_v1 = 10000
    MtFeatureSet_macOS_GPUFamily1_v2 = 10001
    MtFeatureSet_OSX_GPUFamily1_v2 = 10001
    MtFeatureSet_macOS_ReadWriteTextureTier2 = 10002
    MtFeatureSet_OSX_ReadWriteTextureTier2 = 10002
    MtFeatureSet_macOS_GPUFamily1_v3 = 10003
    MtFeatureSet_macOS_GPUFamily1_v4 = 10004
    MtFeatureSet_macOS_GPUFamily2_v1 = 10005
end

@cenum MtPurgeableState::UInt32 begin
    MtPurgeableStateKeepCurrent = 1
    MtPurgeableStateNonVolatile = 2
    MtPurgeableStateVolatile = 3
    MtPurgeableStateEmpty = 4
end

@cenum MtCommandBufferError::UInt32 begin
    MtCommandBufferErrorNone = 0
    MtCommandBufferErrorInternal = 1
    MtCommandBufferErrorTimeout = 2
    MtCommandBufferErrorPageFault = 3
    MtCommandBufferErrorBlacklisted = 4
    MtCommandBufferErrorNotPermitted = 7
    MtCommandBufferErrorOutOfMemory = 8
    MtCommandBufferErrorInvalidResource = 9
    MtCommandBufferErrorMemoryless = 10
    MtCommandBufferErrorDeviceRemoved = 11
end

@cenum MtCommandBufferErrorOption::UInt32 begin
    MtCommandBufferErrorOptionNone = 0
    MtCommandBufferErrorOptionEncoderExecutionStatus = 1
end

@cenum MtCommandEncoderErrorState::UInt32 begin
    MtCommandEncodererrorStateUnknown = 0
    MtCommandEncodererrorStateCompleted = 1
    MtCommandEncodererrorStateAffected = 2
    MtCommandEncodererrorStatePending = 3
    MtCommandEncodererrorStateFaulted = 4
end

const MtCommandencoderErrorState = MtCommandEncoderErrorState

@cenum MtHeapType::UInt32 begin
    MtHeapTypeAutomatic = 0
    MtHeapTypePlacement = 1
end

@cenum MtBlitOption::UInt32 begin
    MtBlitOptionNone = 0
    MtBlitOptionDepthFromDepthStencil = 1
    MtBlitOptionStencilFromDepthStencil = 2
end

@cenum MtLibraryError::UInt32 begin
    MtLibraryErrorUnsupported = 1
    MtLibraryErrorInternal = 2
    MtLibraryErrorCompileFailure = 3
    MtLibraryErrorCompileWarning = 4
    MtLibraryErrorFunctionNotFound = 5
    MtLibraryErrorFileNotFound = 6
end

@cenum MtBarrierScope::UInt32 begin
    MtBarrierScopeBuffers = 1
    MtBarrierScopeTextures = 2
    MtBarrierScopeRenderTargets = 4
end

@cenum MtIndirectCommandType::UInt32 begin
    MIndirectCommandTypeDraw = 1
    MIndirectCommandTypeDrawIndexed = 2
    MIndirectCommandTypeDrawPatches = 4
    MIndirectCommandTypeDrawIndexedPatches = 8
end

@cenum MtDataType::UInt32 begin
    MtDataTypeNone = 0
    MtDataTypeStruct = 1
    MtDataTypeArray = 2
    MtDataTypeFloat = 3
    MtDataTypeFloat2 = 4
    MtDataTypeFloat3 = 5
    MtDataTypeFloat4 = 6
    MtDataTypeFloat2x2 = 7
    MtDataTypeFloat2x3 = 8
    MtDataTypeFloat2x4 = 9
    MtDataTypeFloat3x2 = 10
    MtDataTypeFloat3x3 = 11
    MtDataTypeFloat3x4 = 12
    MtDataTypeFloat4x2 = 13
    MtDataTypeFloat4x3 = 14
    MtDataTypeFloat4x4 = 15
    MtDataTypeHalf = 16
    MtDataTypeHalf2 = 17
    MtDataTypeHalf3 = 18
    MtDataTypeHalf4 = 19
    MtDataTypeHalf2x2 = 20
    MtDataTypeHalf2x3 = 21
    MtDataTypeHalf2x4 = 22
    MtDataTypeHalf3x2 = 23
    MtDataTypeHalf3x3 = 24
    MtDataTypeHalf3x4 = 25
    MtDataTypeHalf4x2 = 26
    MtDataTypeHalf4x3 = 27
    MtDataTypeHalf4x4 = 28
    MtDataTypeInt = 29
    MtDataTypeInt2 = 30
    MtDataTypeInt3 = 31
    MtDataTypeInt4 = 32
    MtDataTypeUInt = 33
    MtDataTypeUInt2 = 34
    MtDataTypeUInt3 = 35
    MtDataTypeUInt4 = 36
    MtDataTypeShort = 37
    MtDataTypeShort2 = 38
    MtDataTypeShort3 = 39
    MtDataTypeShort4 = 40
    MtDataTypeUShort = 41
    MtDataTypeUShort2 = 42
    MtDataTypeUShort3 = 43
    MtDataTypeUShort4 = 44
    MtDataTypeChar = 45
    MtDataTypeChar2 = 46
    MtDataTypeChar3 = 47
    MtDataTypeChar4 = 48
    MtDataTypeUChar = 49
    MtDataTypeUChar2 = 50
    MtDataTypeUChar3 = 51
    MtDataTypeUChar4 = 52
    MtDataTypeBool = 53
    MtDataTypeBool2 = 54
    MtDataTypeBool3 = 55
    MtDataTypeBool4 = 56
    MtDataTypeTexture = 58
    MtDataTypeSampler = 59
    MtDataTypePointer = 60
    MtDataTypeRenderPipeline = 78
    MtDataTypeIndirectCommandBuffer = 80
end

@cenum MtArgumentAccess::UInt32 begin
    MtArgumentAccessReadOnly = 0
    MtArgumentAccessReadWrite = 1
    MtArgumentAccessWriteOnly = 2
end

@cenum MtArgumentBuffersTier::UInt32 begin
    MtArgumentBuffersTier1 = 0
    MtArgumentBuffersTier2 = 1
end

@cenum MtTextureType::UInt32 begin
    MtTextureType1D = 0
    MtTextureType1DArray = 1
    MtTextureType2D = 2
    MtTextureType2DArray = 3
    MtTextureType2DMultisample = 4
    MtTextureTypeCube = 5
    MtTextureTypeCubeArray = 6
    MtTextureType3D = 7
    MtTextureType2DMultisampleArray = 8
    MtTextureTypeTextureBuffer = 9
end

@cenum MtTextureSwizzle::UInt32 begin
    MtTextureSwizzleZero = 0
    MtTextureSwizzleOne = 1
    MtTextureSwizzleRed = 2
    MtTextureSwizzleGreen = 3
    MtTextureSwizzleBlue = 4
    MtTextureSwizzleAlpha = 5
end

@cenum MtAttributeFormat::UInt32 begin
    MtAttributeFormatInvalid = 0
    MtAttributeFormatUChar2 = 1
    MtAttributeFormatUChar3 = 2
    MtAttributeFormatUChar4 = 3
    MtAttributeFormatChar2 = 4
    MtAttributeFormatChar3 = 5
    MtAttributeFormatChar4 = 6
    MtAttributeFormatUChar2Normalized = 7
    MtAttributeFormatUChar3Normalized = 8
    MtAttributeFormatUChar4Normalized = 9
    MtAttributeFormatChar2Normalized = 10
    MtAttributeFormatChar3Normalized = 11
    MtAttributeFormatChar4Normalized = 12
    MtAttributeFormatUShort2 = 13
    MtAttributeFormatUShort3 = 14
    MtAttributeFormatUShort4 = 15
    MtAttributeFormatShort2 = 16
    MtAttributeFormatShort3 = 17
    MtAttributeFormatShort4 = 18
    MtAttributeFormatUShort2Normalized = 19
    MtAttributeFormatUShort3Normalized = 20
    MtAttributeFormatUShort4Normalized = 21
    MtAttributeFormatShort2Normalized = 22
    MtAttributeFormatShort3Normalized = 23
    MtAttributeFormatShort4Normalized = 24
    MtAttributeFormatHalf2 = 25
    MtAttributeFormatHalf3 = 26
    MtAttributeFormatHalf4 = 27
    MtAttributeFormatFloat = 28
    MtAttributeFormatFloat2 = 29
    MtAttributeFormatFloat3 = 30
    MtAttributeFormatFloat4 = 31
    MtAttributeFormatInt = 32
    MtAttributeFormatInt2 = 33
    MtAttributeFormatInt3 = 34
    MtAttributeFormatInt4 = 35
    MtAttributeFormatUInt = 36
    MtAttributeFormatUInt2 = 37
    MtAttributeFormatUInt3 = 38
    MtAttributeFormatUInt4 = 39
    MtAttributeFormatInt1010102Normalized = 40
    MtAttributeFormatUInt1010102Normalized = 41
    MtAttributeFormatUChar4Normalized_BGRA = 42
    MtAttributeFormatUChar = 45
    MtAttributeFormatChar = 46
    MtAttributeFormatUCharNormalized = 47
    MtAttributeFormatCharNormalized = 48
    MtAttributeFormatUShort = 49
    MtAttributeFormatShort = 50
    MtAttributeFormatUShortNormalized = 51
    MtAttributeFormatShortNormalized = 52
    MtAttributeFormatHalf = 53
end

@cenum MtStepFunction::UInt32 begin
    MtStepFunctionConstant = 0
    MtStepFunctionPerVertex = 1
    MtStepFunctionPerInstance = 2
    MtStepFunctionPerPatch = 3
    MtStepFunctionPerPatchControlPoint = 4
    MtStepFunctionThreadPositionInGridX = 5
    MtStepFunctionThreadPositionInGridY = 6
    MtStepFunctionThreadPositionInGridXIndexed = 7
    MtStepFunctionThreadPositionInGridYIndexed = 8
end

@cenum MtPipelineOption::UInt32 begin
    MtPipelineOptionNone = 0
    MtPipelineOptionArgumentInfo = 1
    MtPipelineOptionBufferTypeInfo = 2
end

@cenum MtArgumentType::UInt32 begin
    MtArgumentTypeBuffer = 0
    MtArgumentTypeThreadgroupMemory = 1
    MtArgumentTypeTexture = 2
    MtArgumentTypeSampler = 3
end

struct MtSize
    width::NsUInteger
    height::NsUInteger
    depth::NsUInteger
end

struct MtOrigin
    x::NsUInteger
    y::NsUInteger
    z::NsUInteger
end

struct MtSizeAndAlign
    size::NsUInteger
    align::NsUInteger
end

struct MtDevice
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtRenderDesc
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtRenderPipeline
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCommandQueue
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCommandEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtBlitCommandEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtLibrary
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtRenderPassDesc
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtTexture
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCommandBuffer
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCommandBufferDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCommandBufferEncoderInfo
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtDrawable
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtVertexDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtTextureDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtIndirectCommandBufferDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtIndirectCommandBuffer
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtIndirectComputeCommand
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtIndirectRenderCommand
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtDepthStencil
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtBuffer
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCompileOptions
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtFunction
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtFunctionConstant
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtFunctionConstantValues
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtEvent
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtSharedEvent
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtSharedEventHandle
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtFence
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

# typedef void ( * MtCommandBufferHandlerFun ) ( MtCommandBuffer * buf )
const MtCommandBufferHandlerFun = Ptr{Cvoid}

struct MtSharedEventListener
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtResource
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtHeap
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtHeapDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtAttribute
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtVertexAttribute
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtComputePipelineState
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtSamplerState
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtRenderCommandEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtComputeCommandEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtResourceStateCommandEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtCounterSampleBuffer
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtArgumentEncoder
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtAutoreleasedArgument
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtArgument
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtArgumentDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtComputePipelineDescriptor
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtPointerType
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtArrayType
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtStructType
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtComputePipelineReflection
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtRenderPipelineReflection
    #= /Users/maxhawkins/workspace_julia/src/Metal.jl/res/wrap.jl:42 =#
end

struct MtDispatchThreadgroupsIndirectArguments
    threadgroupsPerGrid::NTuple{3, UInt32}
end

struct MtStageInRegionIndirectArguments
    stageInOrigin::NTuple{3, UInt32}
    stageInSize::NTuple{3, UInt32}
end

struct MtRegion
    origin::MtOrigin
    size::MtSize
end

struct MtIndirectCommandBufferExecutionRange
    location::UInt32
    length::UInt32
end

struct MtTextureSwizzleChannels
    red::MtTextureSwizzle
    green::MtTextureSwizzle
    blue::MtTextureSwizzle
    alpha::MtTextureSwizzle
end

function mtErrorCode(err)
    ccall((:mtErrorCode, libcmt), NsInteger, (Ptr{NsError},), err)
end

function mtErrorDomain(err)
    ccall((:mtErrorDomain, libcmt), Cstring, (Ptr{NsError},), err)
end

function mtErrorUserInfo(err)
    ccall((:mtErrorUserInfo, libcmt), Cstring, (Ptr{NsError},), err)
end

function mtErrorLocalizedDescription(err)
    ccall((:mtErrorLocalizedDescription, libcmt), Cstring, (Ptr{NsError},), err)
end

function mtErrorLocalizedRecoveryOptions(err, count, options)
    ccall((:mtErrorLocalizedRecoveryOptions, libcmt), Ptr{Cstring}, (Ptr{NsError}, Ptr{Csize_t}, Ptr{Cstring}), err, count, options)
end

function mtErrorLocalizedRecoverySuggestion(err)
    ccall((:mtErrorLocalizedRecoverySuggestion, libcmt), Cstring, (Ptr{NsError},), err)
end

function mtErrorLocalizedFailureReason(err)
    ccall((:mtErrorLocalizedFailureReason, libcmt), Cstring, (Ptr{NsError},), err)
end

@cenum MtPixelFormat::UInt32 begin
    MtPixelFormatInvalid = 0
    MtPixelFormatA8Unorm = 1
    MtPixelFormatR8Unorm = 10
    MtPixelFormatR8Unorm_sRGB = 11
    MtPixelFormatR8Snorm = 12
    MtPixelFormatR8Uint = 13
    MtPixelFormatR8Sint = 14
    MtPixelFormatR16Unorm = 20
    MtPixelFormatR16Snorm = 22
    MtPixelFormatR16Uint = 23
    MtPixelFormatR16Sint = 24
    MtPixelFormatR16Float = 25
    MtPixelFormatRG8Unorm = 30
    MtPixelFormatRG8Unorm_sRGB = 31
    MtPixelFormatRG8Snorm = 32
    MtPixelFormatRG8Uint = 33
    MtPixelFormatRG8Sint = 34
    MtPixelFormatB5G6R5Unorm = 40
    MtPixelFormatA1BGR5Unorm = 41
    MtPixelFormatABGR4Unorm = 42
    MtPixelFormatBGR5A1Unorm = 43
    MtPixelFormatR32Uint = 53
    MtPixelFormatR32Sint = 54
    MtPixelFormatR32Float = 55
    MtPixelFormatRG16Unorm = 60
    MtPixelFormatRG16Snorm = 62
    MtPixelFormatRG16Uint = 63
    MtPixelFormatRG16Sint = 64
    MtPixelFormatRG16Float = 65
    MtPixelFormatRGBA8Unorm = 70
    MtPixelFormatRGBA8Unorm_sRGB = 71
    MtPixelFormatRGBA8Snorm = 72
    MtPixelFormatRGBA8Uint = 73
    MtPixelFormatRGBA8Sint = 74
    MtPixelFormatBGRX8Unorm = 75
    MtPixelFormatBGRA8Unorm = 80
    MtPixelFormatBGRA8Unorm_sRGB = 81
    MtPixelFormatRGB10A2Unorm = 90
    MtPixelFormatRGB10A2Uint = 91
    MtPixelFormatRG11B10Float = 92
    MtPixelFormatRGB9E5Float = 93
    MtPixelFormatBGR10A2Unorm = 94
    MtPixelFormatBGR10_XR = 554
    MtPixelFormatBGR10_XR_sRGB = 555
    MtPixelFormatRG32Uint = 103
    MtPixelFormatRG32Sint = 104
    MtPixelFormatRG32Float = 105
    MtPixelFormatRGBA16Unorm = 110
    MtPixelFormatRGBA16Snorm = 112
    MtPixelFormatRGBA16Uint = 113
    MtPixelFormatRGBA16Sint = 114
    MtPixelFormatRGBA16Float = 115
    MtPixelFormatBGRA10_XR = 552
    MtPixelFormatBGRA10_XR_sRGB = 553
    MtPixelFormatRGBA32Uint = 123
    MtPixelFormatRGBA32Sint = 124
    MtPixelFormatRGBA32Float = 125
    MtPixelFormatBC1_RGBA = 130
    MtPixelFormatBC1_RGBA_sRGB = 131
    MtPixelFormatBC2_RGBA = 132
    MtPixelFormatBC2_RGBA_sRGB = 133
    MtPixelFormatBC3_RGBA = 134
    MtPixelFormatBC3_RGBA_sRGB = 135
    MtPixelFormatBC4_RUnorm = 140
    MtPixelFormatBC4_RSnorm = 141
    MtPixelFormatBC5_RGUnorm = 142
    MtPixelFormatBC5_RGSnorm = 143
    MtPixelFormatBC6H_RGBFloat = 150
    MtPixelFormatBC6H_RGBUfloat = 151
    MtPixelFormatBC7_RGBAUnorm = 152
    MtPixelFormatBC7_RGBAUnorm_sRGB = 153
    MtPixelFormatPVRTC_RGB_2BPP = 160
    MtPixelFormatPVRTC_RGB_2BPP_sRGB = 161
    MtPixelFormatPVRTC_RGB_4BPP = 162
    MtPixelFormatPVRTC_RGB_4BPP_sRGB = 163
    MtPixelFormatPVRTC_RGBA_2BPP = 164
    MtPixelFormatPVRTC_RGBA_2BPP_sRGB = 165
    MtPixelFormatPVRTC_RGBA_4BPP = 166
    MtPixelFormatPVRTC_RGBA_4BPP_sRGB = 167
    MtPixelFormatEAC_R11Unorm = 170
    MtPixelFormatEAC_R11Snorm = 172
    MtPixelFormatEAC_RG11Unorm = 174
    MtPixelFormatEAC_RG11Snorm = 176
    MtPixelFormatEAC_RGBA8 = 178
    MtPixelFormatEAC_RGBA8_sRGB = 179
    MtPixelFormatETC2_RGB8 = 180
    MtPixelFormatETC2_RGB8_sRGB = 181
    MtPixelFormatETC2_RGB8A1 = 182
    MtPixelFormatETC2_RGB8A1_sRGB = 183
    MtPixelFormatASTC_4x4_sRGB = 186
    MtPixelFormatASTC_5x4_sRGB = 187
    MtPixelFormatASTC_5x5_sRGB = 188
    MtPixelFormatASTC_6x5_sRGB = 189
    MtPixelFormatASTC_6x6_sRGB = 190
    MtPixelFormatASTC_8x5_sRGB = 192
    MtPixelFormatASTC_8x6_sRGB = 193
    MtPixelFormatASTC_8x8_sRGB = 194
    MtPixelFormatASTC_10x5_sRGB = 195
    MtPixelFormatASTC_10x6_sRGB = 196
    MtPixelFormatASTC_10x8_sRGB = 197
    MtPixelFormatASTC_10x10_sRGB = 198
    MtPixelFormatASTC_12x10_sRGB = 199
    MtPixelFormatASTC_12x12_sRGB = 200
    MtPixelFormatASTC_4x4_LDR = 204
    MtPixelFormatASTC_5x4_LDR = 205
    MtPixelFormatASTC_5x5_LDR = 206
    MtPixelFormatASTC_6x5_LDR = 207
    MtPixelFormatASTC_6x6_LDR = 208
    MtPixelFormatASTC_8x5_LDR = 210
    MtPixelFormatASTC_8x6_LDR = 211
    MtPixelFormatASTC_8x8_LDR = 212
    MtPixelFormatASTC_10x5_LDR = 213
    MtPixelFormatASTC_10x6_LDR = 214
    MtPixelFormatASTC_10x8_LDR = 215
    MtPixelFormatASTC_10x10_LDR = 216
    MtPixelFormatASTC_12x10_LDR = 217
    MtPixelFormatASTC_12x12_LDR = 218
    MtPixelFormatGBGR422 = 240
    MtPixelFormatBGRG422 = 241
    MtPixelFormatDepth16Unorm = 250
    MtPixelFormatDepth32Float = 252
    MtPixelFormatStencil8 = 253
    MtPixelFormatDepth24Unorm_Stencil8 = 255
    MtPixelFormatDepth32Float_Stencil8 = 260
    MtPixelFormatX32_Stencil8 = 261
    MtPixelFormatX24_Stencil8 = 262
end

function mtDeviceNewEvent(dev)
    ccall((:mtDeviceNewEvent, libcmt), Ptr{MtEvent}, (Ptr{MtDevice},), dev)
end

function mtDeviceNewSharedEvent(dev)
    ccall((:mtDeviceNewSharedEvent, libcmt), Ptr{MtSharedEvent}, (Ptr{MtDevice},), dev)
end

function mtDeviceNewSharedEventWithHandle(dev, handle)
    ccall((:mtDeviceNewSharedEventWithHandle, libcmt), Ptr{MtSharedEvent}, (Ptr{MtDevice}, Ptr{MtSharedEventHandle}), dev, handle)
end

function mtDeviceNewFence(dev)
    ccall((:mtDeviceNewFence, libcmt), Ptr{MtFence}, (Ptr{MtDevice},), dev)
end

function mtEventDevice(event)
    ccall((:mtEventDevice, libcmt), Ptr{MtDevice}, (Ptr{MtEvent},), event)
end

function mtEventLabel(event)
    ccall((:mtEventLabel, libcmt), Cstring, (Ptr{MtEvent},), event)
end

function mtEventLabelSet(event, label)
    ccall((:mtEventLabelSet, libcmt), Cvoid, (Ptr{MtEvent}, Cstring), event, label)
end

function mtSharedEventSignaledValue(event)
    ccall((:mtSharedEventSignaledValue, libcmt), UInt64, (Ptr{MtSharedEvent},), event)
end

function mtSharedEventNewHandle(event)
    ccall((:mtSharedEventNewHandle, libcmt), Ptr{MtSharedEventHandle}, (Ptr{MtSharedEvent},), event)
end

@cenum MtCPUCacheMode::UInt32 begin
    MtCPUCacheModeDefaultCache = 0
    MtCPUCacheModeWriteCombined = 1
end

@cenum MtHazardTrackingMode::UInt32 begin
    MtHazardTrackingModeDefault = 0
    MtHazardTrackingModeUntracked = 1
    MtHazardTrackingModeTracked = 2
end

@cenum MtStorageMode::UInt32 begin
    MtStorageModeShared = 0
    MtStorageModeManaged = 1
    MtStorageModePrivate = 2
    MtStorageModeMemoryless = 3
end

@cenum MtResourceOptions::UInt32 begin
    MtResourceCPUCacheModeDefaultCache = 0
    MtResourceCPUCacheModeWriteCombined = 1
    MtResourceStorageModeShared = 0
    MtResourceStorageModeManaged = 16
    MtResourceStorageModePrivate = 32
    MtResourceStorageModeMemoryless = 48
    MtResourceHazardTrackingModeDefault = 0
    MtResourceHazardTrackingModeUntracked = 256
    MtResourceHazardTrackingModeTracked = 512
end

function mtResourceDevice(res)
    ccall((:mtResourceDevice, libcmt), Ptr{MtDevice}, (Ptr{MtResource},), res)
end

function mtResourceLabel(res)
    ccall((:mtResourceLabel, libcmt), Cstring, (Ptr{MtResource},), res)
end

function mtResourceLabelSet(res, label)
    ccall((:mtResourceLabelSet, libcmt), Cvoid, (Ptr{MtResource}, Cstring), res, label)
end

function mtResourceCPUCacheMode(res)
    ccall((:mtResourceCPUCacheMode, libcmt), MtCPUCacheMode, (Ptr{MtResource},), res)
end

function mtResourceStorageMode(res)
    ccall((:mtResourceStorageMode, libcmt), MtStorageMode, (Ptr{MtResource},), res)
end

function mtResourceHazardTrackingMode(res)
    ccall((:mtResourceHazardTrackingMode, libcmt), MtHazardTrackingMode, (Ptr{MtResource},), res)
end

function mtResourceOptions(res)
    ccall((:mtResourceOptions, libcmt), MtResourceOptions, (Ptr{MtResource},), res)
end

function mtCreateSystemDefaultDevice()
    ccall((:mtCreateSystemDefaultDevice, libcmt), Ptr{MtDevice}, ())
end

function mtCopyAllDevices(count, devices)
    ccall((:mtCopyAllDevices, libcmt), Cvoid, (Ptr{Csize_t}, Ptr{Ptr{MtDevice}}), count, devices)
end

function mtDeviceName(arg1)
    ccall((:mtDeviceName, libcmt), Cstring, (Ptr{MtDevice},), arg1)
end

function mtDeviceHeadless(arg1)
    ccall((:mtDeviceHeadless, libcmt), Bool, (Ptr{MtDevice},), arg1)
end

function mtDeviceLowPower(arg1)
    ccall((:mtDeviceLowPower, libcmt), Bool, (Ptr{MtDevice},), arg1)
end

function mtDeviceRemovable(arg1)
    ccall((:mtDeviceRemovable, libcmt), Bool, (Ptr{MtDevice},), arg1)
end

function mtDeviceRegistryID(arg1)
    ccall((:mtDeviceRegistryID, libcmt), UInt64, (Ptr{MtDevice},), arg1)
end

function mtDeviceLocation(arg1)
    ccall((:mtDeviceLocation, libcmt), MtDeviceLocation, (Ptr{MtDevice},), arg1)
end

function mtDeviceLocationNumber(arg1)
    ccall((:mtDeviceLocationNumber, libcmt), UInt64, (Ptr{MtDevice},), arg1)
end

function mtDeviceMaxTransferRate(arg1)
    ccall((:mtDeviceMaxTransferRate, libcmt), UInt64, (Ptr{MtDevice},), arg1)
end

function mtDeviceHasUnifiedMemory(arg1)
    ccall((:mtDeviceHasUnifiedMemory, libcmt), Bool, (Ptr{MtDevice},), arg1)
end

function mtDevicePeerGroupID(arg1)
    ccall((:mtDevicePeerGroupID, libcmt), UInt64, (Ptr{MtDevice},), arg1)
end

function mtDevicePeerCount(arg1)
    ccall((:mtDevicePeerCount, libcmt), UInt32, (Ptr{MtDevice},), arg1)
end

function mtDevicePeerIndex(arg1)
    ccall((:mtDevicePeerIndex, libcmt), UInt32, (Ptr{MtDevice},), arg1)
end

function mtDeviceSupportsFamily(device, family)
    ccall((:mtDeviceSupportsFamily, libcmt), Bool, (Ptr{MtDevice}, MtGPUFamily), device, family)
end

function mtDeviceSupportsFeatureSet(device, set)
    ccall((:mtDeviceSupportsFeatureSet, libcmt), Bool, (Ptr{MtDevice}, MtFeatureSet), device, set)
end

function mtDeviceRecommendedMaxWorkingSetSize(device)
    ccall((:mtDeviceRecommendedMaxWorkingSetSize, libcmt), UInt64, (Ptr{MtDevice},), device)
end

function mtDeviceCurrentAllocatedSize(device)
    ccall((:mtDeviceCurrentAllocatedSize, libcmt), NsUInteger, (Ptr{MtDevice},), device)
end

function mtDeviceMaxThreadgroupMemoryLength(device)
    ccall((:mtDeviceMaxThreadgroupMemoryLength, libcmt), NsUInteger, (Ptr{MtDevice},), device)
end

function mtMaxThreadsPerThreadgroup(device)
    ccall((:mtMaxThreadsPerThreadgroup, libcmt), MtSize, (Ptr{MtDevice},), device)
end

function mtDeviceArgumentBuffersSupport(device)
    ccall((:mtDeviceArgumentBuffersSupport, libcmt), MtArgumentBuffersTier, (Ptr{MtDevice},), device)
end

function mtDeviceMaxBufferLength(device)
    ccall((:mtDeviceMaxBufferLength, libcmt), NsUInteger, (Ptr{MtDevice},), device)
end

function mtDeviceNewBufferWithLength(device, length, opts)
    ccall((:mtDeviceNewBufferWithLength, libcmt), Ptr{MtBuffer}, (Ptr{MtDevice}, NsUInteger, MtResourceOptions), device, length, opts)
end

function mtDeviceNewBufferWithBytes(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytes, libcmt), Ptr{MtBuffer}, (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions), device, ptr, length, opts)
end

function mtDeviceNewBufferWithBytesNoCopy(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytesNoCopy, libcmt), Ptr{MtBuffer}, (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions), device, ptr, length, opts)
end

function mtNewComputePipelineStateWithFunction(device, fun, error)
    ccall((:mtNewComputePipelineStateWithFunction, libcmt), Ptr{MtComputePipelineState}, (Ptr{MtDevice}, Ptr{MtFunction}, Ptr{Ptr{NsError}}), device, fun, error)
end

function mtNewComputePipelineStateWithFunctionReflection(device, fun, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithFunctionReflection, libcmt), Ptr{MtComputePipelineState}, (Ptr{MtDevice}, Ptr{MtFunction}, MtPipelineOption, Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}), device, fun, opt, reflection, error)
end

function mtNewComputePipelineStateWithDescriptor(device, desc, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithDescriptor, libcmt), Ptr{MtComputePipelineState}, (Ptr{MtDevice}, Ptr{MtComputePipelineDescriptor}, MtPipelineOption, Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}), device, desc, opt, reflection, error)
end

function mtComputePipelineDevice(pip)
    ccall((:mtComputePipelineDevice, libcmt), Ptr{MtDevice}, (Ptr{MtComputePipelineState},), pip)
end

function mtComputePipelineLabel(pip)
    ccall((:mtComputePipelineLabel, libcmt), Cstring, (Ptr{MtComputePipelineState},), pip)
end

function mtComputePipelineMaxTotalThreadsPerThreadgroup(pip)
    ccall((:mtComputePipelineMaxTotalThreadsPerThreadgroup, libcmt), NsUInteger, (Ptr{MtComputePipelineState},), pip)
end

function mtComputePipelineThreadExecutionWidth(pip)
    ccall((:mtComputePipelineThreadExecutionWidth, libcmt), NsUInteger, (Ptr{MtComputePipelineState},), pip)
end

function mtComputePipelineStaticThreadgroupMemoryLength(pip)
    ccall((:mtComputePipelineStaticThreadgroupMemoryLength, libcmt), NsUInteger, (Ptr{MtComputePipelineState},), pip)
end

function mtAttributeName(attr)
    ccall((:mtAttributeName, libcmt), Cstring, (Ptr{MtAttribute},), attr)
end

function mtAttributeIndex(attr)
    ccall((:mtAttributeIndex, libcmt), NsUInteger, (Ptr{MtAttribute},), attr)
end

function mtAttributeDataType(attr)
    ccall((:mtAttributeDataType, libcmt), MtDataType, (Ptr{MtAttribute},), attr)
end

function mtAttributeActive(attr)
    ccall((:mtAttributeActive, libcmt), Bool, (Ptr{MtAttribute},), attr)
end

function mtAttributeIsPatchControlPointData(attr)
    ccall((:mtAttributeIsPatchControlPointData, libcmt), Bool, (Ptr{MtAttribute},), attr)
end

function mtAttributeIsPatchData(attr)
    ccall((:mtAttributeIsPatchData, libcmt), Bool, (Ptr{MtAttribute},), attr)
end

function mtVertexAttributeName(attr)
    ccall((:mtVertexAttributeName, libcmt), Cstring, (Ptr{MtVertexAttribute},), attr)
end

function mtVertexAttributeIndex(attr)
    ccall((:mtVertexAttributeIndex, libcmt), NsUInteger, (Ptr{MtVertexAttribute},), attr)
end

function mtVertexAttributeDataType(attr)
    ccall((:mtVertexAttributeDataType, libcmt), MtDataType, (Ptr{MtVertexAttribute},), attr)
end

function mtVertexAttributeActive(attr)
    ccall((:mtVertexAttributeActive, libcmt), Bool, (Ptr{MtVertexAttribute},), attr)
end

function mtVertexAttributeIsPatchControlPointData(attr)
    ccall((:mtVertexAttributeIsPatchControlPointData, libcmt), Bool, (Ptr{MtVertexAttribute},), attr)
end

function mtVertexAttributeIsPatchData(attr)
    ccall((:mtVertexAttributeIsPatchData, libcmt), Bool, (Ptr{MtVertexAttribute},), attr)
end

function mtNewCompileOpts()
    ccall((:mtNewCompileOpts, libcmt), Ptr{MtCompileOptions}, ())
end

function mtCompileOptsFastMath(opts)
    ccall((:mtCompileOptsFastMath, libcmt), Bool, (Ptr{MtCompileOptions},), opts)
end

function mtCompileOptsFastMathSet(opts, val)
    ccall((:mtCompileOptsFastMathSet, libcmt), Cvoid, (Ptr{MtCompileOptions}, Bool), opts, val)
end

function mtCompileOptsLanguageVersion(opts)
    ccall((:mtCompileOptsLanguageVersion, libcmt), MtLanguageVersion, (Ptr{MtCompileOptions},), opts)
end

function mtCompileOptsLanguageVersionSet(opts, val)
    ccall((:mtCompileOptsLanguageVersionSet, libcmt), Cvoid, (Ptr{MtCompileOptions}, MtLanguageVersion), opts, val)
end

function mtFunctionConstantValuesSetWithIndex(funval, value, typ, idx)
    ccall((:mtFunctionConstantValuesSetWithIndex, libcmt), Cvoid, (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsUInteger), funval, value, typ, idx)
end

function mtFunctionConstantValuesSetWithName(funval, value, typ, name)
    ccall((:mtFunctionConstantValuesSetWithName, libcmt), Cvoid, (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, Cstring), funval, value, typ, name)
end

function mtFunctionConstantValuesSetWithRange(funval, value, typ, range)
    ccall((:mtFunctionConstantValuesSetWithRange, libcmt), Cvoid, (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsRange), funval, value, typ, range)
end

function mtFunctionConstantValuesReset(funval)
    ccall((:mtFunctionConstantValuesReset, libcmt), Cvoid, (Ptr{MtFunctionConstantValues},), funval)
end

function mtNewFunctionWithName(lib, name)
    ccall((:mtNewFunctionWithName, libcmt), Ptr{MtFunction}, (Ptr{MtLibrary}, Cstring), lib, name)
end

function mtNewFunctionWithNameConstantValues(lib, name, constantValues, error)
    ccall((:mtNewFunctionWithNameConstantValues, libcmt), Ptr{MtFunction}, (Ptr{MtLibrary}, Cstring, Ptr{MtFunctionConstantValues}, Ptr{Ptr{NsError}}), lib, name, constantValues, error)
end

function mtFunctionDevice(fun)
    ccall((:mtFunctionDevice, libcmt), Ptr{MtDevice}, (Ptr{MtFunction},), fun)
end

function mtFunctionLabel(fun)
    ccall((:mtFunctionLabel, libcmt), Cstring, (Ptr{MtFunction},), fun)
end

function mtFunctionLabelSet(fun, label)
    ccall((:mtFunctionLabelSet, libcmt), Cvoid, (Ptr{MtFunction}, Cstring), fun, label)
end

function mtFunctionType(fun)
    ccall((:mtFunctionType, libcmt), MtFunctionType, (Ptr{MtFunction},), fun)
end

function mtFunctionName(fun)
    ccall((:mtFunctionName, libcmt), Cstring, (Ptr{MtFunction},), fun)
end

function mtFunctionStageInputAttributes(fun)
    ccall((:mtFunctionStageInputAttributes, libcmt), Ptr{Ptr{MtAttribute}}, (Ptr{MtFunction},), fun)
end

function mtNewDefaultLibrary(device)
    ccall((:mtNewDefaultLibrary, libcmt), Ptr{MtLibrary}, (Ptr{MtDevice},), device)
end

function mtNewLibraryWithFile(device, filepath, error)
    ccall((:mtNewLibraryWithFile, libcmt), Ptr{MtLibrary}, (Ptr{MtDevice}, Cstring, Ptr{Ptr{NsError}}), device, filepath, error)
end

function mtNewLibraryWithURL(device, url, error)
    ccall((:mtNewLibraryWithURL, libcmt), Ptr{MtLibrary}, (Ptr{MtDevice}, Cstring, Ptr{Ptr{NsError}}), device, url, error)
end

function mtNewLibraryWithSource(device, source, Opts, error)
    ccall((:mtNewLibraryWithSource, libcmt), Ptr{MtLibrary}, (Ptr{MtDevice}, Cstring, Ptr{MtCompileOptions}, Ptr{Ptr{NsError}}), device, source, Opts, error)
end

function mtNewLibraryWithData(device, buffer, size, error)
    ccall((:mtNewLibraryWithData, libcmt), Ptr{MtLibrary}, (Ptr{MtDevice}, Ptr{Cvoid}, Csize_t, Ptr{Ptr{NsError}}), device, buffer, size, error)
end

function mtLibraryDevice(lib)
    ccall((:mtLibraryDevice, libcmt), Ptr{MtDevice}, (Ptr{MtLibrary},), lib)
end

function mtLibraryLabel(lib)
    ccall((:mtLibraryLabel, libcmt), Cstring, (Ptr{MtLibrary},), lib)
end

function mtLibraryLabelSet(lib, label)
    ccall((:mtLibraryLabelSet, libcmt), Cvoid, (Ptr{MtLibrary}, Cstring), lib, label)
end

function mtLibraryFunctionNames(lib, count, names)
    ccall((:mtLibraryFunctionNames, libcmt), Cvoid, (Ptr{MtLibrary}, Ptr{Csize_t}, Ptr{Cstring}), lib, count, names)
end

function mtBufferContents(buf)
    ccall((:mtBufferContents, libcmt), Ptr{Cvoid}, (Ptr{MtBuffer},), buf)
end

function mtBufferLength(buf)
    ccall((:mtBufferLength, libcmt), NsUInteger, (Ptr{MtBuffer},), buf)
end

function mtBufferDidModifyRange(buf, ran)
    ccall((:mtBufferDidModifyRange, libcmt), Cvoid, (Ptr{MtBuffer}, NsRange), buf, ran)
end

function mtBufferAddDebugMarkerRange(buf, string, range)
    ccall((:mtBufferAddDebugMarkerRange, libcmt), Cvoid, (Ptr{MtBuffer}, Cstring, NsRange), buf, string, range)
end

function mtBufferRemoveAllDebugMarkers(buf)
    ccall((:mtBufferRemoveAllDebugMarkers, libcmt), Cvoid, (Ptr{MtBuffer},), buf)
end

function mtBufferNewRemoteBufferViewForDevice(buf, device)
    ccall((:mtBufferNewRemoteBufferViewForDevice, libcmt), Ptr{MtBuffer}, (Ptr{MtBuffer}, Ptr{MtDevice}), buf, device)
end

function mtBufferRemoteStorageBuffer(buf)
    ccall((:mtBufferRemoteStorageBuffer, libcmt), Ptr{MtBuffer}, (Ptr{MtBuffer},), buf)
end

function mtBufferGPUAddress(buf)
    ccall((:mtBufferGPUAddress, libcmt), UInt64, (Ptr{MtBuffer},), buf)
end

function mtNewHeapDescriptor()
    ccall((:mtNewHeapDescriptor, libcmt), Ptr{MtHeapDescriptor}, ())
end

function mtHeapDescriptorType(heap)
    ccall((:mtHeapDescriptorType, libcmt), MtHeapType, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorTypeSet(heap, type)
    ccall((:mtHeapDescriptorTypeSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, MtHeapType), heap, type)
end

function mtHeapDescriptorStorageMode(heap)
    ccall((:mtHeapDescriptorStorageMode, libcmt), MtStorageMode, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorStorageModeSet(heap, mode)
    ccall((:mtHeapDescriptorStorageModeSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, MtStorageMode), heap, mode)
end

function mtHeapDescriptorCPUCacheMode(heap)
    ccall((:mtHeapDescriptorCPUCacheMode, libcmt), MtCPUCacheMode, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorCpuCacheModeSet(heap, mode)
    ccall((:mtHeapDescriptorCpuCacheModeSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, MtCPUCacheMode), heap, mode)
end

function mtHeapDescriptorHazardTrackingMode(heap)
    ccall((:mtHeapDescriptorHazardTrackingMode, libcmt), MtHazardTrackingMode, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorHazardTrackingModeSet(heap, mode)
    ccall((:mtHeapDescriptorHazardTrackingModeSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, MtHazardTrackingMode), heap, mode)
end

function mtHeapDescriptorResourceOptions(heap)
    ccall((:mtHeapDescriptorResourceOptions, libcmt), MtResourceOptions, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorResourceOptionsSet(heap, mode)
    ccall((:mtHeapDescriptorResourceOptionsSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, MtResourceOptions), heap, mode)
end

function mtHeapDescriptorSize(heap)
    ccall((:mtHeapDescriptorSize, libcmt), NsUInteger, (Ptr{MtHeapDescriptor},), heap)
end

function mtHeapDescriptorSizeSet(heap, size)
    ccall((:mtHeapDescriptorSizeSet, libcmt), Cvoid, (Ptr{MtHeapDescriptor}, NsUInteger), heap, size)
end

function mtDeviceNewHeapWithDescriptor(dev, descriptor)
    ccall((:mtDeviceNewHeapWithDescriptor, libcmt), Ptr{MtHeap}, (Ptr{MtDevice}, Ptr{MtHeapDescriptor}), dev, descriptor)
end

function mtHeapDevice(heap)
    ccall((:mtHeapDevice, libcmt), Ptr{MtDevice}, (Ptr{MtHeap},), heap)
end

function mtHeapLabel(heap)
    ccall((:mtHeapLabel, libcmt), Cstring, (Ptr{MtHeap},), heap)
end

function mtHeapLabelSet(heap, label)
    ccall((:mtHeapLabelSet, libcmt), Cvoid, (Ptr{MtHeap}, Cstring), heap, label)
end

function mtHeapType(heap)
    ccall((:mtHeapType, libcmt), MtHeapType, (Ptr{MtHeap},), heap)
end

function mtHeapStorageMode(heap)
    ccall((:mtHeapStorageMode, libcmt), MtStorageMode, (Ptr{MtHeap},), heap)
end

function mtHeapCPUCacheMode(heap)
    ccall((:mtHeapCPUCacheMode, libcmt), MtCPUCacheMode, (Ptr{MtHeap},), heap)
end

function mtHeapHazardTrackingMode(heap)
    ccall((:mtHeapHazardTrackingMode, libcmt), MtHazardTrackingMode, (Ptr{MtHeap},), heap)
end

function mtHeapResourceOptions(heap)
    ccall((:mtHeapResourceOptions, libcmt), MtResourceOptions, (Ptr{MtHeap},), heap)
end

function mtHeapSize(heap)
    ccall((:mtHeapSize, libcmt), NsUInteger, (Ptr{MtHeap},), heap)
end

function mtHeapUsedSize(heap)
    ccall((:mtHeapUsedSize, libcmt), NsUInteger, (Ptr{MtHeap},), heap)
end

function mtHeapCurrentAllocatedSize(heap)
    ccall((:mtHeapCurrentAllocatedSize, libcmt), NsUInteger, (Ptr{MtHeap},), heap)
end

function mtHeapMaxAvailableSizeWithAlignment(heap, alignment)
    ccall((:mtHeapMaxAvailableSizeWithAlignment, libcmt), NsUInteger, (Ptr{MtHeap}, NsUInteger), heap, alignment)
end

function mtHeapSetPurgeableState(heap, state)
    ccall((:mtHeapSetPurgeableState, libcmt), MtPurgeableState, (Ptr{MtHeap}, MtPurgeableState), heap, state)
end

function mtHeapNewBufferWithLength(heap, len, opt)
    ccall((:mtHeapNewBufferWithLength, libcmt), Ptr{MtBuffer}, (Ptr{MtHeap}, NsUInteger, MtResourceOptions), heap, len, opt)
end

function mtHeapNewBufferWithLengthOffset(heap, len, opt, offset)
    ccall((:mtHeapNewBufferWithLengthOffset, libcmt), Ptr{MtBuffer}, (Ptr{MtHeap}, NsUInteger, MtResourceOptions, NsUInteger), heap, len, opt, offset)
end

function mtHeapNewTextureWithDescriptor(heap, desc)
    ccall((:mtHeapNewTextureWithDescriptor, libcmt), Ptr{MtTexture}, (Ptr{MtHeap}, Ptr{MtTextureDescriptor}), heap, desc)
end

function mtHeapNewTextureWithDescriptorOffset(heap, desc, offset)
    ccall((:mtHeapNewTextureWithDescriptorOffset, libcmt), Ptr{MtTexture}, (Ptr{MtHeap}, Ptr{MtTextureDescriptor}, NsUInteger), heap, desc, offset)
end

@cenum MtVertexFormat::UInt32 begin
    MtVertexFormatInvalid = 0
    MtVertexFormatUChar2 = 1
    MtVertexFormatUChar3 = 2
    MtVertexFormatUChar4 = 3
    MtVertexFormatChar2 = 4
    MtVertexFormatChar3 = 5
    MtVertexFormatChar4 = 6
    MtVertexFormatUChar2Normalized = 7
    MtVertexFormatUChar3Normalized = 8
    MtVertexFormatUChar4Normalized = 9
    MtVertexFormatChar2Normalized = 10
    MtVertexFormatChar3Normalized = 11
    MtVertexFormatChar4Normalized = 12
    MtVertexFormatUShort2 = 13
    MtVertexFormatUShort3 = 14
    MtVertexFormatUShort4 = 15
    MtVertexFormatShort2 = 16
    MtVertexFormatShort3 = 17
    MtVertexFormatShort4 = 18
    MtVertexFormatUShort2Normalized = 19
    MtVertexFormatUShort3Normalized = 20
    MtVertexFormatUShort4Normalized = 21
    MtVertexFormatShort2Normalized = 22
    MtVertexFormatShort3Normalized = 23
    MtVertexFormatShort4Normalized = 24
    MtVertexFormatHalf2 = 25
    MtVertexFormatHalf3 = 26
    MtVertexFormatHalf4 = 27
    MtVertexFormatFloat = 28
    MtVertexFormatFloat2 = 29
    MtVertexFormatFloat3 = 30
    MtVertexFormatFloat4 = 31
    MtVertexFormatInt = 32
    MtVertexFormatInt2 = 33
    MtVertexFormatInt3 = 34
    MtVertexFormatInt4 = 35
    MtVertexFormatUInt = 36
    MtVertexFormatUInt2 = 37
    MtVertexFormatUInt3 = 38
    MtVertexFormatUInt4 = 39
    MtVertexFormatInt1010102Normalized = 40
    MtVertexFormatUInt1010102Normalized = 41
    MtVertexFormatUChar4Normalized_BGRA = 42
    MtVertexFormatUChar = 45
    MtVertexFormatChar = 46
    MtVertexFormatUCharNormalized = 47
    MtVertexFormatCharNormalized = 48
    MtVertexFormatUShort = 49
    MtVertexFormatShort = 50
    MtVertexFormatUShortNormalized = 51
    MtVertexFormatShortNormalized = 52
    MtVertexFormatHalf = 53
end

@cenum MtVertexStepFunction::UInt32 begin
    MtVertexStepFunctionConstant = 0
    MtVertexStepFunctionPerVertex = 1
    MtVertexStepFunctionPerInstance = 2
    MtVertexStepFunctionPerPatch = 3
    MtVertexStepFunctionPerPatchControlPoint = 4
end

function mtVertexDescNew()
    ccall((:mtVertexDescNew, libcmt), Ptr{MtVertexDescriptor}, ())
end

function mtVertexAttrib(vertex, attribIndex, format, offset, bufferIndex)
    ccall((:mtVertexAttrib, libcmt), Cvoid, (Ptr{MtVertexDescriptor}, UInt32, MtVertexFormat, UInt32, UInt32), vertex, attribIndex, format, offset, bufferIndex)
end

function mtVertexLayout(vertex, layoutIndex, stride, stepRate, stepFunction)
    ccall((:mtVertexLayout, libcmt), Cvoid, (Ptr{MtVertexDescriptor}, UInt32, UInt32, UInt32, MtVertexStepFunction), vertex, layoutIndex, stride, stepRate, stepFunction)
end

function mtSetVertexDesc(pipeline, vert)
    ccall((:mtSetVertexDesc, libcmt), Cvoid, (Ptr{MtRenderPipeline}, Ptr{MtVertexDescriptor}), pipeline, vert)
end

@cenum MtCompareFunction::UInt32 begin
    MtCompareFunctionNever = 0
    MtCompareFunctionLess = 1
    MtCompareFunctionEqual = 2
    MtCompareFunctionLessEqual = 3
    MtCompareFunctionGreater = 4
    MtCompareFunctionNotEqual = 5
    MtCompareFunctionGreaterEqual = 6
    MtCompareFunctionAlways = 7
end

@cenum MtStencilOperation::UInt32 begin
    MtStencilOperationKeep = 0
    MtStencilOperationZero = 1
    MtStencilOperationReplace = 2
    MtStencilOperationIncrementClamp = 3
    MtStencilOperationDecrementClamp = 4
    MtStencilOperationInvert = 5
    MtStencilOperationIncrementWrap = 6
    MtStencilOperationDecrementWrap = 7
end

function mtDepthStencil(depthCompareFunc, depthWriteEnabled)
    ccall((:mtDepthStencil, libcmt), Ptr{MtDepthStencil}, (MtCompareFunction, Bool), depthCompareFunc, depthWriteEnabled)
end

function mtNewPass()
    ccall((:mtNewPass, libcmt), Ptr{MtRenderPassDesc}, ())
end

function mtPassTexture(pass, colorAttch, tex)
    ccall((:mtPassTexture, libcmt), Cvoid, (Ptr{MtRenderPassDesc}, Cint, Ptr{MtTexture}), pass, colorAttch, tex)
end

function mtPassLoadAction(pass, colorAttch, action)
    ccall((:mtPassLoadAction, libcmt), Cvoid, (Ptr{MtRenderPassDesc}, Cint, MtLoadAction), pass, colorAttch, action)
end

@cenum MtFuncType::UInt32 begin
    MT_FUNC_VERT = 1
    MT_FUNC_FRAG = 2
end

function mtNewRenderPipeline(pixelFormat)
    ccall((:mtNewRenderPipeline, libcmt), Ptr{MtRenderDesc}, (MtPixelFormat,), pixelFormat)
end

function mtSetFunc(pipDesc, func, functype)
    ccall((:mtSetFunc, libcmt), Cvoid, (Ptr{MtRenderDesc}, Ptr{MtFunction}, MtFuncType), pipDesc, func, functype)
end

function mtNewRenderState(device, pipDesc, error)
    ccall((:mtNewRenderState, libcmt), Ptr{MtRenderPipeline}, (Ptr{MtDevice}, Ptr{MtRenderDesc}, Ptr{Ptr{NsError}}), device, pipDesc, error)
end

function mtColorPixelFormat(renderdesc, index, pixelFormat)
    ccall((:mtColorPixelFormat, libcmt), Cvoid, (Ptr{MtRenderDesc}, UInt32, MtPixelFormat), renderdesc, index, pixelFormat)
end

function mtDepthPixelFormat(renderdesc, pixelFormat)
    ccall((:mtDepthPixelFormat, libcmt), Cvoid, (Ptr{MtRenderDesc}, MtPixelFormat), renderdesc, pixelFormat)
end

function mtStencilPixelFormat(renderdesc, pixelFormat)
    ccall((:mtStencilPixelFormat, libcmt), Cvoid, (Ptr{MtRenderDesc}, MtPixelFormat), renderdesc, pixelFormat)
end

function mtSampleCount(renderdesc, sampleCount)
    ccall((:mtSampleCount, libcmt), Cvoid, (Ptr{MtRenderDesc}, UInt32), renderdesc, sampleCount)
end

function mtArgumentName(arg)
    ccall((:mtArgumentName, libcmt), Cstring, (Ptr{MtArgument},), arg)
end

function mtArgumentActive(arg)
    ccall((:mtArgumentActive, libcmt), Bool, (Ptr{MtArgument},), arg)
end

function mtArgumentIndex(arg)
    ccall((:mtArgumentIndex, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtArgumentType(arg)
    ccall((:mtArgumentType, libcmt), MtArgumentType, (Ptr{MtArgument},), arg)
end

function mtArgumentAccess(arg)
    ccall((:mtArgumentAccess, libcmt), MtArgumentAccess, (Ptr{MtArgument},), arg)
end

function mtArgumentBufferAlignment(arg)
    ccall((:mtArgumentBufferAlignment, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtArgumentBufferDataSize(arg)
    ccall((:mtArgumentBufferDataSize, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtArgumentBufferDataType(arg)
    ccall((:mtArgumentBufferDataType, libcmt), MtDataType, (Ptr{MtArgument},), arg)
end

function mtArgumentBufferStructType(arg)
    ccall((:mtArgumentBufferStructType, libcmt), Ptr{MtStructType}, (Ptr{MtArgument},), arg)
end

function mtArgumentBufferPointerType(arg)
    ccall((:mtArgumentBufferPointerType, libcmt), Ptr{MtPointerType}, (Ptr{MtArgument},), arg)
end

function mtArgumentArrayLength(arg)
    ccall((:mtArgumentArrayLength, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtArgumentThreadgroupMemoryAlignment(arg)
    ccall((:mtArgumentThreadgroupMemoryAlignment, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtArgumentThreadgroupMemoryDataSize(arg)
    ccall((:mtArgumentThreadgroupMemoryDataSize, libcmt), NsUInteger, (Ptr{MtArgument},), arg)
end

function mtNewComputePipelineReflection()
    ccall((:mtNewComputePipelineReflection, libcmt), Ptr{MtComputePipelineReflection}, ())
end

function mtComputePipelinereflectionArguments(refl)
    ccall((:mtComputePipelinereflectionArguments, libcmt), Ptr{MtArgument}, (Ptr{MtComputePipelineReflection},), refl)
end

function mtPointerTypeElementType(ptr)
    ccall((:mtPointerTypeElementType, libcmt), MtDataType, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeAccess(ptr)
    ccall((:mtPointerTypeAccess, libcmt), MtArgumentAccess, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeAlignment(ptr)
    ccall((:mtPointerTypeAlignment, libcmt), NsUInteger, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeDataSize(ptr)
    ccall((:mtPointerTypeDataSize, libcmt), NsUInteger, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeElementIsArgumentBuffer(ptr)
    ccall((:mtPointerTypeElementIsArgumentBuffer, libcmt), Bool, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeElementStructType(ptr)
    ccall((:mtPointerTypeElementStructType, libcmt), Ptr{MtStructType}, (Ptr{MtPointerType},), ptr)
end

function mtPointerTypeElementArrayType(ptr)
    ccall((:mtPointerTypeElementArrayType, libcmt), Ptr{MtArrayType}, (Ptr{MtPointerType},), ptr)
end

# typedef void ( * MtCommandBufferOnCompleteFn ) ( void * __restrict sender , MtCommandBuffer * __restrict cmdb )
const MtCommandBufferOnCompleteFn = Ptr{Cvoid}

# typedef void ( * MtCommandBufferOnCompleteFnNoSender ) ( MtCommandBuffer * __restrict cmdb )
const MtCommandBufferOnCompleteFnNoSender = Ptr{Cvoid}

function mtNewCommandBufferDescriptor()
    ccall((:mtNewCommandBufferDescriptor, libcmt), Ptr{MtCommandBufferDescriptor}, ())
end

function mtCommandBufferDescriptorRetainedReferences(desc)
    ccall((:mtCommandBufferDescriptorRetainedReferences, libcmt), Bool, (Ptr{MtCommandBufferDescriptor},), desc)
end

function mtCommandBufferDescriptorRetainedReferencesSet(desc, retain)
    ccall((:mtCommandBufferDescriptorRetainedReferencesSet, libcmt), Cvoid, (Ptr{MtCommandBufferDescriptor}, Bool), desc, retain)
end

function mtCommandBufferDescriptorErrorOptions(desc)
    ccall((:mtCommandBufferDescriptorErrorOptions, libcmt), NsUInteger, (Ptr{MtCommandBufferDescriptor},), desc)
end

function mtCommandBufferDescriptorErrorOptionsSet(desc, errorOption)
    ccall((:mtCommandBufferDescriptorErrorOptionsSet, libcmt), Cvoid, (Ptr{MtCommandBufferDescriptor}, NsUInteger), desc, errorOption)
end

function mtNewCommandBuffer(cmdq)
    ccall((:mtNewCommandBuffer, libcmt), Ptr{MtCommandBuffer}, (Ptr{MtCommandQueue},), cmdq)
end

function mtNewCommandBufferWithDescriptor(cmdq, desc)
    ccall((:mtNewCommandBufferWithDescriptor, libcmt), Ptr{MtCommandBuffer}, (Ptr{MtCommandQueue}, Ptr{MtCommandBufferDescriptor}), cmdq, desc)
end

function mtNewCommandBufferWithUnretainedReferences(cmdq)
    ccall((:mtNewCommandBufferWithUnretainedReferences, libcmt), Ptr{MtCommandBuffer}, (Ptr{MtCommandQueue},), cmdq)
end

function mtCommandBufferOnComplete(cmdb, sender, oncomplete)
    ccall((:mtCommandBufferOnComplete, libcmt), Cvoid, (Ptr{MtCommandQueue}, Ptr{Cvoid}, MtCommandBufferOnCompleteFn), cmdb, sender, oncomplete)
end

function mtCommandBufferOnCompleteNoSender(cmdb, oncomplete)
    ccall((:mtCommandBufferOnCompleteNoSender, libcmt), Cvoid, (Ptr{MtCommandQueue}, MtCommandBufferOnCompleteFnNoSender), cmdb, oncomplete)
end

function mtCommandBufferPresentDrawable(cmdb, drawable)
    ccall((:mtCommandBufferPresentDrawable, libcmt), Cvoid, (Ptr{MtCommandBuffer}, Ptr{MtDrawable}), cmdb, drawable)
end

function mtCommandBufferEnqueue(cmdb)
    ccall((:mtCommandBufferEnqueue, libcmt), Cvoid, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferCommit(cmdb)
    ccall((:mtCommandBufferCommit, libcmt), Cvoid, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferAddScheduledHandler(cmdb, handler)
    ccall((:mtCommandBufferAddScheduledHandler, libcmt), Cvoid, (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun), cmdb, handler)
end

function mtCommandBufferAddCompletedHandler(cmdb, handler)
    ccall((:mtCommandBufferAddCompletedHandler, libcmt), Cvoid, (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun), cmdb, handler)
end

function mtCommandBufferWaitUntilScheduled(cmdb)
    ccall((:mtCommandBufferWaitUntilScheduled, libcmt), Cvoid, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferWaitUntilCompleted(cmdb)
    ccall((:mtCommandBufferWaitUntilCompleted, libcmt), Cvoid, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferStatus(cmdb)
    ccall((:mtCommandBufferStatus, libcmt), MtCommandBufferStatus, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferErrorOptions(cmdb)
    ccall((:mtCommandBufferErrorOptions, libcmt), MtCommandBufferErrorOption, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferError(cmdb)
    ccall((:mtCommandBufferError, libcmt), Ptr{NsError}, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferKernelStartTime(cmdb)
    ccall((:mtCommandBufferKernelStartTime, libcmt), CfTimeInterval, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferKernelEndTime(cmdb)
    ccall((:mtCommandBufferKernelEndTime, libcmt), CfTimeInterval, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferGPUStartTime(cmdb)
    ccall((:mtCommandBufferGPUStartTime, libcmt), CfTimeInterval, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferGPUEndTime(cmdb)
    ccall((:mtCommandBufferGPUEndTime, libcmt), CfTimeInterval, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferEncodeSignalEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeSignalEvent, libcmt), Cvoid, (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64), cmdb, event, val)
end

function mtCommandBufferEncodeWaitForEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeWaitForEvent, libcmt), Cvoid, (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64), cmdb, event, val)
end

function mtCommandBufferRetainedReferences(cmdb)
    ccall((:mtCommandBufferRetainedReferences, libcmt), Bool, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferDevice(cmdb)
    ccall((:mtCommandBufferDevice, libcmt), Ptr{MtDevice}, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferCommandQueue(cmdb)
    ccall((:mtCommandBufferCommandQueue, libcmt), Ptr{MtCommandQueue}, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferLabel(cmdb)
    ccall((:mtCommandBufferLabel, libcmt), Cstring, (Ptr{MtCommandBuffer},), cmdb)
end

function mtCommandBufferLabelSet(cmdb, label)
    ccall((:mtCommandBufferLabelSet, libcmt), Cvoid, (Ptr{MtCommandBuffer}, Cstring), cmdb, label)
end

function mtCommandBufferPushDebugGroup(cmdb, str)
    ccall((:mtCommandBufferPushDebugGroup, libcmt), Cvoid, (Ptr{MtCommandBuffer}, Cstring), cmdb, str)
end

function mtCommandBufferPopDebugGroup(cmdb)
    ccall((:mtCommandBufferPopDebugGroup, libcmt), Cvoid, (Ptr{MtCommandBuffer},), cmdb)
end

function mtNewIndirectCommandBuffer(device, desc, maxCount, options)
    ccall((:mtNewIndirectCommandBuffer, libcmt), Ptr{MtIndirectCommandBuffer}, (Ptr{MtDevice}, Ptr{MtIndirectCommandBufferDescriptor}, NsUInteger, MtResourceOptions), device, desc, maxCount, options)
end

function mtIndirectCommandBufferSize(icb)
    ccall((:mtIndirectCommandBufferSize, libcmt), NsUInteger, (Ptr{MtIndirectCommandBuffer},), icb)
end

function mtIndirectCommandBufferComputeCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferComputeCommandAtIndex, libcmt), Ptr{MtIndirectComputeCommand}, (Ptr{MtIndirectCommandBuffer}, NsUInteger), icb, index)
end

function mtIndirectCommandBufferRenderCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferRenderCommandAtIndex, libcmt), Ptr{MtIndirectRenderCommand}, (Ptr{MtIndirectCommandBuffer}, NsUInteger), icb, index)
end

function mtIndirectCommandBufferResetWithRange(icb, range)
    ccall((:mtIndirectCommandBufferResetWithRange, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, NsRange), icb, range)
end

function mtCommandEncoderEndEncoding(ce)
    ccall((:mtCommandEncoderEndEncoding, libcmt), Cvoid, (Ptr{MtCommandEncoder},), ce)
end

function mtCommandEncoderDevice(ce)
    ccall((:mtCommandEncoderDevice, libcmt), Ptr{MtDevice}, (Ptr{MtCommandEncoder},), ce)
end

function mtCommandEncoderLabel(ce)
    ccall((:mtCommandEncoderLabel, libcmt), Cstring, (Ptr{MtCommandEncoder},), ce)
end

function mtCommandEncoderLabelSet(ce, label)
    ccall((:mtCommandEncoderLabelSet, libcmt), Cvoid, (Ptr{MtCommandEncoder}, Cstring), ce, label)
end

function mtCommandEncoderInsertDebugSignpost(ce, string)
    ccall((:mtCommandEncoderInsertDebugSignpost, libcmt), Cvoid, (Ptr{MtCommandEncoder}, Cstring), ce, string)
end

function mtCommandEncoderPushDebugGroup(ce, string)
    ccall((:mtCommandEncoderPushDebugGroup, libcmt), Cvoid, (Ptr{MtCommandEncoder}, Cstring), ce, string)
end

function mtCommandEncoderPopDebugGroup(ce)
    ccall((:mtCommandEncoderPopDebugGroup, libcmt), Cvoid, (Ptr{MtCommandEncoder},), ce)
end

function mtNewBlitCommandEncoder(cmdb)
    ccall((:mtNewBlitCommandEncoder, libcmt), Ptr{MtBlitCommandEncoder}, (Ptr{MtCommandBuffer},), cmdb)
end

function mtBlitCommandEncoderCopyFromBufferToBuffer(bce, src, src_offset, dst, dst_offset, size)
    ccall((:mtBlitCommandEncoderCopyFromBufferToBuffer, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsUInteger, Ptr{MtBuffer}, NsUInteger, NsUInteger), bce, src, src_offset, dst, dst_offset, size)
end

function mtBlitCommandEncoderFillBuffer(bce, src, range, val)
    ccall((:mtBlitCommandEncoderFillBuffer, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsRange, UInt8), bce, src, range, val)
end

function mtBlitCommandEncoderGenerateMipmaps(bce, texture)
    ccall((:mtBlitCommandEncoderGenerateMipmaps, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}), bce, texture)
end

function mtBlitCommandEncoderCopyIndirectCommandBuffer(bce, src, range, dst, dst_index)
    ccall((:mtBlitCommandEncoderCopyIndirectCommandBuffer, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange, Ptr{MtIndirectCommandBuffer}, NsUInteger), bce, src, range, dst, dst_index)
end

function mtBlitCommandEncoderOptimizeIndirectCommandBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderOptimizeIndirectCommandBuffer, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange), bce, buffer, range)
end

function mtBlitCommandEncoderResetCommandsInBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderResetCommandsInBuffer, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange), bce, buffer, range)
end

function mtBlitCommandEncoderSynchronizeResource(bce, resource)
    ccall((:mtBlitCommandEncoderSynchronizeResource, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtResource}), bce, resource)
end

function mtBlitCommandEncoderSynchronizeTexture(bce, texture, slice, level)
    ccall((:mtBlitCommandEncoderSynchronizeTexture, libcmt), Cvoid, (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}, NsUInteger, NsUInteger), bce, texture, slice, level)
end

function mtBlitCommandEncoderUpdateFence(icb, fence)
    ccall((:mtBlitCommandEncoderUpdateFence, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}), icb, fence)
end

function mtBlitCommandEncoderWaitForFence(icb, fence)
    ccall((:mtBlitCommandEncoderWaitForFence, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}), icb, fence)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccess, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}), icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger), icb, tex, slice, level)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccess, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}), icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger), icb, tex, slice, level)
end

function mtBlitCommandEncoderSampleCountersInBuffer(icb, sbuf, sampleindex, barrier)
    ccall((:mtBlitCommandEncoderSampleCountersInBuffer, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsUInteger, Bool), icb, sbuf, sampleindex, barrier)
end

function mtBlitCommandEncoderResolveCounters(icb, sbuf, range, dst, dst_offset)
    ccall((:mtBlitCommandEncoderResolveCounters, libcmt), Cvoid, (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsRange, Ptr{MtBuffer}, NsUInteger), icb, sbuf, range, dst, dst_offset)
end

function mtNewComputeCommandEncoder(cmdb)
    ccall((:mtNewComputeCommandEncoder, libcmt), Ptr{MtComputeCommandEncoder}, (Ptr{MtCommandBuffer},), cmdb)
end

function mtNewComputeCommandEncoderWithDispatchType(cmdb, dtype)
    ccall((:mtNewComputeCommandEncoderWithDispatchType, libcmt), Ptr{MtComputeCommandEncoder}, (Ptr{MtCommandBuffer}, MtDispatchType), cmdb, dtype)
end

function mtComputeCommandEncoderEndEncoding(cce)
    ccall((:mtComputeCommandEncoderEndEncoding, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder},), cce)
end

function mtComputeCommandEncoderSetComputePipelineState(cce, state)
    ccall((:mtComputeCommandEncoderSetComputePipelineState, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtComputePipelineState}), cce, state)
end

function mtComputeCommandEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtComputeCommandEncoderSetBufferOffsetAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger), cce, buf, offset, indx)
end

function mtComputeCommandEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtComputeCommandEncoderSetBuffersOffsetsWithRange, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange), cce, bufs, offsets, range)
end

function mtComputeCommandEncoderBufferSetOffsetAtIndex(cce, offset, indx)
    ccall((:mtComputeCommandEncoderBufferSetOffsetAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger), cce, offset, indx)
end

function mtComputeCommandEncoderSetBytesLengthAtIndex(cce, ptr, length, indx)
    ccall((:mtComputeCommandEncoderSetBytesLengthAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Cvoid}, NsUInteger, NsUInteger), cce, ptr, length, indx)
end

function mtComputeCommandEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, NsUInteger), cce, sampler, indx)
end

function mtComputeCommandEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtComputeCommandEncoderSetSamplerStatesWithRange, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange), cce, samplers, range)
end

function mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex(cce, sampler, lodMinClamp, lodMaxClamp, indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, Cfloat, Cfloat, NsUInteger), cce, sampler, lodMinClamp, lodMaxClamp, indx)
end

function mtComputeCommandEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtComputeCommandEncoderSetTextureAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtTexture}, NsUInteger), cce, tex, indx)
end

function mtComputeCommandEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtComputeCommandEncoderSetTexturesWithRange, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtTexture}}, NsRange), cce, textures, range)
end

function mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex(cce, length, indx)
    ccall((:mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger), cce, length, indx)
end

function mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(cce, threadgroupsPerGrid, threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, MtSize, MtSize), cce, threadgroupsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup(cce, threadsPerGrid, threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, MtSize, MtSize), cce, threadsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup(cce, indirectBuffer, indirectBufferOffset, threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, MtSize), cce, indirectBuffer, indirectBufferOffset, threadsPerThreadgroup)
end

function mtComputeCommandEncoderUseResourceUsage(cce, res, usage)
    ccall((:mtComputeCommandEncoderUseResourceUsage, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtResource}, MtResourceUsage), cce, res, usage)
end

function mtComputeCommandEncoderUseResourcesCountUsage(cce, res, count, usage)
    ccall((:mtComputeCommandEncoderUseResourcesCountUsage, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger, MtResourceUsage), cce, res, count, usage)
end

function mtComputeCommandEncoderUseHeap(cce, heap)
    ccall((:mtComputeCommandEncoderUseHeap, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtHeap}), cce, heap)
end

function mtComputeCommandEncoderUseHeaps(cce, heaps, count)
    ccall((:mtComputeCommandEncoderUseHeaps, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtHeap}}, NsUInteger), cce, heaps, count)
end

function mtComputeCommandEncoderSetStageInRegion(cce, region)
    ccall((:mtComputeCommandEncoderSetStageInRegion, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, MtRegion), cce, region)
end

function mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer(cce, buf, offset)
    ccall((:mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger), cce, buf, offset)
end

function mtComputeCommandEncoderDispatchType(cce)
    ccall((:mtComputeCommandEncoderDispatchType, libcmt), MtDispatchType, (Ptr{MtComputeCommandEncoder},), cce)
end

function mtComputeCommandEncoderMemoryBarrierWithScope(cce, scope)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithScope, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, MtBarrierScope), cce, scope)
end

function mtComputeCommandEncoderMemoryBarrierWithResource(cce, resources, count)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithResource, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger), cce, resources, count)
end

function mtComputeCommandEncoderExecuteCommandInBuffer(cce, resources, count)
    ccall((:mtComputeCommandEncoderExecuteCommandInBuffer, libcmt), Cvoid, (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger), cce, resources, count)
end

function mtNewRenderCommandEncoder(cmdb, pass)
    ccall((:mtNewRenderCommandEncoder, libcmt), Ptr{MtRenderCommandEncoder}, (Ptr{MtCommandBuffer}, Ptr{MtRenderPassDesc}), cmdb, pass)
end

function mtFrontFace(rce, winding)
    ccall((:mtFrontFace, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, MtWinding), rce, winding)
end

function mtCullMode(rce, mode)
    ccall((:mtCullMode, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, MtCullMode), rce, mode)
end

function mtViewport(rce, viewport)
    ccall((:mtViewport, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{MtViewport}), rce, viewport)
end

function mtSetRenderState(rce, pipline)
    ccall((:mtSetRenderState, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{MtRenderPipeline}), rce, pipline)
end

function mtSetDepthStencil(rce, ds)
    ccall((:mtSetDepthStencil, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{MtDepthStencil}), rce, ds)
end

function mtVertexBytes(rce, bytes, legth, atIndex)
    ccall((:mtVertexBytes, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{Cvoid}, Csize_t, UInt32), rce, bytes, legth, atIndex)
end

function mtVertexBuffer(rce, buf, off, index)
    ccall((:mtVertexBuffer, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32), rce, buf, off, index)
end

function mtFragmentBuffer(rce, buf, off, index)
    ccall((:mtFragmentBuffer, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32), rce, buf, off, index)
end

function mtDrawPrims(rce, type, start, count)
    ccall((:mtDrawPrims, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, Csize_t, Csize_t), rce, type, start, count)
end

function mtDrawIndexedPrims(rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
    ccall((:mtDrawIndexedPrims, libcmt), Cvoid, (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, UInt32, MtIndexType, Ptr{MtBuffer}, UInt32), rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
end

function mtNewCommandQueue(device)
    ccall((:mtNewCommandQueue, libcmt), Ptr{MtCommandQueue}, (Ptr{MtDevice},), device)
end

function mtNewCommandQueueWithMaxCommandBufferCount(device, count)
    ccall((:mtNewCommandQueueWithMaxCommandBufferCount, libcmt), Ptr{MtCommandQueue}, (Ptr{MtDevice}, NsUInteger), device, count)
end

function mtCommandQueueDevice(cmdq)
    ccall((:mtCommandQueueDevice, libcmt), Ptr{MtDevice}, (Ptr{MtCommandQueue},), cmdq)
end

function mtCommandQueueLabel(cmdq)
    ccall((:mtCommandQueueLabel, libcmt), Cstring, (Ptr{MtCommandQueue},), cmdq)
end

function mtCommandQueueLabelSet(cmdq, label)
    ccall((:mtCommandQueueLabelSet, libcmt), Cvoid, (Ptr{MtCommandQueue}, Cstring), cmdq, label)
end

function mtNewArgumentDescriptor()
    ccall((:mtNewArgumentDescriptor, libcmt), Ptr{MtArgumentDescriptor}, ())
end

function mtArgumentDescriptorDataType(desc)
    ccall((:mtArgumentDescriptorDataType, libcmt), MtDataType, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorDataTypeSet(desc, dataType)
    ccall((:mtArgumentDescriptorDataTypeSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, MtDataType), desc, dataType)
end

function mtArgumentDescriptorIndex(desc)
    ccall((:mtArgumentDescriptorIndex, libcmt), NsUInteger, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorIndexSet(desc, index)
    ccall((:mtArgumentDescriptorIndexSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, NsUInteger), desc, index)
end

function mtArgumentDescriptorAccess(desc)
    ccall((:mtArgumentDescriptorAccess, libcmt), MtArgumentAccess, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorAccessSet(desc, access)
    ccall((:mtArgumentDescriptorAccessSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, MtArgumentAccess), desc, access)
end

function mtArgumentDescriptorArrayLength(desc)
    ccall((:mtArgumentDescriptorArrayLength, libcmt), NsUInteger, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorArrayLengthSet(desc, length)
    ccall((:mtArgumentDescriptorArrayLengthSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, NsUInteger), desc, length)
end

function mtArgumentDescriptorConstantBlockAlignment(desc)
    ccall((:mtArgumentDescriptorConstantBlockAlignment, libcmt), NsUInteger, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorConstantBlockAlignmentSet(desc, alignment)
    ccall((:mtArgumentDescriptorConstantBlockAlignmentSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, NsUInteger), desc, alignment)
end

function mtArgumentDescriptorTextureType(desc)
    ccall((:mtArgumentDescriptorTextureType, libcmt), MtTextureType, (Ptr{MtArgumentDescriptor},), desc)
end

function mtArgumentDescriptorTextureTypeSet(desc, textype)
    ccall((:mtArgumentDescriptorTextureTypeSet, libcmt), Cvoid, (Ptr{MtArgumentDescriptor}, MtTextureType), desc, textype)
end

function mtNewArgumentEncoderWithBufferIndexFromFunction(_function, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromFunction, libcmt), Ptr{MtArgumentEncoder}, (Ptr{MtFunction}, NsUInteger), _function, bufferIndex)
end

function mtNewArgumentEncoderWithBufferIndexReflectionFromFunction(_function, bufferIndex, reflection)
    ccall((:mtNewArgumentEncoderWithBufferIndexReflectionFromFunction, libcmt), Ptr{MtArgumentEncoder}, (Ptr{MtFunction}, NsUInteger, Ptr{MtAutoreleasedArgument}), _function, bufferIndex, reflection)
end

function mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer(ae, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer, libcmt), Ptr{MtArgumentEncoder}, (Ptr{MtArgumentEncoder}, NsUInteger), ae, bufferIndex)
end

function mtNewArgumentEncoder(device, arguments, count)
    ccall((:mtNewArgumentEncoder, libcmt), Ptr{MtArgumentEncoder}, (Ptr{MtDevice}, Ptr{Ptr{MtArgumentDescriptor}}, UInt64), device, arguments, count)
end

function mtArgumentEncoderLength(encoder)
    ccall((:mtArgumentEncoderLength, libcmt), NsUInteger, (Ptr{MtArgumentEncoder},), encoder)
end

function mtArgumentEncoderSetArgumentBufferWithOffset(cce, buf, offset)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffset, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger), cce, buf, offset)
end

function mtArgumentEncoderSetArgumentBufferWithOffsetForElement(cce, buf, startOffset, arrayElement)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffsetForElement, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger), cce, buf, startOffset, arrayElement)
end

function mtArgumentEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtArgumentEncoderSetBufferOffsetAtIndex, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger), cce, buf, offset, indx)
end

function mtArgumentEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtArgumentEncoderSetBuffersOffsetsWithRange, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange), cce, bufs, offsets, range)
end

function mtArgumentEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtArgumentEncoderSetTextureAtIndex, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtTexture}, NsUInteger), cce, tex, indx)
end

function mtArgumentEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtArgumentEncoderSetTexturesWithRange, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtTexture}}, NsRange), cce, textures, range)
end

function mtArgumentEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtArgumentEncoderSetSamplerStateAtIndex, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtSamplerState}, NsUInteger), cce, sampler, indx)
end

function mtArgumentEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtArgumentEncoderSetSamplerStatesWithRange, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange), cce, samplers, range)
end

function mtArgumentEncoderConstantDataAtIndex(cce, index)
    ccall((:mtArgumentEncoderConstantDataAtIndex, libcmt), Ptr{Cvoid}, (Ptr{MtArgumentEncoder}, NsUInteger), cce, index)
end

function mtArgumentEncoderSetIndirectCommandBuffer(cce, cbuf, index)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffer, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{MtIndirectCommandBuffer}, NsUInteger), cce, cbuf, index)
end

function mtArgumentEncoderSetIndirectCommandBuffers(cce, cbufs, range)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffers, libcmt), Cvoid, (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtIndirectCommandBuffer}}, NsRange), cce, cbufs, range)
end

function mtArgumentEncoderAlignment(cce)
    ccall((:mtArgumentEncoderAlignment, libcmt), NsUInteger, (Ptr{MtArgumentEncoder},), cce)
end

function mtRetain(obj)
    ccall((:mtRetain, libcmt), Ptr{Cvoid}, (Ptr{Cvoid},), obj)
end

function mtRelease(obj)
    ccall((:mtRelease, libcmt), Cvoid, (Ptr{Cvoid},), obj)
end

# Skipping MacroDefinition: MT_EXPORT __attribute__ ( ( visibility ( "default" ) ) )

# Skipping MacroDefinition: MT_HIDE __attribute__ ( ( visibility ( "hidden" ) ) )

# Skipping MacroDefinition: MT_INLINE inline __attribute ( ( always_inline ) )

