#include "impl/common.h"
#include "cmt/kernels/attribute.h"

MT_EXPORT
const char*
mtAttributeName(MtAttribute *attr) {
    return Cstring([(MTLAttribute*)attr name]);
}

MT_EXPORT
NsUInteger
mtAttributeIndex(MtAttribute *attr) {
    return [(MTLAttribute*)attr attributeIndex];
}

MT_EXPORT
MtDataType
mtAttributeDataType(MtAttribute *attr) {
    return [(MTLAttribute*)attr attributeType];
}

MT_EXPORT
bool
mtAttributeActive(MtAttribute *attr) {
    return [(MTLAttribute*)attr isActive];
}

MT_EXPORT
bool
mtAttributeIsPatchControlPointData(MtAttribute *attr) {
    return [(MTLAttribute*)attr isPatchControlPointData];
}

MT_EXPORT
bool
mtAttributeIsPatchData(MtAttribute *attr) {
    return [(MTLAttribute*)attr isPatchData];
}
