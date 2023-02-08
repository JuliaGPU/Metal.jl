/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/performance_shaders/device.h"

#include <MetalPerformanceShaders/MetalPerformanceShaders.h>

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(9.0))
bool
mtMPSSupportsMTLDevice(MtDevice* device) {
    return (bool)MPSSupportsMTLDevice(device);
}
