# Julia wrapper for header: cmt.h
# Automatically generated using Clang.jl

function mtErrorCode(err)
    ccall((:mtErrorCode, libcmt), NsInteger,
          (Ptr{NsError},),
          err)
end

function mtErrorDomain(err)
    ccall((:mtErrorDomain, libcmt), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorUserInfo(err)
    ccall((:mtErrorUserInfo, libcmt), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedDescription(err)
    ccall((:mtErrorLocalizedDescription, libcmt), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedRecoveryOptions(err, count, options)
    ccall((:mtErrorLocalizedRecoveryOptions, libcmt), Cvoid,
          (Ptr{NsError}, Ptr{Csize_t}, Ptr{Cstring}),
          err, count, options)
end

function mtErrorLocalizedRecoverySuggestion(err)
    ccall((:mtErrorLocalizedRecoverySuggestion, libcmt), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedFailureReason(err)
    ccall((:mtErrorLocalizedFailureReason, libcmt), Cstring,
          (Ptr{NsError},),
          err)
end

function mtDeviceNewEvent(dev)
    ccall((:mtDeviceNewEvent, libcmt), Ptr{MtEvent},
          (Ptr{MtDevice},),
          dev)
end

function mtDeviceNewSharedEvent(dev)
    ccall((:mtDeviceNewSharedEvent, libcmt), Ptr{MtSharedEvent},
          (Ptr{MtDevice},),
          dev)
end

function mtDeviceNewSharedEventWithHandle(dev, handle)
    ccall((:mtDeviceNewSharedEventWithHandle, libcmt), Ptr{MtSharedEvent},
          (Ptr{MtDevice}, Ptr{MtSharedEventHandle}),
          dev, handle)
end

function mtDeviceNewFence(dev)
    ccall((:mtDeviceNewFence, libcmt), Ptr{MtFence},
          (Ptr{MtDevice},),
          dev)
end

function mtEventDevice(event)
    ccall((:mtEventDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtEvent},),
          event)
end

function mtEventLabel(event)
    ccall((:mtEventLabel, libcmt), Cstring,
          (Ptr{MtEvent},),
          event)
end

function mtSharedEventSignaledValue(event)
    ccall((:mtSharedEventSignaledValue, libcmt), UInt64,
          (Ptr{MtSharedEvent},),
          event)
end

function mtSharedEventNewHandle(event)
    ccall((:mtSharedEventNewHandle, libcmt), Ptr{MtSharedEventHandle},
          (Ptr{MtSharedEvent},),
          event)
end

function mtSharedEventNotifyListener(event, listener, val, block)
    ccall((:mtSharedEventNotifyListener, libcmt), Cvoid,
          (Ptr{MtSharedEvent}, Ptr{MtSharedEventListener}, UInt64,
           MtSharedEventNotificationBlock),
          event, listener, val, block)
end

function mtResourceDevice(res)
    ccall((:mtResourceDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtResource},),
          res)
end

function mtResourceLabel(res)
    ccall((:mtResourceLabel, libcmt), Cstring,
          (Ptr{MtResource},),
          res)
end

function mtResourceCPUCacheMode(res)
    ccall((:mtResourceCPUCacheMode, libcmt), MtCPUCacheMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceStorageMode(res)
    ccall((:mtResourceStorageMode, libcmt), MtStorageMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceHazardTrackingMode(res)
    ccall((:mtResourceHazardTrackingMode, libcmt), MtHazardTrackingMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceOptions(res)
    ccall((:mtResourceOptions, libcmt), MtResourceOptions,
          (Ptr{MtResource},),
          res)
end

function mtCreateSystemDefaultDevice()
    ccall((:mtCreateSystemDefaultDevice, libcmt), Ptr{MtDevice}, ())
end

function mtCopyAllDevices(count, devices)
    ccall((:mtCopyAllDevices, libcmt), Cvoid,
          (Ptr{Csize_t}, Ptr{MtDevice}),
          count, devices)
end

function mtDeviceName(arg1)
    ccall((:mtDeviceName, libcmt), Cstring,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceHeadless(arg1)
    ccall((:mtDeviceHeadless, libcmt), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLowPower(arg1)
    ccall((:mtDeviceLowPower, libcmt), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceRemovable(arg1)
    ccall((:mtDeviceRemovable, libcmt), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceRegistryID(arg1)
    ccall((:mtDeviceRegistryID, libcmt), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLocation(arg1)
    ccall((:mtDeviceLocation, libcmt), MtDeviceLocation,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLocationNumber(arg1)
    ccall((:mtDeviceLocationNumber, libcmt), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceMaxTransferRate(arg1)
    ccall((:mtDeviceMaxTransferRate, libcmt), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceHasUnifiedMemory(arg1)
    ccall((:mtDeviceHasUnifiedMemory, libcmt), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerGroupID(arg1)
    ccall((:mtDevicePeerGroupID, libcmt), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerCount(arg1)
    ccall((:mtDevicePeerCount, libcmt), UInt32,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerIndex(arg1)
    ccall((:mtDevicePeerIndex, libcmt), UInt32,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceSupportsFamily(device, family)
    ccall((:mtDeviceSupportsFamily, libcmt), Bool,
          (Ptr{MtDevice}, MtGPUFamily),
          device, family)
end

function mtDeviceSupportsFeatureSet(device, set)
    ccall((:mtDeviceSupportsFeatureSet, libcmt), Bool,
          (Ptr{MtDevice}, MtFeatureSet),
          device, set)
end

function mtDeviceRecommendedMaxWorkingSetSize(device)
    ccall((:mtDeviceRecommendedMaxWorkingSetSize, libcmt), UInt64,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceCurrentAllocatedSize(device)
    ccall((:mtDeviceCurrentAllocatedSize, libcmt), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceMaxThreadgroupMemoryLength(device)
    ccall((:mtDeviceMaxThreadgroupMemoryLength, libcmt), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtMaxThreadsPerThreadgroup(device)
    ccall((:mtMaxThreadsPerThreadgroup, libcmt), MtSize,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceMaxBufferLength(device)
    ccall((:mtDeviceMaxBufferLength, libcmt), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceNewBufferWithLength(device, length, opts)
    ccall((:mtDeviceNewBufferWithLength, libcmt), Ptr{MtBuffer},
          (Ptr{MtDevice}, NsUInteger, MtResourceOptions),
          device, length, opts)
end

function mtDeviceNewBufferWithBytes(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytes, libcmt), Ptr{MtBuffer},
          (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions),
          device, ptr, length, opts)
end

function mtDeviceNewBufferWithBytesNoCopy(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytesNoCopy, libcmt), Ptr{MtBuffer},
          (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions),
          device, ptr, length, opts)
end

function mtNewComputePipelineStateWithFunction(device, fun, error)
    ccall((:mtNewComputePipelineStateWithFunction, libcmt), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtFunction}, Ptr{Ptr{NsError}}),
          device, fun, error)
end

function mtNewComputePipelineStateWithFunctionReflection(device, fun, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithFunctionReflection, libcmt), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtFunction}, MtPipelineOption,
           Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}),
          device, fun, opt, reflection, error)
end

function mtNewComputePipelineStateWithDescriptor(device, desc, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithDescriptor, libcmt), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtComputePipelineDescriptor}, MtPipelineOption,
           Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}),
          device, desc, opt, reflection, error)
end

function mtComputePipelineDevice(pip)
    ccall((:mtComputePipelineDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineLabel(pip)
    ccall((:mtComputePipelineLabel, libcmt), Cstring,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineMaxTotalThreadsPerThreadgroup(pip)
    ccall((:mtComputePipelineMaxTotalThreadsPerThreadgroup, libcmt), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineThreadExecutionWidth(pip)
    ccall((:mtComputePipelineThreadExecutionWidth, libcmt), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineStaticThreadgroupMemoryLength(pip)
    ccall((:mtComputePipelineStaticThreadgroupMemoryLength, libcmt), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtAttributeName(attr)
    ccall((:mtAttributeName, libcmt), Cstring,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIndex(attr)
    ccall((:mtAttributeIndex, libcmt), NsUInteger,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeDataType(attr)
    ccall((:mtAttributeDataType, libcmt), MtDataType,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeActive(attr)
    ccall((:mtAttributeActive, libcmt), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIsPatchControlPointData(attr)
    ccall((:mtAttributeIsPatchControlPointData, libcmt), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIsPatchData(attr)
    ccall((:mtAttributeIsPatchData, libcmt), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtVertexAttributeName(attr)
    ccall((:mtVertexAttributeName, libcmt), Cstring,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIndex(attr)
    ccall((:mtVertexAttributeIndex, libcmt), NsUInteger,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeDataType(attr)
    ccall((:mtVertexAttributeDataType, libcmt), MtDataType,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeActive(attr)
    ccall((:mtVertexAttributeActive, libcmt), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIsPatchControlPointData(attr)
    ccall((:mtVertexAttributeIsPatchControlPointData, libcmt), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIsPatchData(attr)
    ccall((:mtVertexAttributeIsPatchData, libcmt), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtNewCompileOpts()
    ccall((:mtNewCompileOpts, libcmt), Ptr{MtCompileOptions}, ())
end

function mtCompileOptsFastMath(opts)
    ccall((:mtCompileOptsFastMath, libcmt), Bool,
          (Ptr{MtCompileOptions},),
          opts)
end

function mtCompileOptsFastMathSet(opts, val)
    ccall((:mtCompileOptsFastMathSet, libcmt), Cvoid,
          (Ptr{MtCompileOptions}, Bool),
          opts, val)
end

function mtCompileOptsLanguageVersion(opts)
    ccall((:mtCompileOptsLanguageVersion, libcmt), MtLanguageVersion,
          (Ptr{MtCompileOptions},),
          opts)
end

function mtCompileOptsLanguageVersionSet(opts, val)
    ccall((:mtCompileOptsLanguageVersionSet, libcmt), Cvoid,
          (Ptr{MtCompileOptions}, MtLanguageVersion),
          opts, val)
end

function mtFunctionConstantValuesSetWithIndex(funval, value, typ, idx)
    ccall((:mtFunctionConstantValuesSetWithIndex, libcmt), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsUInteger),
          funval, value, typ, idx)
end

function mtFunctionConstantValuesSetWithName(funval, value, typ, name)
    ccall((:mtFunctionConstantValuesSetWithName, libcmt), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, Cstring),
          funval, value, typ, name)
end

function mtFunctionConstantValuesSetWithRange(funval, value, typ, range)
    ccall((:mtFunctionConstantValuesSetWithRange, libcmt), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsRange),
          funval, value, typ, range)
end

function mtFunctionConstantValuesReset(funval)
    ccall((:mtFunctionConstantValuesReset, libcmt), Cvoid,
          (Ptr{MtFunctionConstantValues},),
          funval)
end

function mtNewFunctionWithName(lib, name)
    ccall((:mtNewFunctionWithName, libcmt), Ptr{MtFunction},
          (Ptr{MtLibrary}, Cstring),
          lib, name)
end

function mtNewFunctionWithNameConstantValues(lib, name, constantValues, error)
    ccall((:mtNewFunctionWithNameConstantValues, libcmt), Ptr{MtFunction},
          (Ptr{MtLibrary}, Cstring, Ptr{MtFunctionConstantValues}, Ptr{Ptr{NsError}}),
          lib, name, constantValues, error)
end

function mtFunctionDevice(fun)
    ccall((:mtFunctionDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionLabel(fun)
    ccall((:mtFunctionLabel, libcmt), Cstring,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionType(fun)
    ccall((:mtFunctionType, libcmt), MtFunctionType,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionName(fun)
    ccall((:mtFunctionName, libcmt), Cstring,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionStageInputAttributes(fun)
    ccall((:mtFunctionStageInputAttributes, libcmt), Ptr{Ptr{MtAttribute}},
          (Ptr{MtFunction},),
          fun)
end

function mtNewDefaultLibrary(device)
    ccall((:mtNewDefaultLibrary, libcmt), Ptr{MtLibrary},
          (Ptr{MtDevice},),
          device)
end

function mtNewLibraryWithFile(device, filepath, error)
    ccall((:mtNewLibraryWithFile, libcmt), Ptr{MtLibrary},
          (Ptr{MtDevice}, Cstring, Ptr{Ptr{NsError}}),
          device, filepath, error)
end

function mtNewLibraryWithSource(device, source, Opts, error)
    ccall((:mtNewLibraryWithSource, libcmt), Ptr{MtLibrary},
          (Ptr{MtDevice}, Cstring, Ptr{MtCompileOptions}, Ptr{Ptr{NsError}}),
          device, source, Opts, error)
end

function mtNewLibraryWithData(device, buffer, size, error)
    ccall((:mtNewLibraryWithData, libcmt), Ptr{MtLibrary},
          (Ptr{MtDevice}, Ptr{Cvoid}, Csize_t, Ptr{Ptr{NsError}}),
          device, buffer, size, error)
end

function mtLibraryDevice(lib)
    ccall((:mtLibraryDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtLibrary},),
          lib)
end

function mtLibraryLabel(lib)
    ccall((:mtLibraryLabel, libcmt), Cstring,
          (Ptr{MtLibrary},),
          lib)
end

function mtLibraryFunctionNames(lib, count, names)
    ccall((:mtLibraryFunctionNames, libcmt), Cvoid,
          (Ptr{MtLibrary}, Ptr{Csize_t}, Ptr{Cstring}),
          lib, count, names)
end

function mtBufferContents(buf)
    ccall((:mtBufferContents, libcmt), Ptr{Cvoid},
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferLength(buf)
    ccall((:mtBufferLength, libcmt), NsUInteger,
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferDidModifyRange(buf, ran)
    ccall((:mtBufferDidModifyRange, libcmt), Cvoid,
          (Ptr{MtBuffer}, NsRange),
          buf, ran)
end

function mtBufferAddDebugMarkerRange(buf, string, range)
    ccall((:mtBufferAddDebugMarkerRange, libcmt), Cvoid,
          (Ptr{MtBuffer}, Cstring, NsRange),
          buf, string, range)
end

function mtBufferRemoveAllDebugMarkers(buf)
    ccall((:mtBufferRemoveAllDebugMarkers, libcmt), Cvoid,
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferNewRemoteBufferViewForDevice(buf, device)
    ccall((:mtBufferNewRemoteBufferViewForDevice, libcmt), Ptr{MtBuffer},
          (Ptr{MtBuffer}, Ptr{MtDevice}),
          buf, device)
end

function mtBufferRemoteStorageBuffer(buf)
    ccall((:mtBufferRemoteStorageBuffer, libcmt), Ptr{MtBuffer},
          (Ptr{MtBuffer},),
          buf)
end

function mtNewHeapDescriptor()
    ccall((:mtNewHeapDescriptor, libcmt), Ptr{MtHeapDescriptor}, ())
end

function mtHeapDescriptorType(heap)
    ccall((:mtHeapDescriptorType, libcmt), MtHeapType,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorTypeSet(heap, type)
    ccall((:mtHeapDescriptorTypeSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, MtHeapType),
          heap, type)
end

function mtHeapDescriptorStorageMode(heap)
    ccall((:mtHeapDescriptorStorageMode, libcmt), MtStorageMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorStorageModeSet(heap, mode)
    ccall((:mtHeapDescriptorStorageModeSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, MtStorageMode),
          heap, mode)
end

function mtHeapDescriptorCPUCacheMode(heap)
    ccall((:mtHeapDescriptorCPUCacheMode, libcmt), MtCPUCacheMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorCpuCacheModeSet(heap, mode)
    ccall((:mtHeapDescriptorCpuCacheModeSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, MtCPUCacheMode),
          heap, mode)
end

function mtHeapDescriptorHazardTrackingMode(heap)
    ccall((:mtHeapDescriptorHazardTrackingMode, libcmt), MtHazardTrackingMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorHazardTrackingModeSet(heap, mode)
    ccall((:mtHeapDescriptorHazardTrackingModeSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, MtHazardTrackingMode),
          heap, mode)
end

function mtHeapDescriptorResourceOptions(heap)
    ccall((:mtHeapDescriptorResourceOptions, libcmt), MtResourceOptions,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorResourceOptionsSet(heap, mode)
    ccall((:mtHeapDescriptorResourceOptionsSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, MtResourceOptions),
          heap, mode)
end

function mtHeapDescriptorSize(heap)
    ccall((:mtHeapDescriptorSize, libcmt), NsUInteger,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorSizeSet(heap, size)
    ccall((:mtHeapDescriptorSizeSet, libcmt), Cvoid,
          (Ptr{MtHeapDescriptor}, NsUInteger),
          heap, size)
end

function mtDeviceNewHeapWithDescriptor(dev, descriptor)
    ccall((:mtDeviceNewHeapWithDescriptor, libcmt), Ptr{MtHeap},
          (Ptr{MtDevice}, Ptr{MtHeapDescriptor}),
          dev, descriptor)
end

function mtHeapDevice(heap)
    ccall((:mtHeapDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtHeap},),
          heap)
end

function mtHeapLabel(heap)
    ccall((:mtHeapLabel, libcmt), Cstring,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapType(heap)
    ccall((:mtHeapType, libcmt), MtHeapType,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapStorageMode(heap)
    ccall((:mtHeapStorageMode, libcmt), MtStorageMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapCPUCacheMode(heap)
    ccall((:mtHeapCPUCacheMode, libcmt), MtCPUCacheMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapHazardTrackingMode(heap)
    ccall((:mtHeapHazardTrackingMode, libcmt), MtHazardTrackingMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapResourceOptions(heap)
    ccall((:mtHeapResourceOptions, libcmt), MtResourceOptions,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapSize(heap)
    ccall((:mtHeapSize, libcmt), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapUsedSize(heap)
    ccall((:mtHeapUsedSize, libcmt), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapCurrentAllocatedSize(heap)
    ccall((:mtHeapCurrentAllocatedSize, libcmt), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapMaxAvailableSizeWithAlignment(heap, alignment)
    ccall((:mtHeapMaxAvailableSizeWithAlignment, libcmt), NsUInteger,
          (Ptr{MtHeap}, NsUInteger),
          heap, alignment)
end

function mtHeapSetPurgeableState(heap, state)
    ccall((:mtHeapSetPurgeableState, libcmt), MtPurgeableState,
          (Ptr{MtHeap}, MtPurgeableState),
          heap, state)
end

function mtHeapNewBufferWithLength(heap, len, opt)
    ccall((:mtHeapNewBufferWithLength, libcmt), Ptr{MtBuffer},
          (Ptr{MtHeap}, NsUInteger, MtResourceOptions),
          heap, len, opt)
end

function mtHeapNewBufferWithLengthOffset(heap, len, opt, offset)
    ccall((:mtHeapNewBufferWithLengthOffset, libcmt), Ptr{MtBuffer},
          (Ptr{MtHeap}, NsUInteger, MtResourceOptions, NsUInteger),
          heap, len, opt, offset)
end

function mtHeapNewTextureWithDescriptor(heap, desc)
    ccall((:mtHeapNewTextureWithDescriptor, libcmt), Ptr{MtTexture},
          (Ptr{MtHeap}, Ptr{MtTextureDescriptor}),
          heap, desc)
end

function mtHeapNewTextureWithDescriptorOffset(heap, desc, offset)
    ccall((:mtHeapNewTextureWithDescriptorOffset, libcmt), Ptr{MtTexture},
          (Ptr{MtHeap}, Ptr{MtTextureDescriptor}, NsUInteger),
          heap, desc, offset)
end

function mtVertexDescNew()
    ccall((:mtVertexDescNew, libcmt), Ptr{MtVertexDescriptor}, ())
end

function mtVertexAttrib(vertex, attribIndex, format, offset, bufferIndex)
    ccall((:mtVertexAttrib, libcmt), Cvoid,
          (Ptr{MtVertexDescriptor}, UInt32, MtVertexFormat, UInt32, UInt32),
          vertex, attribIndex, format, offset, bufferIndex)
end

function mtVertexLayout(vertex, layoutIndex, stride, stepRate, stepFunction)
    ccall((:mtVertexLayout, libcmt), Cvoid,
          (Ptr{MtVertexDescriptor}, UInt32, UInt32, UInt32, MtVertexStepFunction),
          vertex, layoutIndex, stride, stepRate, stepFunction)
end

function mtSetVertexDesc(pipeline, vert)
    ccall((:mtSetVertexDesc, libcmt), Cvoid,
          (Ptr{MtRenderPipeline}, Ptr{MtVertexDescriptor}),
          pipeline, vert)
end

function mtDepthStencil(depthCompareFunc, depthWriteEnabled)
    ccall((:mtDepthStencil, libcmt), Ptr{MtDepthStencil},
          (MtCompareFunction, Bool),
          depthCompareFunc, depthWriteEnabled)
end

function mtNewPass()
    ccall((:mtNewPass, libcmt), Ptr{MtRenderPassDesc}, ())
end

function mtPassTexture(pass, colorAttch, tex)
    ccall((:mtPassTexture, libcmt), Cvoid,
          (Ptr{MtRenderPassDesc}, Cint, Ptr{MtTexture}),
          pass, colorAttch, tex)
end

function mtPassLoadAction(pass, colorAttch, action)
    ccall((:mtPassLoadAction, libcmt), Cvoid,
          (Ptr{MtRenderPassDesc}, Cint, MtLoadAction),
          pass, colorAttch, action)
end

function mtNewRenderPipeline(pixelFormat)
    ccall((:mtNewRenderPipeline, libcmt), Ptr{MtRenderDesc},
          (MtPixelFormat,),
          pixelFormat)
end

function mtSetFunc(pipDesc, func, functype)
    ccall((:mtSetFunc, libcmt), Cvoid,
          (Ptr{MtRenderDesc}, Ptr{MtFunction}, MtFuncType),
          pipDesc, func, functype)
end

function mtNewRenderState(device, pipDesc, error)
    ccall((:mtNewRenderState, libcmt), Ptr{MtRenderPipeline},
          (Ptr{MtDevice}, Ptr{MtRenderDesc}, Ptr{Ptr{NsError}}),
          device, pipDesc, error)
end

function mtColorPixelFormat(renderdesc, index, pixelFormat)
    ccall((:mtColorPixelFormat, libcmt), Cvoid,
          (Ptr{MtRenderDesc}, UInt32, MtPixelFormat),
          renderdesc, index, pixelFormat)
end

function mtDepthPixelFormat(renderdesc, pixelFormat)
    ccall((:mtDepthPixelFormat, libcmt), Cvoid,
          (Ptr{MtRenderDesc}, MtPixelFormat),
          renderdesc, pixelFormat)
end

function mtStencilPixelFormat(renderdesc, pixelFormat)
    ccall((:mtStencilPixelFormat, libcmt), Cvoid,
          (Ptr{MtRenderDesc}, MtPixelFormat),
          renderdesc, pixelFormat)
end

function mtSampleCount(renderdesc, sampleCount)
    ccall((:mtSampleCount, libcmt), Cvoid,
          (Ptr{MtRenderDesc}, UInt32),
          renderdesc, sampleCount)
end

function mtArgumentName(arg)
    ccall((:mtArgumentName, libcmt), Cstring,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentActive(arg)
    ccall((:mtArgumentActive, libcmt), Bool,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentIndex(arg)
    ccall((:mtArgumentIndex, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentType(arg)
    ccall((:mtArgumentType, libcmt), MtArgumentType,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentAccess(arg)
    ccall((:mtArgumentAccess, libcmt), MtArgumentAccess,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferAlignment(arg)
    ccall((:mtArgumentBufferAlignment, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferDataSize(arg)
    ccall((:mtArgumentBufferDataSize, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferDataType(arg)
    ccall((:mtArgumentBufferDataType, libcmt), MtDataType,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferStructType(arg)
    ccall((:mtArgumentBufferStructType, libcmt), Ptr{MtStructType},
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferPointerType(arg)
    ccall((:mtArgumentBufferPointerType, libcmt), Ptr{MtPointerType},
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentArrayLength(arg)
    ccall((:mtArgumentArrayLength, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentThreadgroupMemoryAlignment(arg)
    ccall((:mtArgumentThreadgroupMemoryAlignment, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentThreadgroupMemoryDataSize(arg)
    ccall((:mtArgumentThreadgroupMemoryDataSize, libcmt), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtNewComputePipelineReflection()
    ccall((:mtNewComputePipelineReflection, libcmt), Ptr{MtComputePipelineReflection}, ())
end

function mtComputePipelinereflectionArguments(refl)
    ccall((:mtComputePipelinereflectionArguments, libcmt), Ptr{MtArgument},
          (Ptr{MtComputePipelineReflection},),
          refl)
end

function mtPointerTypeElementType(ptr)
    ccall((:mtPointerTypeElementType, libcmt), MtDataType,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeAccess(ptr)
    ccall((:mtPointerTypeAccess, libcmt), MtArgumentAccess,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeAlignment(ptr)
    ccall((:mtPointerTypeAlignment, libcmt), NsUInteger,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeDataSize(ptr)
    ccall((:mtPointerTypeDataSize, libcmt), NsUInteger,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementIsArgumentBuffer(ptr)
    ccall((:mtPointerTypeElementIsArgumentBuffer, libcmt), Bool,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementStructType(ptr)
    ccall((:mtPointerTypeElementStructType, libcmt), Ptr{MtStructType},
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementArrayType(ptr)
    ccall((:mtPointerTypeElementArrayType, libcmt), Ptr{MtArrayType},
          (Ptr{MtPointerType},),
          ptr)
end

function mtNewCommandBuffer(cmdq)
    ccall((:mtNewCommandBuffer, libcmt), Ptr{MtCommandBuffer},
          (Ptr{MtCommandQueue},),
          cmdq)
end

function mtNewCommandBufferWithUnretainedReferences(cmdq)
    ccall((:mtNewCommandBufferWithUnretainedReferences, libcmt), Ptr{MtCommandBuffer},
          (Ptr{MtCommandQueue},),
          cmdq)
end

function mtCommandBufferOnComplete(cmdb, sender, oncomplete)
    ccall((:mtCommandBufferOnComplete, libcmt), Cvoid,
          (Ptr{MtCommandQueue}, Ptr{Cvoid}, MtCommandBufferOnCompleteFn),
          cmdb, sender, oncomplete)
end

function mtCommandBufferOnCompleteNoSender(cmdb, oncomplete)
    ccall((:mtCommandBufferOnCompleteNoSender, libcmt), Cvoid,
          (Ptr{MtCommandQueue}, MtCommandBufferOnCompleteFnNoSender),
          cmdb, oncomplete)
end

function mtCommandBufferPresentDrawable(cmdb, drawable)
    ccall((:mtCommandBufferPresentDrawable, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtDrawable}),
          cmdb, drawable)
end

function mtCommandBufferEqueue(cmdb)
    ccall((:mtCommandBufferEqueue, libcmt), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferCommit(cmdb)
    ccall((:mtCommandBufferCommit, libcmt), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferAddScheduledHandler(cmdb, handler)
    ccall((:mtCommandBufferAddScheduledHandler, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun),
          cmdb, handler)
end

function mtCommandBufferAddCompletedHandler(cmdb, handler)
    ccall((:mtCommandBufferAddCompletedHandler, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun),
          cmdb, handler)
end

function mtCommandBufferWaitUntilScheduled(cmdb)
    ccall((:mtCommandBufferWaitUntilScheduled, libcmt), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferWaitUntilCompleted(cmdb)
    ccall((:mtCommandBufferWaitUntilCompleted, libcmt), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferStatus(cmdb)
    ccall((:mtCommandBufferStatus, libcmt), MtCommandBufferStatus,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferError(cmdb)
    ccall((:mtCommandBufferError, libcmt), Ptr{NsError},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferKernelStartTime(cmdb)
    ccall((:mtCommandBufferKernelStartTime, libcmt), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferKernelEndTime(cmdb)
    ccall((:mtCommandBufferKernelEndTime, libcmt), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferGPUStartTime(cmdb)
    ccall((:mtCommandBufferGPUStartTime, libcmt), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferGPUEndTime(cmdb)
    ccall((:mtCommandBufferGPUEndTime, libcmt), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferEncodeSignalEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeSignalEvent, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64),
          cmdb, event, val)
end

function mtCommandBufferEncodeWaitForEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeWaitForEvent, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64),
          cmdb, event, val)
end

function mtCommandBufferRetainedReferences(cmdb)
    ccall((:mtCommandBufferRetainedReferences, libcmt), Bool,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferDevice(cmdb)
    ccall((:mtCommandBufferDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferCommandQueue(cmdb)
    ccall((:mtCommandBufferCommandQueue, libcmt), Ptr{MtCommandQueue},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferLabel(cmdb)
    ccall((:mtCommandBufferLabel, libcmt), Cstring,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferPushDebugGroup(cmdb, str)
    ccall((:mtCommandBufferPushDebugGroup, libcmt), Cvoid,
          (Ptr{MtCommandBuffer}, Cstring),
          cmdb, str)
end

function mtCommandBufferPopDebugGroup(cmdb)
    ccall((:mtCommandBufferPopDebugGroup, libcmt), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtNewIndirectCommandBuffer(device, desc, maxCount, options)
    ccall((:mtNewIndirectCommandBuffer, libcmt), Ptr{MtIndirectCommandBuffer},
          (Ptr{MtDevice}, Ptr{MtIndirectCommandBufferDescriptor}, NsUInteger,
           MtResourceOptions),
          device, desc, maxCount, options)
end

function mtIndirectCommandBufferSize(icb)
    ccall((:mtIndirectCommandBufferSize, libcmt), NsUInteger,
          (Ptr{MtIndirectCommandBuffer},),
          icb)
end

function mtIndirectCommandBufferComputeCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferComputeCommandAtIndex, libcmt), Ptr{MtIndirectComputeCommand},
          (Ptr{MtIndirectCommandBuffer}, NsUInteger),
          icb, index)
end

function mtIndirectCommandBufferRenderCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferRenderCommandAtIndex, libcmt), Ptr{MtIndirectRenderCommand},
          (Ptr{MtIndirectCommandBuffer}, NsUInteger),
          icb, index)
end

function mtIndirectCommandBufferResetWithRange(icb, range)
    ccall((:mtIndirectCommandBufferResetWithRange, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, NsRange),
          icb, range)
end

function mtCommandEncoderEndEncoding(ce)
    ccall((:mtCommandEncoderEndEncoding, libcmt), Cvoid,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderDevice(ce)
    ccall((:mtCommandEncoderDevice, libcmt), Ptr{MtDevice},
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderLabel(ce)
    ccall((:mtCommandEncoderLabel, libcmt), Cstring,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderInsertDebugSignpost(ce, string)
    ccall((:mtCommandEncoderInsertDebugSignpost, libcmt), Cvoid,
          (Ptr{MtCommandEncoder}, Cstring),
          ce, string)
end

function mtCommandEncoderPushDebugGroup(ce, string)
    ccall((:mtCommandEncoderPushDebugGroup, libcmt), Cvoid,
          (Ptr{MtCommandEncoder}, Cstring),
          ce, string)
end

function mtCommandEncoderPopDebugGroup(ce)
    ccall((:mtCommandEncoderPopDebugGroup, libcmt), Cvoid,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtNewBlitCommandEncoder(cmdb)
    ccall((:mtNewBlitCommandEncoder, libcmt), Ptr{MtBlitCommandEncoder},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtBlitCommandEncoderCopyFromBufferToBuffer(bce, src, src_offset, dst, dst_offset,
                                                    size)
    ccall((:mtBlitCommandEncoderCopyFromBufferToBuffer, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsUInteger, Ptr{MtBuffer},
           NsUInteger, NsUInteger),
          bce, src, src_offset, dst, dst_offset, size)
end

function mtBlitCommandEncoderFillBuffer(bce, src, range, val)
    ccall((:mtBlitCommandEncoderFillBuffer, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsRange, UInt8),
          bce, src, range, val)
end

function mtBlitCommandEncoderGenerateMipmaps(bce, texture)
    ccall((:mtBlitCommandEncoderGenerateMipmaps, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}),
          bce, texture)
end

function mtBlitCommandEncoderCopyIndirectCommandBuffer(bce, src, range, dst, dst_index)
    ccall((:mtBlitCommandEncoderCopyIndirectCommandBuffer, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange,
           Ptr{MtIndirectCommandBuffer}, NsUInteger),
          bce, src, range, dst, dst_index)
end

function mtBlitCommandEncoderOptimizeIndirectCommandBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderOptimizeIndirectCommandBuffer, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange),
          bce, buffer, range)
end

function mtBlitCommandEncoderResetCommandsInBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderResetCommandsInBuffer, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange),
          bce, buffer, range)
end

function mtBlitCommandEncoderSynchronizeResource(bce, resource)
    ccall((:mtBlitCommandEncoderSynchronizeResource, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtResource}),
          bce, resource)
end

function mtBlitCommandEncoderSynchronizeTexture(bce, texture, slice, level)
    ccall((:mtBlitCommandEncoderSynchronizeTexture, libcmt), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          bce, texture, slice, level)
end

function mtBlitCommandEncoderUpdateFence(icb, fence)
    ccall((:mtBlitCommandEncoderUpdateFence, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}),
          icb, fence)
end

function mtBlitCommandEncoderWaitForFence(icb, fence)
    ccall((:mtBlitCommandEncoderWaitForFence, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}),
          icb, fence)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccess, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}),
          icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          icb, tex, slice, level)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccess, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}),
          icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          icb, tex, slice, level)
end

function mtBlitCommandEncoderSampleCountersInBuffer(icb, sbuf, sampleindex, barrier)
    ccall((:mtBlitCommandEncoderSampleCountersInBuffer, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsUInteger, Bool),
          icb, sbuf, sampleindex, barrier)
end

function mtBlitCommandEncoderResolveCounters(icb, sbuf, range, dst, dst_offset)
    ccall((:mtBlitCommandEncoderResolveCounters, libcmt), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsRange,
           Ptr{MtBuffer}, NsUInteger),
          icb, sbuf, range, dst, dst_offset)
end

function mtNewComputeCommandEncoder(cmdb)
    ccall((:mtNewComputeCommandEncoder, libcmt), Ptr{MtComputeCommandEncoder},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtNewComputeCommandEncoderWithDispatchType(cmdb, dtype)
    ccall((:mtNewComputeCommandEncoderWithDispatchType, libcmt), Ptr{MtComputeCommandEncoder},
          (Ptr{MtCommandBuffer}, MtDispatchType),
          cmdb, dtype)
end

function mtComputeCommandEncoderEndEncoding(cce)
    ccall((:mtComputeCommandEncoderEndEncoding, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder},),
          cce)
end

function mtComputeCommandEncoderSetComputePipelineState(cce, state)
    ccall((:mtComputeCommandEncoderSetComputePipelineState, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtComputePipelineState}),
          cce, state)
end

function mtComputeCommandEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtComputeCommandEncoderSetBufferOffsetAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, offset, indx)
end

function mtComputeCommandEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtComputeCommandEncoderSetBuffersOffsetsWithRange, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange),
          cce, bufs, offsets, range)
end

function mtComputeCommandEncoderBufferSetOffsetAtIndex(cce, offset, indx)
    ccall((:mtComputeCommandEncoderBufferSetOffsetAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger),
          cce, offset, indx)
end

function mtComputeCommandEncoderSetBytesLengthAtIndex(cce, ptr, length, indx)
    ccall((:mtComputeCommandEncoderSetBytesLengthAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Cvoid}, NsUInteger, NsUInteger),
          cce, ptr, length, indx)
end

function mtComputeCommandEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, NsUInteger),
          cce, sampler, indx)
end

function mtComputeCommandEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtComputeCommandEncoderSetSamplerStatesWithRange, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange),
          cce, samplers, range)
end

function mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex(cce, sampler,
                                                                             lodMinClamp,
                                                                             lodMaxClamp,
                                                                             indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, Cfloat, Cfloat, NsUInteger),
          cce, sampler, lodMinClamp, lodMaxClamp, indx)
end

function mtComputeCommandEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtComputeCommandEncoderSetTextureAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtTexture}, NsUInteger),
          cce, tex, indx)
end

function mtComputeCommandEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtComputeCommandEncoderSetTexturesWithRange, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtTexture}}, NsRange),
          cce, textures, range)
end

function mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex(cce, length, indx)
    ccall((:mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger),
          cce, length, indx)
end

function mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(cce,
                                                                           threadgroupsPerGrid,
                                                                           threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtSize, MtSize),
          cce, threadgroupsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup(cce, threadsPerGrid,
                                                                     threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtSize, MtSize),
          cce, threadsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup(cce,
                                                                                                                  indirectBuffer,
                                                                                                                  indirectBufferOffset,
                                                                                                                  threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, MtSize),
          cce, indirectBuffer, indirectBufferOffset, threadsPerThreadgroup)
end

function mtComputeCommandEncoderUseResourceUsage(cce, res, usage)
    ccall((:mtComputeCommandEncoderUseResourceUsage, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtResource}, MtResourceUsage),
          cce, res, usage)
end

function mtComputeCommandEncoderUseResourcesCountUsage(cce, res, count, usage)
    ccall((:mtComputeCommandEncoderUseResourcesCountUsage, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger, MtResourceUsage),
          cce, res, count, usage)
end

function mtComputeCommandEncoderUseHeap(cce, heap)
    ccall((:mtComputeCommandEncoderUseHeap, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtHeap}),
          cce, heap)
end

function mtComputeCommandEncoderUseHeaps(cce, heaps, count)
    ccall((:mtComputeCommandEncoderUseHeaps, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtHeap}}, NsUInteger),
          cce, heaps, count)
end

function mtComputeCommandEncoderSetStageInRegion(cce, region)
    ccall((:mtComputeCommandEncoderSetStageInRegion, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtRegion),
          cce, region)
end

function mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer(cce, buf, offset)
    ccall((:mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger),
          cce, buf, offset)
end

function mtComputeCommandEncoderDispatchType(cce)
    ccall((:mtComputeCommandEncoderDispatchType, libcmt), MtDispatchType,
          (Ptr{MtComputeCommandEncoder},),
          cce)
end

function mtComputeCommandEncoderMemoryBarrierWithScope(cce, scope)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithScope, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtBarrierScope),
          cce, scope)
end

function mtComputeCommandEncoderMemoryBarrierWithResource(cce, resources, count)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithResource, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger),
          cce, resources, count)
end

function mtComputeCommandEncoderExecuteCommandInBuffer(cce, resources, count)
    ccall((:mtComputeCommandEncoderExecuteCommandInBuffer, libcmt), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger),
          cce, resources, count)
end

function mtNewRenderCommandEncoder(cmdb, pass)
    ccall((:mtNewRenderCommandEncoder, libcmt), Ptr{MtRenderCommandEncoder},
          (Ptr{MtCommandBuffer}, Ptr{MtRenderPassDesc}),
          cmdb, pass)
end

function mtFrontFace(rce, winding)
    ccall((:mtFrontFace, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtWinding),
          rce, winding)
end

function mtCullMode(rce, mode)
    ccall((:mtCullMode, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtCullMode),
          rce, mode)
end

function mtViewport(rce, viewport)
    ccall((:mtViewport, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtViewport}),
          rce, viewport)
end

function mtSetRenderState(rce, pipline)
    ccall((:mtSetRenderState, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtRenderPipeline}),
          rce, pipline)
end

function mtSetDepthStencil(rce, ds)
    ccall((:mtSetDepthStencil, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtDepthStencil}),
          rce, ds)
end

function mtVertexBytes(rce, bytes, legth, atIndex)
    ccall((:mtVertexBytes, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{Cvoid}, Csize_t, UInt32),
          rce, bytes, legth, atIndex)
end

function mtVertexBuffer(rce, buf, off, index)
    ccall((:mtVertexBuffer, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32),
          rce, buf, off, index)
end

function mtFragmentBuffer(rce, buf, off, index)
    ccall((:mtFragmentBuffer, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32),
          rce, buf, off, index)
end

function mtDrawPrims(rce, type, start, count)
    ccall((:mtDrawPrims, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, Csize_t, Csize_t),
          rce, type, start, count)
end

function mtDrawIndexedPrims(rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
    ccall((:mtDrawIndexedPrims, libcmt), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, UInt32, MtIndexType,
           Ptr{MtBuffer}, UInt32),
          rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
end

function mtNewCommandQueue(device)
    ccall((:mtNewCommandQueue, libcmt), Ptr{MtCommandQueue},
          (Ptr{MtDevice},),
          device)
end

function mtNewCommandQueueWithMaxCommandBufferCount(device, count)
    ccall((:mtNewCommandQueueWithMaxCommandBufferCount, libcmt), Ptr{MtCommandQueue},
          (Ptr{MtDevice}, NsUInteger),
          device, count)
end

function mtNewArgumentDescriptor()
    ccall((:mtNewArgumentDescriptor, libcmt), Ptr{MtArgumentDescriptor}, ())
end

function mtArgumentDescriptorDataType(desc)
    ccall((:mtArgumentDescriptorDataType, libcmt), MtDataType,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorDataTypeSet(desc, dataType)
    ccall((:mtArgumentDescriptorDataTypeSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtDataType),
          desc, dataType)
end

function mtArgumentDescriptorIndex(desc)
    ccall((:mtArgumentDescriptorIndex, libcmt), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorIndexSet(desc, index)
    ccall((:mtArgumentDescriptorIndexSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, index)
end

function mtArgumentDescriptorAccess(desc)
    ccall((:mtArgumentDescriptorAccess, libcmt), MtArgumentAccess,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorAccessSet(desc, access)
    ccall((:mtArgumentDescriptorAccessSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtArgumentAccess),
          desc, access)
end

function mtArgumentDescriptorArrayLength(desc)
    ccall((:mtArgumentDescriptorArrayLength, libcmt), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorArrayLengthSet(desc, length)
    ccall((:mtArgumentDescriptorArrayLengthSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, length)
end

function mtArgumentDescriptorConstantBlockAlignment(desc)
    ccall((:mtArgumentDescriptorConstantBlockAlignment, libcmt), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorConstantBlockAlignmentSet(desc, alignment)
    ccall((:mtArgumentDescriptorConstantBlockAlignmentSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, alignment)
end

function mtArgumentDescriptorTextureType(desc)
    ccall((:mtArgumentDescriptorTextureType, libcmt), MtTextureType,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorTextureTypeSet(desc, textype)
    ccall((:mtArgumentDescriptorTextureTypeSet, libcmt), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtTextureType),
          desc, textype)
end

function mtNewArgumentEncoderWithBufferIndexFromFunction(_function, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromFunction, libcmt), Ptr{MtArgumentEncoder},
          (Ptr{MtFunction}, NsUInteger),
          _function, bufferIndex)
end

function mtNewArgumentEncoderWithBufferIndexReflectionFromFunction(_function, bufferIndex,
                                                                   reflection)
    ccall((:mtNewArgumentEncoderWithBufferIndexReflectionFromFunction, libcmt), Ptr{MtArgumentEncoder},
          (Ptr{MtFunction}, NsUInteger, Ptr{MtAutoreleasedArgument}),
          _function, bufferIndex, reflection)
end

function mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer(ae, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer, libcmt), Ptr{MtArgumentEncoder},
          (Ptr{MtArgumentEncoder}, NsUInteger),
          ae, bufferIndex)
end

function mtNewArgumentEncoder(device, arguments, count)
    ccall((:mtNewArgumentEncoder, libcmt), Ptr{MtArgumentEncoder},
          (Ptr{MtDevice}, Ptr{Ptr{MtArgumentDescriptor}}, UInt64),
          device, arguments, count)
end

function mtArgumentEncoderLength(encoder)
    ccall((:mtArgumentEncoderLength, libcmt), NsUInteger,
          (Ptr{MtArgumentEncoder},),
          encoder)
end

function mtArgumentEncoderSetArgumentBufferWithOffset(cce, buf, offset)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffset, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger),
          cce, buf, offset)
end

function mtArgumentEncoderSetArgumentBufferWithOffsetForElement(cce, buf, startOffset,
                                                                arrayElement)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffsetForElement, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, startOffset, arrayElement)
end

function mtArgumentEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtArgumentEncoderSetBufferOffsetAtIndex, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, offset, indx)
end

function mtArgumentEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtArgumentEncoderSetBuffersOffsetsWithRange, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange),
          cce, bufs, offsets, range)
end

function mtArgumentEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtArgumentEncoderSetTextureAtIndex, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtTexture}, NsUInteger),
          cce, tex, indx)
end

function mtArgumentEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtArgumentEncoderSetTexturesWithRange, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtTexture}}, NsRange),
          cce, textures, range)
end

function mtArgumentEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtArgumentEncoderSetSamplerStateAtIndex, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtSamplerState}, NsUInteger),
          cce, sampler, indx)
end

function mtArgumentEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtArgumentEncoderSetSamplerStatesWithRange, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange),
          cce, samplers, range)
end

function mtArgumentEncoderConstantDataAtIndex(cce, index)
    ccall((:mtArgumentEncoderConstantDataAtIndex, libcmt), Ptr{Cvoid},
          (Ptr{MtArgumentEncoder}, NsUInteger),
          cce, index)
end

function mtArgumentEncoderSetIndirectCommandBuffer(cce, cbuf, index)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffer, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtIndirectCommandBuffer}, NsUInteger),
          cce, cbuf, index)
end

function mtArgumentEncoderSetIndirectCommandBuffers(cce, cbufs, range)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffers, libcmt), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtIndirectCommandBuffer}}, NsRange),
          cce, cbufs, range)
end

function mtArgumentEncoderAlignment(cce)
    ccall((:mtArgumentEncoderAlignment, libcmt), NsUInteger,
          (Ptr{MtArgumentEncoder},),
          cce)
end

function mtRetain(obj)
    ccall((:mtRetain, libcmt), Ptr{Cvoid},
          (Ptr{Cvoid},),
          obj)
end

function mtRelease(obj)
    ccall((:mtRelease, libcmt), Cvoid,
          (Ptr{Cvoid},),
          obj)
end
