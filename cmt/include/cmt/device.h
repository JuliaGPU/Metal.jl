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
MtDevice*
mtCreateSystemDefaultDevice(void);

MT_EXPORT
MtDevice**
mtCopyAllDevices(void);

MT_EXPORT
const char*
mtDeviceName(MtDevice*);

MT_EXPORT
bool
mtDeviceHeadless(MtDevice*);

MT_EXPORT
bool
mtDeviceLowPower(MtDevice*);

MT_EXPORT
bool
mtDeviceRemovable(MtDevice*);

MT_EXPORT
uint64_t
mtDeviceRegistryID(MtDevice*);

MT_EXPORT
MtDeviceLocation
mtDeviceLocation(MtDevice*);

MT_EXPORT
uint64_t
mtDeviceLocationNumber(MtDevice*);

MT_EXPORT
uint64_t
mtDeviceMaxTransferRate(MtDevice*);

MT_EXPORT
bool
mtDeviceHasUnifiedMemory(MtDevice*);

// peers
MT_EXPORT
uint64_t
mtDevicePeerGroupID(MtDevice*);

MT_EXPORT
uint32_t
mtDevicePeerCount(MtDevice*);

MT_EXPORT
uint32_t
mtDevicePeerIndex(MtDevice*);

// level
MT_EXPORT
bool
mtDeviceSupportsFamily(MtDevice *device, MtGPUFamily family);

MT_EXPORT
bool
mtDeviceSupportsFeatureSet(MtDevice *device, MtFeatureSet set);

//
MT_EXPORT
uint64_t
mtDeviceRecommendedMaxWorkingSetSize(MtDevice* device);

MT_EXPORT
NsUInteger
mtDeviceCurrentAllocatedSize(MtDevice* device);

MT_EXPORT
NsUInteger
mtDeviceMaxThreadgroupMemoryLength(MtDevice* device);

MT_EXPORT
MtSize
mtMaxThreadsPerThreadgroup(MtDevice* device);

// Buffers
MT_EXPORT
NsUInteger
mtDeviceMaxBufferLength(MtDevice *device);

MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithLength(MtDevice *device, NsUInteger length, MtResourceOptions opts);

MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithBytes(MtDevice *device, const void* ptr, NsUInteger length, MtResourceOptions opts);

MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithBytesNoCopy(MtDevice *device, void* ptr, NsUInteger length, MtResourceOptions opts);

//MT_EXPORT
//MtBuffer*
//mtDeviceNewBufferWithBytesNoCopyDeallocator(MtDevice *device, void* ptr, NsUInteger length, MtResourceOptions opts);

#ifdef __cplusplus
}
#endif
#endif /* cmt_device_h */
