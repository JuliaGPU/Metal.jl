# Julia wrapper for header: cmt.h
# Automatically generated using Clang.jl


function mtErrorRelease(err)
    ccall((:mtErrorRelease, cmt_lib), Cvoid,
          (Ptr{NsError},),
          err)
end

function mtErrorCode(err)
    ccall((:mtErrorCode, cmt_lib), NsInteger,
          (Ptr{NsError},),
          err)
end

function mtErrorDomain(err)
    ccall((:mtErrorDomain, cmt_lib), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorUserInfo(err)
    ccall((:mtErrorUserInfo, cmt_lib), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedDescription(err)
    ccall((:mtErrorLocalizedDescription, cmt_lib), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedRecoveryOptions(err)
    ccall((:mtErrorLocalizedRecoveryOptions, cmt_lib), Ptr{Cstring},
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedRecoverySuggestion(err)
    ccall((:mtErrorLocalizedRecoverySuggestion, cmt_lib), Cstring,
          (Ptr{NsError},),
          err)
end

function mtErrorLocalizedFailureReason(err)
    ccall((:mtErrorLocalizedFailureReason, cmt_lib), Cstring,
          (Ptr{NsError},),
          err)
end

function mtDeviceNewEvent(dev)
    ccall((:mtDeviceNewEvent, cmt_lib), Ptr{MtEvent},
          (Ptr{MtDevice},),
          dev)
end

function mtDeviceNewSharedEvent(dev)
    ccall((:mtDeviceNewSharedEvent, cmt_lib), Ptr{MtSharedEvent},
          (Ptr{MtDevice},),
          dev)
end

function mtDeviceNewSharedEventWithHandle(dev, handle)
    ccall((:mtDeviceNewSharedEventWithHandle, cmt_lib), Ptr{MtSharedEvent},
          (Ptr{MtDevice}, Ptr{MtSharedEventHandle}),
          dev, handle)
end

function mtDeviceNewFence(dev)
    ccall((:mtDeviceNewFence, cmt_lib), Ptr{MtFence},
          (Ptr{MtDevice},),
          dev)
end

function mtEventRelease(event)
    ccall((:mtEventRelease, cmt_lib), Cvoid,
          (Ptr{MtEvent},),
          event)
end

function mtEventDevice(event)
    ccall((:mtEventDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtEvent},),
          event)
end

function mtEventLabel(event)
    ccall((:mtEventLabel, cmt_lib), Cstring,
          (Ptr{MtEvent},),
          event)
end

function mtSharedEventSignaledValue(event)
    ccall((:mtSharedEventSignaledValue, cmt_lib), UInt64,
          (Ptr{MtSharedEvent},),
          event)
end

function mtSharedEventNewHandle(event)
    ccall((:mtSharedEventNewHandle, cmt_lib), Ptr{MtSharedEventHandle},
          (Ptr{MtSharedEvent},),
          event)
end

function mtSharedEventHandleRelease(handle)
    ccall((:mtSharedEventHandleRelease, cmt_lib), Cvoid,
          (Ptr{MtSharedEventHandle},),
          handle)
end

function mtSharedEventNotifyListener(event, listener, val, block)
    ccall((:mtSharedEventNotifyListener, cmt_lib), Cvoid,
          (Ptr{MtSharedEvent}, Ptr{MtSharedEventListener}, UInt64,
           MtSharedEventNotificationBlock),
          event, listener, val, block)
end

function mtResourceDevice(res)
    ccall((:mtResourceDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtResource},),
          res)
end

function mtResourceLabel(res)
    ccall((:mtResourceLabel, cmt_lib), Cstring,
          (Ptr{MtResource},),
          res)
end

function mtResourceCPUCacheMode(res)
    ccall((:mtResourceCPUCacheMode, cmt_lib), MtCPUCacheMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceStorageMode(res)
    ccall((:mtResourceStorageMode, cmt_lib), MtStorageMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceHazardTrackingMode(res)
    ccall((:mtResourceHazardTrackingMode, cmt_lib), MtHazardTrackingMode,
          (Ptr{MtResource},),
          res)
end

function mtResourceOptions(res)
    ccall((:mtResourceOptions, cmt_lib), MtResourceOptions,
          (Ptr{MtResource},),
          res)
end

function mtCreateSystemDefaultDevice()
    ccall((:mtCreateSystemDefaultDevice, cmt_lib), Ptr{MtDevice}, ())
end

function mtCopyAllDevices()
    ccall((:mtCopyAllDevices, cmt_lib), Ptr{Ptr{MtDevice}}, ())
end

function mtDeviceName(arg1)
    ccall((:mtDeviceName, cmt_lib), Cstring,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceHeadless(arg1)
    ccall((:mtDeviceHeadless, cmt_lib), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLowPower(arg1)
    ccall((:mtDeviceLowPower, cmt_lib), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceRemovable(arg1)
    ccall((:mtDeviceRemovable, cmt_lib), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceRegistryID(arg1)
    ccall((:mtDeviceRegistryID, cmt_lib), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLocation(arg1)
    ccall((:mtDeviceLocation, cmt_lib), MtDeviceLocation,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceLocationNumber(arg1)
    ccall((:mtDeviceLocationNumber, cmt_lib), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceMaxTransferRate(arg1)
    ccall((:mtDeviceMaxTransferRate, cmt_lib), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceHasUnifiedMemory(arg1)
    ccall((:mtDeviceHasUnifiedMemory, cmt_lib), Bool,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerGroupID(arg1)
    ccall((:mtDevicePeerGroupID, cmt_lib), UInt64,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerCount(arg1)
    ccall((:mtDevicePeerCount, cmt_lib), UInt32,
          (Ptr{MtDevice},),
          arg1)
end

function mtDevicePeerIndex(arg1)
    ccall((:mtDevicePeerIndex, cmt_lib), UInt32,
          (Ptr{MtDevice},),
          arg1)
end

function mtDeviceSupportsFamily(device, family)
    ccall((:mtDeviceSupportsFamily, cmt_lib), Bool,
          (Ptr{MtDevice}, MtGPUFamily),
          device, family)
end

function mtDeviceSupportsFeatureSet(device, set)
    ccall((:mtDeviceSupportsFeatureSet, cmt_lib), Bool,
          (Ptr{MtDevice}, MtFeatureSet),
          device, set)
end

function mtDeviceRecommendedMaxWorkingSetSize(device)
    ccall((:mtDeviceRecommendedMaxWorkingSetSize, cmt_lib), UInt64,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceCurrentAllocatedSize(device)
    ccall((:mtDeviceCurrentAllocatedSize, cmt_lib), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceMaxThreadgroupMemoryLength(device)
    ccall((:mtDeviceMaxThreadgroupMemoryLength, cmt_lib), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtMaxThreadsPerThreadgroup(device)
    ccall((:mtMaxThreadsPerThreadgroup, cmt_lib), MtSize,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceMaxBufferLength(device)
    ccall((:mtDeviceMaxBufferLength, cmt_lib), NsUInteger,
          (Ptr{MtDevice},),
          device)
end

function mtDeviceNewBufferWithLength(device, length, opts)
    ccall((:mtDeviceNewBufferWithLength, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtDevice}, NsUInteger, MtResourceOptions),
          device, length, opts)
end

function mtDeviceNewBufferWithBytes(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytes, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions),
          device, ptr, length, opts)
end

function mtDeviceNewBufferWithBytesNoCopy(device, ptr, length, opts)
    ccall((:mtDeviceNewBufferWithBytesNoCopy, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtDevice}, Ptr{Cvoid}, NsUInteger, MtResourceOptions),
          device, ptr, length, opts)
end

function mtNewComputePipelineStateWithFunction(device, fun, error)
    ccall((:mtNewComputePipelineStateWithFunction, cmt_lib), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtFunction}, Ptr{Ptr{NsError}}),
          device, fun, error)
end

function mtNewComputePipelineStateWithFunctionReflection(device, fun, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithFunctionReflection, cmt_lib), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtFunction}, MtPipelineOption,
           Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}),
          device, fun, opt, reflection, error)
end

function mtNewComputePipelineStateWithDescriptor(device, desc, opt, reflection, error)
    ccall((:mtNewComputePipelineStateWithDescriptor, cmt_lib), Ptr{MtComputePipelineState},
          (Ptr{MtDevice}, Ptr{MtComputePipelineDescriptor}, MtPipelineOption,
           Ptr{Ptr{MtComputePipelineReflection}}, Ptr{Ptr{NsError}}),
          device, desc, opt, reflection, error)
end

function mtComputePipelineDevice(pip)
    ccall((:mtComputePipelineDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineRelease(pip)
    ccall((:mtComputePipelineRelease, cmt_lib), Cvoid,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineLabel(pip)
    ccall((:mtComputePipelineLabel, cmt_lib), Cstring,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineMaxTotalThreadsPerThreadgroup(pip)
    ccall((:mtComputePipelineMaxTotalThreadsPerThreadgroup, cmt_lib), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineThreadExecutionWidth(pip)
    ccall((:mtComputePipelineThreadExecutionWidth, cmt_lib), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtComputePipelineStaticThreadgroupMemoryLength(pip)
    ccall((:mtComputePipelineStaticThreadgroupMemoryLength, cmt_lib), NsUInteger,
          (Ptr{MtComputePipelineState},),
          pip)
end

function mtAttributeName(attr)
    ccall((:mtAttributeName, cmt_lib), Cstring,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIndex(attr)
    ccall((:mtAttributeIndex, cmt_lib), NsUInteger,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeDataType(attr)
    ccall((:mtAttributeDataType, cmt_lib), MtDataType,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeActive(attr)
    ccall((:mtAttributeActive, cmt_lib), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIsPatchControlPointData(attr)
    ccall((:mtAttributeIsPatchControlPointData, cmt_lib), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtAttributeIsPatchData(attr)
    ccall((:mtAttributeIsPatchData, cmt_lib), Bool,
          (Ptr{MtAttribute},),
          attr)
end

function mtVertexAttributeName(attr)
    ccall((:mtVertexAttributeName, cmt_lib), Cstring,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIndex(attr)
    ccall((:mtVertexAttributeIndex, cmt_lib), NsUInteger,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeDataType(attr)
    ccall((:mtVertexAttributeDataType, cmt_lib), MtDataType,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeActive(attr)
    ccall((:mtVertexAttributeActive, cmt_lib), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIsPatchControlPointData(attr)
    ccall((:mtVertexAttributeIsPatchControlPointData, cmt_lib), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtVertexAttributeIsPatchData(attr)
    ccall((:mtVertexAttributeIsPatchData, cmt_lib), Bool,
          (Ptr{MtVertexAttribute},),
          attr)
end

function mtNewCompileOpts()
    ccall((:mtNewCompileOpts, cmt_lib), Ptr{MtCompileOptions}, ())
end

function mtCompileOptsRelease(opts)
    ccall((:mtCompileOptsRelease, cmt_lib), Cvoid,
          (Ptr{MtCompileOptions},),
          opts)
end

function mtCompileOptsFastMath(opts)
    ccall((:mtCompileOptsFastMath, cmt_lib), Bool,
          (Ptr{MtCompileOptions},),
          opts)
end

function mtCompileOptsFastMathSet(opts, val)
    ccall((:mtCompileOptsFastMathSet, cmt_lib), Cvoid,
          (Ptr{MtCompileOptions}, Bool),
          opts, val)
end

function mtCompileOptsLanguageVersion(opts)
    ccall((:mtCompileOptsLanguageVersion, cmt_lib), MtLanguageVersion,
          (Ptr{MtCompileOptions},),
          opts)
end

function mtCompileOptsLanguageVersionSet(opts, val)
    ccall((:mtCompileOptsLanguageVersionSet, cmt_lib), Cvoid,
          (Ptr{MtCompileOptions}, MtLanguageVersion),
          opts, val)
end

function mtFunctionConstantValuesSetWithIndex(funval, value, typ, idx)
    ccall((:mtFunctionConstantValuesSetWithIndex, cmt_lib), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsUInteger),
          funval, value, typ, idx)
end

function mtFunctionConstantValuesSetWithName(funval, value, typ, name)
    ccall((:mtFunctionConstantValuesSetWithName, cmt_lib), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, Cstring),
          funval, value, typ, name)
end

function mtFunctionConstantValuesSetWithRange(funval, value, typ, range)
    ccall((:mtFunctionConstantValuesSetWithRange, cmt_lib), Cvoid,
          (Ptr{MtFunctionConstantValues}, Ptr{Cvoid}, MtDataType, NsRange),
          funval, value, typ, range)
end

function mtFunctionConstantValuesReset(funval)
    ccall((:mtFunctionConstantValuesReset, cmt_lib), Cvoid,
          (Ptr{MtFunctionConstantValues},),
          funval)
end

function mtNewFunctionWithName(lib, name)
    ccall((:mtNewFunctionWithName, cmt_lib), Ptr{MtFunction},
          (Ptr{MtLibrary}, Cstring),
          lib, name)
end

function mtNewFunctionWithNameConstantValues(lib, name, constantValues, error)
    ccall((:mtNewFunctionWithNameConstantValues, cmt_lib), Ptr{MtFunction},
          (Ptr{MtLibrary}, Cstring, Ptr{MtFunctionConstantValues}, Ptr{Ptr{NsError}}),
          lib, name, constantValues, error)
end

function mtFunctionRelease(fun)
    ccall((:mtFunctionRelease, cmt_lib), Cvoid,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionDevice(fun)
    ccall((:mtFunctionDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionLabel(fun)
    ccall((:mtFunctionLabel, cmt_lib), Cstring,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionType(fun)
    ccall((:mtFunctionType, cmt_lib), MtFunctionType,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionName(fun)
    ccall((:mtFunctionName, cmt_lib), Cstring,
          (Ptr{MtFunction},),
          fun)
end

function mtFunctionStageInputAttributes(fun)
    ccall((:mtFunctionStageInputAttributes, cmt_lib), Ptr{Ptr{MtAttribute}},
          (Ptr{MtFunction},),
          fun)
end

function mtNewDefaultLibrary(device)
    ccall((:mtNewDefaultLibrary, cmt_lib), Ptr{MtLibrary},
          (Ptr{MtDevice},),
          device)
end

function mtNewLibraryWithFile(device, filepath, error)
    ccall((:mtNewLibraryWithFile, cmt_lib), Ptr{MtLibrary},
          (Ptr{MtDevice}, Cstring, Ptr{Ptr{NsError}}),
          device, filepath, error)
end

function mtNewLibraryWithSource(device, source, Opts, error)
    ccall((:mtNewLibraryWithSource, cmt_lib), Ptr{MtLibrary},
          (Ptr{MtDevice}, Cstring, Ptr{MtCompileOptions}, Ptr{Ptr{NsError}}),
          device, source, Opts, error)
end

function mtLibraryRelease(lib)
    ccall((:mtLibraryRelease, cmt_lib), Cvoid,
          (Ptr{MtLibrary},),
          lib)
end

function mtLibraryDevice(device)
    ccall((:mtLibraryDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtLibrary},),
          device)
end

function mtLibraryLabel(device)
    ccall((:mtLibraryLabel, cmt_lib), Cstring,
          (Ptr{MtLibrary},),
          device)
end

function mtLibraryFunctionNames(device)
    ccall((:mtLibraryFunctionNames, cmt_lib), Ptr{Cstring},
          (Ptr{MtLibrary},),
          device)
end

function mtBufferRelease(buf)
    ccall((:mtBufferRelease, cmt_lib), Cvoid,
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferContents(buf)
    ccall((:mtBufferContents, cmt_lib), Ptr{Cvoid},
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferLength(buf)
    ccall((:mtBufferLength, cmt_lib), NsUInteger,
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferDidModifyRange(buf, ran)
    ccall((:mtBufferDidModifyRange, cmt_lib), Cvoid,
          (Ptr{MtBuffer}, NsRange),
          buf, ran)
end

function mtBufferAddDebugMarkerRange(buf, string, range)
    ccall((:mtBufferAddDebugMarkerRange, cmt_lib), Cvoid,
          (Ptr{MtBuffer}, Cstring, NsRange),
          buf, string, range)
end

function mtBufferRemoveAllDebugMarkers(buf)
    ccall((:mtBufferRemoveAllDebugMarkers, cmt_lib), Cvoid,
          (Ptr{MtBuffer},),
          buf)
end

function mtBufferNewRemoteBufferViewForDevice(buf, device)
    ccall((:mtBufferNewRemoteBufferViewForDevice, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtBuffer}, Ptr{MtDevice}),
          buf, device)
end

function mtBufferRemoteStorageBuffer(buf)
    ccall((:mtBufferRemoteStorageBuffer, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtBuffer},),
          buf)
end

function mtNewHeapDescriptor()
    ccall((:mtNewHeapDescriptor, cmt_lib), Ptr{MtHeapDescriptor}, ())
end

function mtHeapDescriptorRelease(desc)
    ccall((:mtHeapDescriptorRelease, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor},),
          desc)
end

function mtHeapDescriptorType(heap)
    ccall((:mtHeapDescriptorType, cmt_lib), MtHeapType,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorTypeSet(heap, type)
    ccall((:mtHeapDescriptorTypeSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, MtHeapType),
          heap, type)
end

function mtHeapDescriptorStorageMode(heap)
    ccall((:mtHeapDescriptorStorageMode, cmt_lib), MtStorageMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorStorageModeSet(heap, mode)
    ccall((:mtHeapDescriptorStorageModeSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, MtStorageMode),
          heap, mode)
end

function mtHeapDescriptorCPUCacheMode(heap)
    ccall((:mtHeapDescriptorCPUCacheMode, cmt_lib), MtCPUCacheMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorCpuCacheModeSet(heap, mode)
    ccall((:mtHeapDescriptorCpuCacheModeSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, MtCPUCacheMode),
          heap, mode)
end

function mtHeapDescriptorHazardTrackingMode(heap)
    ccall((:mtHeapDescriptorHazardTrackingMode, cmt_lib), MtHazardTrackingMode,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorHazardTrackingModeSet(heap, mode)
    ccall((:mtHeapDescriptorHazardTrackingModeSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, MtHazardTrackingMode),
          heap, mode)
end

function mtHeapDescriptorResourceOptions(heap)
    ccall((:mtHeapDescriptorResourceOptions, cmt_lib), MtResourceOptions,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorResourceOptionsSet(heap, mode)
    ccall((:mtHeapDescriptorResourceOptionsSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, MtResourceOptions),
          heap, mode)
end

function mtHeapDescriptorSize(heap)
    ccall((:mtHeapDescriptorSize, cmt_lib), NsUInteger,
          (Ptr{MtHeapDescriptor},),
          heap)
end

function mtHeapDescriptorSizeSet(heap, size)
    ccall((:mtHeapDescriptorSizeSet, cmt_lib), Cvoid,
          (Ptr{MtHeapDescriptor}, NsUInteger),
          heap, size)
end

function mtDeviceNewHeapWithDescriptor(dev, descriptor)
    ccall((:mtDeviceNewHeapWithDescriptor, cmt_lib), Ptr{MtHeap},
          (Ptr{MtDevice}, Ptr{MtHeapDescriptor}),
          dev, descriptor)
end

function mtHeapRelease(heap)
    ccall((:mtHeapRelease, cmt_lib), Cvoid,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapDevice(heap)
    ccall((:mtHeapDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtHeap},),
          heap)
end

function mtHeapLabel(heap)
    ccall((:mtHeapLabel, cmt_lib), Cstring,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapType(heap)
    ccall((:mtHeapType, cmt_lib), MtHeapType,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapStorageMode(heap)
    ccall((:mtHeapStorageMode, cmt_lib), MtStorageMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapCPUCacheMode(heap)
    ccall((:mtHeapCPUCacheMode, cmt_lib), MtCPUCacheMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapHazardTrackingMode(heap)
    ccall((:mtHeapHazardTrackingMode, cmt_lib), MtHazardTrackingMode,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapResourceOptions(heap)
    ccall((:mtHeapResourceOptions, cmt_lib), MtResourceOptions,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapSize(heap)
    ccall((:mtHeapSize, cmt_lib), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapUsedSize(heap)
    ccall((:mtHeapUsedSize, cmt_lib), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapCurrentAllocatedSize(heap)
    ccall((:mtHeapCurrentAllocatedSize, cmt_lib), NsUInteger,
          (Ptr{MtHeap},),
          heap)
end

function mtHeapMaxAvailableSizeWithAlignment(heap, alignment)
    ccall((:mtHeapMaxAvailableSizeWithAlignment, cmt_lib), NsUInteger,
          (Ptr{MtHeap}, NsUInteger),
          heap, alignment)
end

function mtHeapSetPurgeableState(heap, state)
    ccall((:mtHeapSetPurgeableState, cmt_lib), MtPurgeableState,
          (Ptr{MtHeap}, MtPurgeableState),
          heap, state)
end

function mtHeapNewBufferWithLength(heap, len, opt)
    ccall((:mtHeapNewBufferWithLength, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtHeap}, NsUInteger, MtResourceOptions),
          heap, len, opt)
end

function mtHeapNewBufferWithLengthOffset(heap, len, opt, offset)
    ccall((:mtHeapNewBufferWithLengthOffset, cmt_lib), Ptr{MtBuffer},
          (Ptr{MtHeap}, NsUInteger, MtResourceOptions, NsUInteger),
          heap, len, opt, offset)
end

function mtHeapNewTextureWithDescriptor(heap, desc)
    ccall((:mtHeapNewTextureWithDescriptor, cmt_lib), Ptr{MtTexture},
          (Ptr{MtHeap}, Ptr{MtTextureDescriptor}),
          heap, desc)
end

function mtHeapNewTextureWithDescriptorOffset(heap, desc, offset)
    ccall((:mtHeapNewTextureWithDescriptorOffset, cmt_lib), Ptr{MtTexture},
          (Ptr{MtHeap}, Ptr{MtTextureDescriptor}, NsUInteger),
          heap, desc, offset)
end

function mtVertexDescNew()
    ccall((:mtVertexDescNew, cmt_lib), Ptr{MtVertexDescriptor}, ())
end

function mtVertexAttrib(vertex, attribIndex, format, offset, bufferIndex)
    ccall((:mtVertexAttrib, cmt_lib), Cvoid,
          (Ptr{MtVertexDescriptor}, UInt32, MtVertexFormat, UInt32, UInt32),
          vertex, attribIndex, format, offset, bufferIndex)
end

function mtVertexLayout(vertex, layoutIndex, stride, stepRate, stepFunction)
    ccall((:mtVertexLayout, cmt_lib), Cvoid,
          (Ptr{MtVertexDescriptor}, UInt32, UInt32, UInt32, MtVertexStepFunction),
          vertex, layoutIndex, stride, stepRate, stepFunction)
end

function mtSetVertexDesc(pipeline, vert)
    ccall((:mtSetVertexDesc, cmt_lib), Cvoid,
          (Ptr{MtRenderPipeline}, Ptr{MtVertexDescriptor}),
          pipeline, vert)
end

function mtDepthStencil(depthCompareFunc, depthWriteEnabled)
    ccall((:mtDepthStencil, cmt_lib), Ptr{MtDepthStencil},
          (MtCompareFunction, Bool),
          depthCompareFunc, depthWriteEnabled)
end

function mtNewPass()
    ccall((:mtNewPass, cmt_lib), Ptr{MtRenderPassDesc}, ())
end

function mtPassTexture(pass, colorAttch, tex)
    ccall((:mtPassTexture, cmt_lib), Cvoid,
          (Ptr{MtRenderPassDesc}, Cint, Ptr{MtTexture}),
          pass, colorAttch, tex)
end

function mtPassLoadAction(pass, colorAttch, action)
    ccall((:mtPassLoadAction, cmt_lib), Cvoid,
          (Ptr{MtRenderPassDesc}, Cint, MtLoadAction),
          pass, colorAttch, action)
end

function mtNewRenderPipeline(pixelFormat)
    ccall((:mtNewRenderPipeline, cmt_lib), Ptr{MtRenderDesc},
          (MtPixelFormat,),
          pixelFormat)
end

function mtSetFunc(pipDesc, func, functype)
    ccall((:mtSetFunc, cmt_lib), Cvoid,
          (Ptr{MtRenderDesc}, Ptr{MtFunction}, MtFuncType),
          pipDesc, func, functype)
end

function mtNewRenderState(device, pipDesc, error)
    ccall((:mtNewRenderState, cmt_lib), Ptr{MtRenderPipeline},
          (Ptr{MtDevice}, Ptr{MtRenderDesc}, Ptr{Ptr{NsError}}),
          device, pipDesc, error)
end

function mtColorPixelFormat(renderdesc, index, pixelFormat)
    ccall((:mtColorPixelFormat, cmt_lib), Cvoid,
          (Ptr{MtRenderDesc}, UInt32, MtPixelFormat),
          renderdesc, index, pixelFormat)
end

function mtDepthPixelFormat(renderdesc, pixelFormat)
    ccall((:mtDepthPixelFormat, cmt_lib), Cvoid,
          (Ptr{MtRenderDesc}, MtPixelFormat),
          renderdesc, pixelFormat)
end

function mtStencilPixelFormat(renderdesc, pixelFormat)
    ccall((:mtStencilPixelFormat, cmt_lib), Cvoid,
          (Ptr{MtRenderDesc}, MtPixelFormat),
          renderdesc, pixelFormat)
end

function mtSampleCount(renderdesc, sampleCount)
    ccall((:mtSampleCount, cmt_lib), Cvoid,
          (Ptr{MtRenderDesc}, UInt32),
          renderdesc, sampleCount)
end

function mtArgumentName(arg)
    ccall((:mtArgumentName, cmt_lib), Cstring,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentActive(arg)
    ccall((:mtArgumentActive, cmt_lib), Bool,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentIndex(arg)
    ccall((:mtArgumentIndex, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentType(arg)
    ccall((:mtArgumentType, cmt_lib), MtArgumentType,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentAccess(arg)
    ccall((:mtArgumentAccess, cmt_lib), MtArgumentAccess,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferAlignment(arg)
    ccall((:mtArgumentBufferAlignment, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferDataSize(arg)
    ccall((:mtArgumentBufferDataSize, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferDataType(arg)
    ccall((:mtArgumentBufferDataType, cmt_lib), MtDataType,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferStructType(arg)
    ccall((:mtArgumentBufferStructType, cmt_lib), Ptr{MtStructType},
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentBufferPointerType(arg)
    ccall((:mtArgumentBufferPointerType, cmt_lib), Ptr{MtPointerType},
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentArrayLength(arg)
    ccall((:mtArgumentArrayLength, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentThreadgroupMemoryAlignment(arg)
    ccall((:mtArgumentThreadgroupMemoryAlignment, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtArgumentThreadgroupMemoryDataSize(arg)
    ccall((:mtArgumentThreadgroupMemoryDataSize, cmt_lib), NsUInteger,
          (Ptr{MtArgument},),
          arg)
end

function mtNewComputePipelineReflection()
    ccall((:mtNewComputePipelineReflection, cmt_lib), Ptr{MtComputePipelineReflection}, ())
end

function mtComputePipelinereflectionArguments(refl)
    ccall((:mtComputePipelinereflectionArguments, cmt_lib), Ptr{MtArgument},
          (Ptr{MtComputePipelineReflection},),
          refl)
end

function mtPointerTypeElementType(ptr)
    ccall((:mtPointerTypeElementType, cmt_lib), MtDataType,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeAccess(ptr)
    ccall((:mtPointerTypeAccess, cmt_lib), MtArgumentAccess,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeAlignment(ptr)
    ccall((:mtPointerTypeAlignment, cmt_lib), NsUInteger,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeDataSize(ptr)
    ccall((:mtPointerTypeDataSize, cmt_lib), NsUInteger,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementIsArgumentBuffer(ptr)
    ccall((:mtPointerTypeElementIsArgumentBuffer, cmt_lib), Bool,
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementStructType(ptr)
    ccall((:mtPointerTypeElementStructType, cmt_lib), Ptr{MtStructType},
          (Ptr{MtPointerType},),
          ptr)
end

function mtPointerTypeElementArrayType(ptr)
    ccall((:mtPointerTypeElementArrayType, cmt_lib), Ptr{MtArrayType},
          (Ptr{MtPointerType},),
          ptr)
end

function mtNewCommandBuffer(cmdq)
    ccall((:mtNewCommandBuffer, cmt_lib), Ptr{MtCommandBuffer},
          (Ptr{MtCommandQueue},),
          cmdq)
end

function mtNewCommandBufferWithUnretainedReferences(cmdq)
    ccall((:mtNewCommandBufferWithUnretainedReferences, cmt_lib), Ptr{MtCommandBuffer},
          (Ptr{MtCommandQueue},),
          cmdq)
end

function mtCommandBufferOnComplete(cmdb, sender, oncomplete)
    ccall((:mtCommandBufferOnComplete, cmt_lib), Cvoid,
          (Ptr{MtCommandQueue}, Ptr{Cvoid}, MtCommandBufferOnCompleteFn),
          cmdb, sender, oncomplete)
end

function mtCommandBufferOnCompleteNoSender(cmdb, oncomplete)
    ccall((:mtCommandBufferOnCompleteNoSender, cmt_lib), Cvoid,
          (Ptr{MtCommandQueue}, MtCommandBufferOnCompleteFnNoSender),
          cmdb, oncomplete)
end

function mtCommandBufferRelease(cmdbuf)
    ccall((:mtCommandBufferRelease, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdbuf)
end

function mtCommandBufferPresentDrawable(cmdb, drawable)
    ccall((:mtCommandBufferPresentDrawable, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtDrawable}),
          cmdb, drawable)
end

function mtCommandBufferEqueue(cmdb)
    ccall((:mtCommandBufferEqueue, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferCommit(cmdb)
    ccall((:mtCommandBufferCommit, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferAddScheduledHandler(cmdb, handler)
    ccall((:mtCommandBufferAddScheduledHandler, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun),
          cmdb, handler)
end

function mtCommandBufferAddCompletedHandler(cmdb, handler)
    ccall((:mtCommandBufferAddCompletedHandler, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, MtCommandBufferHandlerFun),
          cmdb, handler)
end

function mtCommandBufferWaitUntilScheduled(cmdb)
    ccall((:mtCommandBufferWaitUntilScheduled, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferWaitUntilCompleted(cmdb)
    ccall((:mtCommandBufferWaitUntilCompleted, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferStatus(cmdb)
    ccall((:mtCommandBufferStatus, cmt_lib), MtCommandBufferStatus,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferError(cmdb)
    ccall((:mtCommandBufferError, cmt_lib), Ptr{NsError},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferKernelStartTime(cmdb)
    ccall((:mtCommandBufferKernelStartTime, cmt_lib), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferKernelEndTime(cmdb)
    ccall((:mtCommandBufferKernelEndTime, cmt_lib), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferGPUStartTime(cmdb)
    ccall((:mtCommandBufferGPUStartTime, cmt_lib), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferGPUEndTime(cmdb)
    ccall((:mtCommandBufferGPUEndTime, cmt_lib), CfTimeInterval,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferEncodeSignalEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeSignalEvent, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64),
          cmdb, event, val)
end

function mtCommandBufferEncodeWaitForEvent(cmdb, event, val)
    ccall((:mtCommandBufferEncodeWaitForEvent, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, Ptr{MtEvent}, UInt64),
          cmdb, event, val)
end

function mtCommandBufferRetainedReferences(cmdb)
    ccall((:mtCommandBufferRetainedReferences, cmt_lib), Bool,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferDevice(cmdb)
    ccall((:mtCommandBufferDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferCommandQueue(cmdb)
    ccall((:mtCommandBufferCommandQueue, cmt_lib), Ptr{MtCommandQueue},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferLabel(cmdb)
    ccall((:mtCommandBufferLabel, cmt_lib), Cstring,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtCommandBufferPushDebugGroup(cmdb, str)
    ccall((:mtCommandBufferPushDebugGroup, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer}, Cstring),
          cmdb, str)
end

function mtCommandBufferPopDebugGroup(cmdb)
    ccall((:mtCommandBufferPopDebugGroup, cmt_lib), Cvoid,
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtNewIndirectCommandBuffer(device, desc, maxCount, options)
    ccall((:mtNewIndirectCommandBuffer, cmt_lib), Ptr{MtIndirectCommandBuffer},
          (Ptr{MtDevice}, Ptr{MtIndirectCommandBufferDescriptor}, NsUInteger,
           MtResourceOptions),
          device, desc, maxCount, options)
end

function mtIndirectCommandBufferSize(icb)
    ccall((:mtIndirectCommandBufferSize, cmt_lib), NsUInteger,
          (Ptr{MtIndirectCommandBuffer},),
          icb)
end

function mtIndirectCommandBufferComputeCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferComputeCommandAtIndex, cmt_lib), Ptr{MtIndirectComputeCommand},
          (Ptr{MtIndirectCommandBuffer}, NsUInteger),
          icb, index)
end

function mtIndirectCommandBufferRenderCommandAtIndex(icb, index)
    ccall((:mtIndirectCommandBufferRenderCommandAtIndex, cmt_lib), Ptr{MtIndirectRenderCommand},
          (Ptr{MtIndirectCommandBuffer}, NsUInteger),
          icb, index)
end

function mtIndirectCommandBufferResetWithRange(icb, range)
    ccall((:mtIndirectCommandBufferResetWithRange, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, NsRange),
          icb, range)
end

function mtCommandEncoderEndEncoding(ce)
    ccall((:mtCommandEncoderEndEncoding, cmt_lib), Cvoid,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderDevice(ce)
    ccall((:mtCommandEncoderDevice, cmt_lib), Ptr{MtDevice},
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderLabel(ce)
    ccall((:mtCommandEncoderLabel, cmt_lib), Cstring,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtCommandEncoderInsertDebugSignpost(ce, string)
    ccall((:mtCommandEncoderInsertDebugSignpost, cmt_lib), Cvoid,
          (Ptr{MtCommandEncoder}, Cstring),
          ce, string)
end

function mtCommandEncoderPushDebugGroup(ce, string)
    ccall((:mtCommandEncoderPushDebugGroup, cmt_lib), Cvoid,
          (Ptr{MtCommandEncoder}, Cstring),
          ce, string)
end

function mtCommandEncoderPopDebugGroup(ce)
    ccall((:mtCommandEncoderPopDebugGroup, cmt_lib), Cvoid,
          (Ptr{MtCommandEncoder},),
          ce)
end

function mtNewBlitCommandEncoder(cmdb)
    ccall((:mtNewBlitCommandEncoder, cmt_lib), Ptr{MtBlitCommandEncoder},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtBlitCommandEncoderCopyFromBufferToBuffer(bce, src, src_offset, dst, dst_offset,
                                                    size)
    ccall((:mtBlitCommandEncoderCopyFromBufferToBuffer, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsUInteger, Ptr{MtBuffer},
           NsUInteger, NsUInteger),
          bce, src, src_offset, dst, dst_offset, size)
end

function mtBlitCommandEncoderFillBuffer(bce, src, range, val)
    ccall((:mtBlitCommandEncoderFillBuffer, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtBuffer}, NsRange, UInt8),
          bce, src, range, val)
end

function mtBlitCommandEncoderGenerateMipmaps(bce, texture)
    ccall((:mtBlitCommandEncoderGenerateMipmaps, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}),
          bce, texture)
end

function mtBlitCommandEncoderCopyIndirectCommandBuffer(bce, src, range, dst, dst_index)
    ccall((:mtBlitCommandEncoderCopyIndirectCommandBuffer, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange,
           Ptr{MtIndirectCommandBuffer}, NsUInteger),
          bce, src, range, dst, dst_index)
end

function mtBlitCommandEncoderOptimizeIndirectCommandBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderOptimizeIndirectCommandBuffer, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange),
          bce, buffer, range)
end

function mtBlitCommandEncoderResetCommandsInBuffer(bce, buffer, range)
    ccall((:mtBlitCommandEncoderResetCommandsInBuffer, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtIndirectCommandBuffer}, NsRange),
          bce, buffer, range)
end

function mtBlitCommandEncoderSynchronizeResource(bce, resource)
    ccall((:mtBlitCommandEncoderSynchronizeResource, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtResource}),
          bce, resource)
end

function mtBlitCommandEncoderSynchronizeTexture(bce, texture, slice, level)
    ccall((:mtBlitCommandEncoderSynchronizeTexture, cmt_lib), Cvoid,
          (Ptr{MtBlitCommandEncoder}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          bce, texture, slice, level)
end

function mtBlitCommandEncoderUpdateFence(icb, fence)
    ccall((:mtBlitCommandEncoderUpdateFence, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}),
          icb, fence)
end

function mtBlitCommandEncoderWaitForFence(icb, fence)
    ccall((:mtBlitCommandEncoderWaitForFence, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtFence}),
          icb, fence)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccess, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}),
          icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForGPUAccessSliceLevel, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          icb, tex, slice, level)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccess(icb, tex)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccess, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}),
          icb, tex)
end

function mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel(icb, tex, slice, level)
    ccall((:mtBlitCommandEncoderOptimizeContentsForCPUAccessSliceLevel, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtTexture}, NsUInteger, NsUInteger),
          icb, tex, slice, level)
end

function mtBlitCommandEncoderSampleCountersInBuffer(icb, sbuf, sampleindex, barrier)
    ccall((:mtBlitCommandEncoderSampleCountersInBuffer, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsUInteger, Bool),
          icb, sbuf, sampleindex, barrier)
end

function mtBlitCommandEncoderResolveCounters(icb, sbuf, range, dst, dst_offset)
    ccall((:mtBlitCommandEncoderResolveCounters, cmt_lib), Cvoid,
          (Ptr{MtIndirectCommandBuffer}, Ptr{MtCounterSampleBuffer}, NsRange,
           Ptr{MtBuffer}, NsUInteger),
          icb, sbuf, range, dst, dst_offset)
end

function mtNewComputeCommandEncoder(cmdb)
    ccall((:mtNewComputeCommandEncoder, cmt_lib), Ptr{MtComputeCommandEncoder},
          (Ptr{MtCommandBuffer},),
          cmdb)
end

function mtNewComputeCommandEncoderWithDispatchType(cmdb, dtype)
    ccall((:mtNewComputeCommandEncoderWithDispatchType, cmt_lib), Ptr{MtComputeCommandEncoder},
          (Ptr{MtCommandBuffer}, MtDispatchType),
          cmdb, dtype)
end

function mtComputeCommandEncoderRelease(cce)
    ccall((:mtComputeCommandEncoderRelease, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder},),
          cce)
end

function mtComputeCommandEncoderEndEncoding(cce)
    ccall((:mtComputeCommandEncoderEndEncoding, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder},),
          cce)
end

function mtComputeCommandEncoderSetComputePipelineState(cce, state)
    ccall((:mtComputeCommandEncoderSetComputePipelineState, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtComputePipelineState}),
          cce, state)
end

function mtComputeCommandEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtComputeCommandEncoderSetBufferOffsetAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, offset, indx)
end

function mtComputeCommandEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtComputeCommandEncoderSetBuffersOffsetsWithRange, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange),
          cce, bufs, offsets, range)
end

function mtComputeCommandEncoderBufferSetOffsetAtIndex(cce, offset, indx)
    ccall((:mtComputeCommandEncoderBufferSetOffsetAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger),
          cce, offset, indx)
end

function mtComputeCommandEncoderSetBytesLengthAtIndex(cce, ptr, length, indx)
    ccall((:mtComputeCommandEncoderSetBytesLengthAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Cvoid}, NsUInteger, NsUInteger),
          cce, ptr, length, indx)
end

function mtComputeCommandEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, NsUInteger),
          cce, sampler, indx)
end

function mtComputeCommandEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtComputeCommandEncoderSetSamplerStatesWithRange, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange),
          cce, samplers, range)
end

function mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex(cce, sampler,
                                                                             lodMinClamp,
                                                                             lodMaxClamp,
                                                                             indx)
    ccall((:mtComputeCommandEncoderSetSamplerStateLodMinClampLodMaxClampAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtSamplerState}, Cfloat, Cfloat, NsUInteger),
          cce, sampler, lodMinClamp, lodMaxClamp, indx)
end

function mtComputeCommandEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtComputeCommandEncoderSetTextureAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtTexture}, NsUInteger),
          cce, tex, indx)
end

function mtComputeCommandEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtComputeCommandEncoderSetTexturesWithRange, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtTexture}}, NsRange),
          cce, textures, range)
end

function mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex(cce, length, indx)
    ccall((:mtComputeCommandEncoderSetThreadgroupMemoryLengthAtIndex, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, NsUInteger, NsUInteger),
          cce, length, indx)
end

function mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(cce,
                                                                           threadgroupsPerGrid,
                                                                           threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtSize, MtSize),
          cce, threadgroupsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup(cce, threadsPerGrid,
                                                                     threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThread_threadsPerThreadgroup, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtSize, MtSize),
          cce, threadsPerGrid, threadsPerThreadgroup)
end

function mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup(cce,
                                                                                                                  indirectBuffer,
                                                                                                                  indirectBufferOffset,
                                                                                                                  threadsPerThreadgroup)
    ccall((:mtComputeCommandEncoderDispatchThreadgroupsWithIndirectBuffer_IndirectBufferOffset_threadsPerThreadgroup, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger, MtSize),
          cce, indirectBuffer, indirectBufferOffset, threadsPerThreadgroup)
end

function mtComputeCommandEncoderUseResourceUsage(cce, res, usage)
    ccall((:mtComputeCommandEncoderUseResourceUsage, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtResource}, MtResourceUsage),
          cce, res, usage)
end

function mtComputeCommandEncoderUseResourcesCountUsage(cce, res, count, usage)
    ccall((:mtComputeCommandEncoderUseResourcesCountUsage, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger, MtResourceUsage),
          cce, res, count, usage)
end

function mtComputeCommandEncoderUseHeap(cce, heap)
    ccall((:mtComputeCommandEncoderUseHeap, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtHeap}),
          cce, heap)
end

function mtComputeCommandEncoderUseHeaps(cce, heaps, count)
    ccall((:mtComputeCommandEncoderUseHeaps, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtHeap}}, NsUInteger),
          cce, heaps, count)
end

function mtComputeCommandEncoderSetStageInRegion(cce, region)
    ccall((:mtComputeCommandEncoderSetStageInRegion, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtRegion),
          cce, region)
end

function mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer(cce, buf, offset)
    ccall((:mtComputeCommandEncoderSetStageInRegionWithIndirectBuffer, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{MtBuffer}, NsUInteger),
          cce, buf, offset)
end

function mtComputeCommandEncoderDispatchType(cce)
    ccall((:mtComputeCommandEncoderDispatchType, cmt_lib), MtDispatchType,
          (Ptr{MtComputeCommandEncoder},),
          cce)
end

function mtComputeCommandEncoderMemoryBarrierWithScope(cce, scope)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithScope, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, MtBarrierScope),
          cce, scope)
end

function mtComputeCommandEncoderMemoryBarrierWithResource(cce, resources, count)
    ccall((:mtComputeCommandEncoderMemoryBarrierWithResource, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger),
          cce, resources, count)
end

function mtComputeCommandEncoderExecuteCommandInBuffer(cce, resources, count)
    ccall((:mtComputeCommandEncoderExecuteCommandInBuffer, cmt_lib), Cvoid,
          (Ptr{MtComputeCommandEncoder}, Ptr{Ptr{MtResource}}, NsUInteger),
          cce, resources, count)
end

function mtNewRenderCommandEncoder(cmdb, pass)
    ccall((:mtNewRenderCommandEncoder, cmt_lib), Ptr{MtRenderCommandEncoder},
          (Ptr{MtCommandBuffer}, Ptr{MtRenderPassDesc}),
          cmdb, pass)
end

function mtFrontFace(rce, winding)
    ccall((:mtFrontFace, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtWinding),
          rce, winding)
end

function mtCullMode(rce, mode)
    ccall((:mtCullMode, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtCullMode),
          rce, mode)
end

function mtViewport(rce, viewport)
    ccall((:mtViewport, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtViewport}),
          rce, viewport)
end

function mtSetRenderState(rce, pipline)
    ccall((:mtSetRenderState, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtRenderPipeline}),
          rce, pipline)
end

function mtSetDepthStencil(rce, ds)
    ccall((:mtSetDepthStencil, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtDepthStencil}),
          rce, ds)
end

function mtVertexBytes(rce, bytes, legth, atIndex)
    ccall((:mtVertexBytes, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{Cvoid}, Csize_t, UInt32),
          rce, bytes, legth, atIndex)
end

function mtVertexBuffer(rce, buf, off, index)
    ccall((:mtVertexBuffer, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32),
          rce, buf, off, index)
end

function mtFragmentBuffer(rce, buf, off, index)
    ccall((:mtFragmentBuffer, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, Ptr{MtBuffer}, Csize_t, UInt32),
          rce, buf, off, index)
end

function mtDrawPrims(rce, type, start, count)
    ccall((:mtDrawPrims, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, Csize_t, Csize_t),
          rce, type, start, count)
end

function mtDrawIndexedPrims(rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
    ccall((:mtDrawIndexedPrims, cmt_lib), Cvoid,
          (Ptr{MtRenderCommandEncoder}, MtPrimitiveType, UInt32, MtIndexType,
           Ptr{MtBuffer}, UInt32),
          rce, type, indexCount, indexType, indexBuffer, indexBufferOffset)
end

function mtNewCommandQueue(device)
    ccall((:mtNewCommandQueue, cmt_lib), Ptr{MtCommandQueue},
          (Ptr{MtDevice},),
          device)
end

function mtNewCommandQueueWithMaxCommandBufferCount(device, count)
    ccall((:mtNewCommandQueueWithMaxCommandBufferCount, cmt_lib), Ptr{MtCommandQueue},
          (Ptr{MtDevice}, NsUInteger),
          device, count)
end

function mtCommandQueueRelease(queue)
    ccall((:mtCommandQueueRelease, cmt_lib), Cvoid,
          (Ptr{MtCommandQueue},),
          queue)
end

function mtNewArgumentDescriptor()
    ccall((:mtNewArgumentDescriptor, cmt_lib), Ptr{MtArgumentDescriptor}, ())
end

function mtArgumentDescriptorDataType(desc)
    ccall((:mtArgumentDescriptorDataType, cmt_lib), MtDataType,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorDataTypeSet(desc, dataType)
    ccall((:mtArgumentDescriptorDataTypeSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtDataType),
          desc, dataType)
end

function mtArgumentDescriptorIndex(desc)
    ccall((:mtArgumentDescriptorIndex, cmt_lib), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorIndexSet(desc, index)
    ccall((:mtArgumentDescriptorIndexSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, index)
end

function mtArgumentDescriptorAccess(desc)
    ccall((:mtArgumentDescriptorAccess, cmt_lib), MtArgumentAccess,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorAccessSet(desc, access)
    ccall((:mtArgumentDescriptorAccessSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtArgumentAccess),
          desc, access)
end

function mtArgumentDescriptorArrayLength(desc)
    ccall((:mtArgumentDescriptorArrayLength, cmt_lib), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorArrayLengthSet(desc, length)
    ccall((:mtArgumentDescriptorArrayLengthSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, length)
end

function mtArgumentDescriptorConstantBlockAlignment(desc)
    ccall((:mtArgumentDescriptorConstantBlockAlignment, cmt_lib), NsUInteger,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorConstantBlockAlignmentSet(desc, alignment)
    ccall((:mtArgumentDescriptorConstantBlockAlignmentSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, NsUInteger),
          desc, alignment)
end

function mtArgumentDescriptorTextureType(desc)
    ccall((:mtArgumentDescriptorTextureType, cmt_lib), MtTextureType,
          (Ptr{MtArgumentDescriptor},),
          desc)
end

function mtArgumentDescriptorTextureTypeSet(desc, textype)
    ccall((:mtArgumentDescriptorTextureTypeSet, cmt_lib), Cvoid,
          (Ptr{MtArgumentDescriptor}, MtTextureType),
          desc, textype)
end

function mtNewArgumentEncoderWithBufferIndexFromFunction(_function, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromFunction, cmt_lib), Ptr{MtArgumentEncoder},
          (Ptr{MtFunction}, NsUInteger),
          _function, bufferIndex)
end

function mtNewArgumentEncoderWithBufferIndexReflectionFromFunction(_function, bufferIndex,
                                                                   reflection)
    ccall((:mtNewArgumentEncoderWithBufferIndexReflectionFromFunction, cmt_lib), Ptr{MtArgumentEncoder},
          (Ptr{MtFunction}, NsUInteger, Ptr{MtAutoreleasedArgument}),
          _function, bufferIndex, reflection)
end

function mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer(ae, bufferIndex)
    ccall((:mtNewArgumentEncoderWithBufferIndexFromArgumentBuffer, cmt_lib), Ptr{MtArgumentEncoder},
          (Ptr{MtArgumentEncoder}, NsUInteger),
          ae, bufferIndex)
end

function mtNewArgumentEncoder(device, arguments, count)
    ccall((:mtNewArgumentEncoder, cmt_lib), Ptr{MtArgumentEncoder},
          (Ptr{MtDevice}, Ptr{Ptr{MtArgumentDescriptor}}, UInt64),
          device, arguments, count)
end

function mtArgumentEncoderLength(encoder)
    ccall((:mtArgumentEncoderLength, cmt_lib), NsUInteger,
          (Ptr{MtArgumentEncoder},),
          encoder)
end

function mtArgumentEncoderSetArgumentBufferWithOffset(cce, buf, offset)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffset, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger),
          cce, buf, offset)
end

function mtArgumentEncoderSetArgumentBufferWithOffsetForElement(cce, buf, startOffset,
                                                                arrayElement)
    ccall((:mtArgumentEncoderSetArgumentBufferWithOffsetForElement, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, startOffset, arrayElement)
end

function mtArgumentEncoderSetBufferOffsetAtIndex(cce, buf, offset, indx)
    ccall((:mtArgumentEncoderSetBufferOffsetAtIndex, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtBuffer}, NsUInteger, NsUInteger),
          cce, buf, offset, indx)
end

function mtArgumentEncoderSetBuffersOffsetsWithRange(cce, bufs, offsets, range)
    ccall((:mtArgumentEncoderSetBuffersOffsetsWithRange, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtBuffer}}, Ptr{NsUInteger}, NsRange),
          cce, bufs, offsets, range)
end

function mtArgumentEncoderSetTextureAtIndex(cce, tex, indx)
    ccall((:mtArgumentEncoderSetTextureAtIndex, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtTexture}, NsUInteger),
          cce, tex, indx)
end

function mtArgumentEncoderSetTexturesWithRange(cce, textures, range)
    ccall((:mtArgumentEncoderSetTexturesWithRange, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtTexture}}, NsRange),
          cce, textures, range)
end

function mtArgumentEncoderSetSamplerStateAtIndex(cce, sampler, indx)
    ccall((:mtArgumentEncoderSetSamplerStateAtIndex, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtSamplerState}, NsUInteger),
          cce, sampler, indx)
end

function mtArgumentEncoderSetSamplerStatesWithRange(cce, samplers, range)
    ccall((:mtArgumentEncoderSetSamplerStatesWithRange, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtSamplerState}}, NsRange),
          cce, samplers, range)
end

function mtArgumentEncoderConstantDataAtIndex(cce, index)
    ccall((:mtArgumentEncoderConstantDataAtIndex, cmt_lib), Ptr{Cvoid},
          (Ptr{MtArgumentEncoder}, NsUInteger),
          cce, index)
end

function mtArgumentEncoderSetIndirectCommandBuffer(cce, cbuf, index)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffer, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{MtIndirectCommandBuffer}, NsUInteger),
          cce, cbuf, index)
end

function mtArgumentEncoderSetIndirectCommandBuffers(cce, cbufs, range)
    ccall((:mtArgumentEncoderSetIndirectCommandBuffers, cmt_lib), Cvoid,
          (Ptr{MtArgumentEncoder}, Ptr{Ptr{MtIndirectCommandBuffer}}, NsRange),
          cce, cbufs, range)
end

function mtArgumentEncoderAlignment(cce)
    ccall((:mtArgumentEncoderAlignment, cmt_lib), NsUInteger,
          (Ptr{MtArgumentEncoder},),
          cce)
end

function mtRetain(obj)
    ccall((:mtRetain, cmt_lib), Ptr{Cvoid},
          (Ptr{Cvoid},),
          obj)
end

function mtRelease(obj)
    ccall((:mtRelease, cmt_lib), Cvoid,
          (Ptr{Cvoid},),
          obj)
end
