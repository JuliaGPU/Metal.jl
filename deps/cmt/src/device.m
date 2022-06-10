/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/device.h"


// Acquiring Device Objects

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtCreateSystemDefaultDevice() {
  return MTLCreateSystemDefaultDevice();
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCopyAllDevices(size_t* count, MtDevice** devices) {
  NSArray<id<MTLDevice>> * _devices = MTLCopyAllDevices();
  NSInteger n = [_devices count];

  if (*count == 0) {
	  *count = n;
  } else {
	  assert(*count <= n);
	  for (int i=0; i < *count; i++)
		devices[i] = [_devices objectAtIndex:i];
  }

  return;
}


// Querying GPU Properties

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtDeviceName(MtDevice* device) {
  return [[(id<MTLDevice>)device name] cStringUsingEncoding:NSUTF8StringEncoding];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceHeadless(MtDevice* device) {
	return [(id<MTLDevice>)device isHeadless];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceLowPower(MtDevice* device) {
	return [(id<MTLDevice>)device isLowPower];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_macCatalyst(13.0))
MT_API_UNAVAILABLE(mt_ios)
bool
mtDeviceRemovable(MtDevice* device) {
	return [(id<MTLDevice>)device isRemovable];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
uint64_t
mtDeviceRegistryID(MtDevice* device) {
	return [(id<MTLDevice>)device registryID];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDeviceLocation
mtDeviceLocation(MtDevice* device) {
	return MtDeviceLocationExternal;//[(id<MTLDevice>)device location];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceLocationNumber(MtDevice* device) {
	return [(id<MTLDevice>)device locationNumber];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceMaxTransferRate(MtDevice* device) {
	return [(id<MTLDevice>)device maxTransferRate];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
bool
mtDeviceHasUnifiedMemory(MtDevice* device) {
	return [(id<MTLDevice>)device hasUnifiedMemory];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_macCatalyst(13.0))
MT_API_UNAVAILABLE(mt_ios)
uint64_t
mtDeviceRecommendedMaxWorkingSetSize(MtDevice* device) {
	return [(id<MTLDevice>)device recommendedMaxWorkingSetSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtDeviceCurrentAllocatedSize(MtDevice* device) {
	return [(id<MTLDevice>)device currentAllocatedSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtDeviceMaxThreadgroupMemoryLength(MtDevice* device) {
	return [(id<MTLDevice>)device maxThreadgroupMemoryLength];
}


// Determining Threadgroup Limits

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtSize
mtMaxThreadsPerThreadgroup(MtDevice* device) {
	return mtSize([(id<MTLDevice>)device maxThreadsPerThreadgroup]);
}


// Finding Groups of Connected GPUs

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint64_t
mtDevicePeerGroupID(MtDevice *device) {
	return [(id<MTLDevice>)device peerGroupID];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint32_t
mtDevicePeerCount(MtDevice *device) {
	return[(id<MTLDevice>)device peerCount];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15))
MT_API_UNAVAILABLE(mt_ios)
uint32_t
mtDevicePeerIndex(MtDevice *device) {
	return [(id<MTLDevice>)device peerIndex];
}


// Querying Feature Sets and GPU Families

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
bool
mtDeviceSupportsFamily(MtDevice *device, MtGPUFamily family) {
	return [(id<MTLDevice>)device supportsFamily: (MTLGPUFamily)family];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtDeviceSupportsFeatureSet(MtDevice *device, MtFeatureSet set) {
	return [(id<MTLDevice>)device supportsFeatureSet: (MTLFeatureSet)set];
}


// Querying Argument Buffer Support

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentBuffersTier
mtDeviceArgumentBuffersSupport(MtDevice *device) {
	return [(id<MTLDevice>)device argumentBuffersSupport];
}


// Creating Buffers

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.14), mt_ios(12.0))
NsUInteger
mtDeviceMaxBufferLength(MtDevice *device) {
	return [(id<MTLDevice>)device maxBufferLength];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtBuffer*
mtDeviceNewBufferWithLength(MtDevice *device, NsUInteger length, MtResourceOptions opts) {
	return [(id<MTLDevice>)device
					newBufferWithLength: length
					options: (MTLResourceOptions)opts];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
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
