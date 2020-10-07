#include "impl/common.h"
#include "cmt/kernels/attribute.h"

MT_EXPORT
const char*
mtVertexAttributeName(MtVertexAttribute *attr) {
    return Cstring([(MTLVertexAttribute*)attr name]);
}

MT_EXPORT
NsUInteger
mtVertexAttributeIndex(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr attributeIndex];
}

MT_EXPORT
MtDataType
mtVertexAttributeDataType(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr attributeType];
}

MT_EXPORT
bool
mtVertexAttributeActive(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isActive];
}

MT_EXPORT
bool
mtVertexAttributeIsPatchControlPointData(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isPatchControlPointData];
}

MT_EXPORT
bool
mtVertexAttributeIsPatchData(MtVertexAttribute *attr) {
    return [(MTLVertexAttribute*)attr isPatchData];
}
