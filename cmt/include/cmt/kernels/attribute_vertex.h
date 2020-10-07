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
const char*
mtVertexAttributeName(MtVertexAttribute *attr);

MT_EXPORT
NsUInteger
mtVertexAttributeIndex(MtVertexAttribute *attr);

MT_EXPORT
MtDataType
mtVertexAttributeDataType(MtVertexAttribute *attr);

MT_EXPORT
bool
mtVertexAttributeActive(MtVertexAttribute *attr);

MT_EXPORT
bool
mtVertexAttributeIsPatchControlPointData(MtVertexAttribute *attr);

MT_EXPORT
bool
mtVertexAttributeIsPatchData(MtVertexAttribute *attr);

#ifdef __cplusplus
}
#endif
#endif /* attribute_vertex_h */
