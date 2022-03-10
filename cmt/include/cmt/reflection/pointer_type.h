/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_pointer_type_h
#define cmt_pointer_type_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDataType
mtPointerTypeElementType(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentAccess
mtPointerTypeAccess(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger 
mtPointerTypeAlignment(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger 
mtPointerTypeDataSize(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtPointerTypeElementIsArgumentBuffer(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtStructType*
mtPointerTypeElementStructType(MtPointerType *ptr);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArrayType*
mtPointerTypeElementArrayType(MtPointerType *ptr);

#ifdef __cplusplus
}
#endif
#endif /* cmt_compute_pipeline_h */
