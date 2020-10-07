/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef attribute_h
#define attribute_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
const char*
mtAttributeName(MtAttribute *attr);

MT_EXPORT
NsUInteger
mtAttributeIndex(MtAttribute *attr);

MT_EXPORT
MtDataType
mtAttributeDataType(MtAttribute *attr);

MT_EXPORT
bool
mtAttributeActive(MtAttribute *attr);

MT_EXPORT
bool
mtAttributeIsPatchControlPointData(MtAttribute *attr);

MT_EXPORT
bool
mtAttributeIsPatchData(MtAttribute *attr);

#ifdef __cplusplus
}
#endif
#endif /* attribute_h */
