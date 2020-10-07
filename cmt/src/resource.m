#include "impl/common.h"
#include "cmt/resource.h"

MT_EXPORT
MtDevice*
mtResourceDevice(MtLibrary *res) {
	return [(id<MTLResource>)res device];
}

MT_EXPORT
const char*
mtResourceLabel(MtLibrary *res) {
	return Cstring([(id<MTLResource>)res label]);
}

MT_EXPORT
MtCPUCacheMode
mtResourceCPUCacheMode(MtResource *res) {
	return [(id<MTLResource>)res cpuCacheMode];
}

MT_EXPORT
MtStorageMode
mtResourceStorageMode(MtResource *res) {
	return [(id<MTLResource>)res storageMode];
}

MT_EXPORT
MtHazardTrackingMode
mtResourceHazardTrackingMode(MtResource *res) {
	return [(id<MTLResource>)res hazardTrackingMode];
}

MT_EXPORT
MtResourceOptions
mtResourceOptions(MtResource *res) {
	return [(id<MTLResource>)res resourceOptions];
}
