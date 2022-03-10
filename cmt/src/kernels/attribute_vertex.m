/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/kernels/attribute.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtVertexAttributeName(MtVertexAttribute *attr) {
    return Cstring([(MTLVertexAttribute*)attr name]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtVertexAttributeIndex(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr attributeIndex];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDataType
mtVertexAttributeDataType(MtVertexAttribute *attr) {
    return (MtDataType)[(MTLVertexAttribute*)attr attributeType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtVertexAttributeActive(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isActive];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtVertexAttributeIsPatchControlPointData(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isPatchControlPointData];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtVertexAttributeIsPatchData(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isPatchData];
}
