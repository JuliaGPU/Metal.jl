#ifndef cmt_argument_
#define cmt_argument_
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
const char*
mtArgumentName(MtArgument *arg);

MT_EXPORT
bool
mtArgumentActive(MtArgument *arg);

MT_EXPORT
NsUInteger
mtArgumentIndex(MtArgument *arg);

MT_EXPORT
MtArgumentType
mtArgumentType(MtArgument *arg);

MT_EXPORT
MtArgumentAccess
mtArgumentAccess(MtArgument *arg);

// Buffer
MT_EXPORT
NsUInteger
mtArgumentBufferAlignment(MtArgument *arg);

MT_EXPORT
NsUInteger
mtArgumentBufferDataSize(MtArgument *arg);

MT_EXPORT
MtDataType
mtArgumentBufferDataType(MtArgument *arg);

MT_EXPORT
MtStructType*
mtArgumentBufferStructType(MtArgument *arg);

MT_EXPORT
MtPointerType*
mtArgumentBufferPointerType(MtArgument *arg);

// Array
MT_EXPORT
NsUInteger
mtArgumentArrayLength(MtArgument *arg);

// Array
MT_EXPORT
NsUInteger
mtArgumentThreadgroupMemoryAlignment(MtArgument *arg);

MT_EXPORT
NsUInteger
mtArgumentThreadgroupMemoryDataSize(MtArgument *arg);

#ifdef __cplusplus
}
#endif
#endif /* cmt_argument_ */
