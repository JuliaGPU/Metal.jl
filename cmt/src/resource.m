/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtResourceDevice(MtLibrary *res) {
	return [(id<MTLResource>)res device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtResourceLabel(MtLibrary *res) {
	return Cstring([(id<MTLResource>)res label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCPUCacheMode
mtResourceCPUCacheMode(MtResource *res) {
	return (MtCPUCacheMode)[(id<MTLResource>)res cpuCacheMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtStorageMode
mtResourceStorageMode(MtResource *res) {
	return (MtStorageMode)[(id<MTLResource>)res storageMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode
mtResourceHazardTrackingMode(MtResource *res) {
	return (MtHazardTrackingMode)[(id<MTLResource>)res hazardTrackingMode];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions
mtResourceOptions(MtResource *res) {
	return (MtResourceOptions)[(id<MTLResource>)res resourceOptions];
}
