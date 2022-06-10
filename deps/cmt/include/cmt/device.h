/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_device_h
#define cmt_device_h
#ifdef __cplusplus
extern "C" {
#endif

#include "common.h"
#include "types.h"
#include "enums.h"
#include "error.h"
#include "resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtCreateSystemDefaultDevice(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCopyAllDevices(size_t *count, MtDevice** devices);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtDeviceName(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceHeadless(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceLowPower(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_macCatalyst(13.0))
MT_API_UNAVAILABLE(mt_ios)
bool
mtDeviceRemovable(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
uint64_t
mtDeviceRegistryID(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDeviceLocation
mtDeviceLocation(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceLocationNumber(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceMaxTransferRate(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
bool
mtDeviceHasUnifiedMemory(MtDevice*);

// peers
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint64_t
mtDevicePeerGroupID(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint32_t
mtDevicePeerCount(MtDevice*);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint32_t
mtDevicePeerIndex(MtDevice*);

// level
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
bool
mtDeviceSupportsFamily(MtDevice *device, MtGPUFamily family);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceSupportsFeatureSet(MtDevice *device, MtFeatureSet set);

//
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_macCatalyst(13.0))
MT_API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceRecommendedMaxWorkingSetSize(MtDevice* device);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtDeviceCurrentAllocatedSize(MtDevice* device);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtDeviceMaxThreadgroupMemoryLength(MtDevice* device);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtSize
mtMaxThreadsPerThreadgroup(MtDevice* device);

// Buffers
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
NsUInteger
mtDeviceMaxBufferLength(MtDevice *device);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtBuffer*
mtDeviceNewBufferWithLength(MtDevice *device, NsUInteger length, MtResourceOptions opts);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtBuffer*
mtDeviceNewBufferWithBytes(MtDevice *device, const void* ptr, NsUInteger length, MtResourceOptions opts);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtBuffer*
mtDeviceNewBufferWithBytesNoCopy(MtDevice *device, void* ptr, NsUInteger length, MtResourceOptions opts);

//MT_EXPORT
//MtBuffer*
//mtDeviceNewBufferWithBytesNoCopyDeallocator(MtDevice *device, void* ptr, NsUInteger length, MtResourceOptions opts);

#ifdef __cplusplus
}
#endif
#endif /* cmt_device_h */
