/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef attribute_vertex_h
#define attribute_vertex_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtVertexAttributeName(MtVertexAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtVertexAttributeIndex(MtVertexAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDataType
mtVertexAttributeDataType(MtVertexAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtVertexAttributeActive(MtVertexAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtVertexAttributeIsPatchControlPointData(MtVertexAttribute *attr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
bool
mtVertexAttributeIsPatchData(MtVertexAttribute *attr);

#ifdef __cplusplus
}
#endif
#endif /* attribute_vertex_h */
