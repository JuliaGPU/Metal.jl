/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/device.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtDevice*
mtCreateSystemDefaultDevice() {
  return MTLCreateSystemDefaultDevice();
}

CF_RETURNS_RETAINED
MT_EXPORT
MtDevice**
mtCopyAllDevices() {
  NSArray<id<MTLDevice>> * _devices = MTLCopyAllDevices();

  NSRange copyRange = NSMakeRange(0, [_devices count]);
  id<MTLDevice> *devices = malloc(sizeof(id<MTLDevice>) * (copyRange.length + 1));

  [_devices getObjects:devices range:copyRange];
  devices[copyRange.length] = NULL;

  return (MtDevice**)(devices);
}

CF_RETURNS_RETAINED
MT_EXPORT
const char*
mtDeviceName(MtDevice* device) {
  return [[(id<MTLDevice>)device name] cStringUsingEncoding:NSUTF8StringEncoding];
}

MT_EXPORT
bool
mtDeviceHeadless(MtDevice* device) {
	return [(id<MTLDevice>)device isHeadless];
}

MT_EXPORT
bool
mtDeviceLowPower(MtDevice* device) {
	return [(id<MTLDevice>)device isLowPower];
}

MT_EXPORT
bool
mtDeviceRemovable(MtDevice* device) {
	return [(id<MTLDevice>)device isRemovable];
}

MT_EXPORT
uint64_t
mtDeviceRegistryID(MtDevice* device) {
	return [(id<MTLDevice>)device registryID];
}

MT_EXPORT
MtDeviceLocation
mtDeviceLocation(MtDevice* device) {
	return MtDeviceLocationExternal;//[(id<MTLDevice>)device location];
}

MT_EXPORT
uint64_t
mtDeviceLocationNumber(MtDevice* device) {
	return [(id<MTLDevice>)device locationNumber];
}

MT_EXPORT
uint64_t
mtDeviceMaxTransferRate(MtDevice* device) {
	return [(id<MTLDevice>)device maxTransferRate];
}

MT_EXPORT
bool
mtDeviceHasUnifiedMemory(MtDevice* device) {
	return [(id<MTLDevice>)device hasUnifiedMemory];
}

// Querying Memory Availability and Limits 3/3

MT_EXPORT
uint64_t
mtDeviceRecommendedMaxWorkingSetSize(MtDevice* device) {
	return [(id<MTLDevice>)device recommendedMaxWorkingSetSize];
}

MT_EXPORT
NsUInteger
mtDeviceCurrentAllocatedSize(MtDevice* device) {
	return [(id<MTLDevice>)device currentAllocatedSize];
}

MT_EXPORT
NsUInteger
mtDeviceMaxThreadgroupMemoryLength(MtDevice* device) {
	return [(id<MTLDevice>)device maxThreadgroupMemoryLength];
}

// Querying Threadgroup Limits 1/1
MT_EXPORT
MtSize
mtMaxThreadsPerThreadgroup(MtDevice* device) {
	return mtSize([(id<MTLDevice>)device maxThreadsPerThreadgroup]);
}

MT_EXPORT
uint64_t
mtDevicePeerGroupID(MtDevice *device) {
	return [(id<MTLDevice>)device peerGroupID];
}

MT_EXPORT
uint32_t
mtDevicePeerCount(MtDevice *device) {
	return[(id<MTLDevice>)device peerCount];
}

MT_EXPORT
uint32_t
mtDevicePeerIndex(MtDevice *device) {
	return [(id<MTLDevice>)device peerIndex];
}

//
MT_EXPORT
bool
mtDeviceSupportsFamily(MtDevice *device, MtGPUFamily family) {
	return [(id<MTLDevice>)device supportsFamily: (MTLGPUFamily)family];
}

MT_EXPORT
bool
mtDeviceSupportsFeatureSet(MtDevice *device, MtFeatureSet set) {
	return [(id<MTLDevice>)device supportsFeatureSet: (MTLFeatureSet)set];
}

// Buffers
MT_EXPORT
NsUInteger
mtDeviceMaxBufferLength(MtDevice *device) {
	return [(id<MTLDevice>)device maxBufferLength]; 
}

CF_RETURNS_RETAINED
MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithLength(MtDevice *device, NsUInteger length, MtResourceOptions opts) {
	return [(id<MTLDevice>)device 
					newBufferWithLength: length 
					options: (MTLResourceOptions)opts];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtCommandBuffer*
mtDeviceNewBufferWithBytes(MtDevice      * __restrict device,
	                     const void * __restrict ptr,
	                     NsUInteger                  len,
	                     MtResourceOptions       options) {
  return [(id<MTLDevice>)device
          newBufferWithBytes: ptr
          length:             len
          options:            (MTLResourceOptions)options];
}


MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithBytesNoCopy(MtDevice * __restrict device, 
							   void * ptr, 
							   NsUInteger length, 
							   MtResourceOptions opts) {
	return [(id<MTLDevice>)device newBufferWithBytesNoCopy: ptr 
                                   					length: length 
                                  				   options: (MTLResourceOptions)opts 
                              				   deallocator: nil];
}

/*
MT_EXPORT
MtBuffer*
mtDeviceNewBufferWithBytesNoCopyDeallocator(MtDevice *device, const void* ptr, NsUInteger length, MtResourceOptions opts) {
	return [(id<MTLDevice>)device newBufferWithBytesNoCopy: ptr 
                                   					length: length 
                                  				   options: (MTLResourceOptions)opts 
                              				   deallocator: nil];
}*/
