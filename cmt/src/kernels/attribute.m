/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/kernels/attribute.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
const char*
mtAttributeName(MtAttribute *attr) {
    return Cstring([(MTLAttribute*)attr name]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
NsUInteger
mtAttributeIndex(MtAttribute *attr) {
    return [(MTLAttribute*)attr attributeIndex];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
MtDataType
mtAttributeDataType(MtAttribute *attr) {
    return [(MTLAttribute*)attr attributeType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeActive(MtAttribute *attr) {
    return [(MTLAttribute*)attr isActive];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeIsPatchControlPointData(MtAttribute *attr) {
    return [(MTLAttribute*)attr isPatchControlPointData];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeIsPatchData(MtAttribute *attr) {
    return [(MTLAttribute*)attr isPatchData];
}
