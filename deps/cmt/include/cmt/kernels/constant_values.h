/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

/* https://developer.apple.com/documentation/metal/mtlfunctionconstantvalues?language=objc */

#ifndef cmt_constant_values_h
#define cmt_constant_values_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithIndex(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsUInteger idx);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithName(MtFunctionConstantValues *funval, const void *value, MtDataType typ, const char* name);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithRange(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsRange range);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesReset(MtFunctionConstantValues *funval);

#ifdef __cplusplus
}
#endif
#endif /* cmt_constant_values_h */
