/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_argument_
#define cmt_argument_
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtArgumentName(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtArgumentActive(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentIndex(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtArgumentType
mtArgumentType(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtArgumentAccess
mtArgumentAccess(MtArgument *arg);

// Buffer
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentBufferAlignment(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentBufferDataSize(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDataType
mtArgumentBufferDataType(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtStructType*
mtArgumentBufferStructType(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtPointerType*
mtArgumentBufferPointerType(MtArgument *arg);

// Array
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger
mtArgumentArrayLength(MtArgument *arg);

// Array
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentThreadgroupMemoryAlignment(MtArgument *arg);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentThreadgroupMemoryDataSize(MtArgument *arg);

#ifdef __cplusplus
}
#endif
#endif /* cmt_argument_ */
