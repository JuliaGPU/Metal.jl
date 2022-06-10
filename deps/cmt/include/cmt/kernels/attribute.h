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
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
const char*
mtAttributeName(MtAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
NsUInteger
mtAttributeIndex(MtAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
MtDataType
mtAttributeDataType(MtAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeActive(MtAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeIsPatchControlPointData(MtAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtAttributeIsPatchData(MtAttribute *attr);

#ifdef __cplusplus
}
#endif
#endif /* attribute_h */
