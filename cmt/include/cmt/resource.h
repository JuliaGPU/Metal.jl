/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_resource_h
#define cmt_resource_h
#ifdef __cplusplus
extern "C" {
#endif

#include "common.h"

typedef enum MtCPUCacheMode {
  MtCPUCacheModeDefaultCache  = 0,
  MtCPUCacheModeWriteCombined = 1
} MtCPUCacheMode;

typedef enum MtHazardTrackingMode {
  MtHazardTrackingModeDefault   = 0,
  MtHazardTrackingModeUntracked = 1,
  MtHazardTrackingModeTracked   = 2
} MtHazardTrackingMode;

typedef enum MtStorageMode {
  MtStorageModeShared     = 0,
  MtStorageModeManaged    = 1,
  MtStorageModePrivate    = 2,
  MtStorageModeMemoryless = 3
} MtStorageMode;

typedef enum MtResourceOptions {
  MtResourceCPUCacheModeDefaultCache    = MtCPUCacheModeDefaultCache,
  MtResourceCPUCacheModeWriteCombined   = MtCPUCacheModeWriteCombined,
  
  MtResourceStorageModeShared           = MtStorageModeShared           << 4,
  MtResourceStorageModeManaged          = MtStorageModeManaged          << 4,
  MtResourceStorageModePrivate          = MtStorageModePrivate          << 4,
  MtResourceStorageModeMemoryless       = MtStorageModeMemoryless       << 4,
  
  MtResourceHazardTrackingModeDefault   = MtHazardTrackingModeDefault   << 8,
  MtResourceHazardTrackingModeUntracked = MtHazardTrackingModeUntracked << 8,
  MtResourceHazardTrackingModeTracked   = MtHazardTrackingModeTracked   << 8
} MtResourceOptions;

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtResourceDevice(MtResource *res);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtResourceLabel(MtResource *res);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCPUCacheMode
mtResourceCPUCacheMode(MtResource *res);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtStorageMode
mtResourceStorageMode(MtResource *res);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtHazardTrackingMode
mtResourceHazardTrackingMode(MtResource *res);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtResourceOptions
mtResourceOptions(MtResource *res);

#ifdef __cplusplus
}
#endif

#endif /* cmt_resource_h */
