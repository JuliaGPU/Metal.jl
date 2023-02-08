/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_mps_device_h
#define cmt_mps_device_h

#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(9.0))
bool
mtMPSSupportsMTLDevice(MtDevice* device);

#ifdef __cplusplus
}
#endif
#endif /* cmt_mps_device_h */
