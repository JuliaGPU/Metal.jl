#ifndef cmt_pointer_type_h
#define cmt_pointer_type_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MtDataType
mtPointerTypeElementType(MtPointerType *ptr);

MT_EXPORT
MtArgumentAccess
mtPointerTypeAccess(MtPointerType *ptr);

MT_EXPORT
NsUInteger 
mtPointerTypeAlignment(MtPointerType *ptr);

MT_EXPORT
NsUInteger 
mtPointerTypeDataSize(MtPointerType *ptr);

MT_EXPORT
bool
mtPointerTypeElementIsArgumentBuffer(MtPointerType *ptr);

MT_EXPORT
MtStructType*
mtPointerTypeElementStructType(MtPointerType *ptr);

MT_EXPORT
MtArrayType*
mtPointerTypeElementArrayType(MtPointerType *ptr);

#ifdef __cplusplus
}
#endif
#endif /* cmt_compute_pipeline_h */
