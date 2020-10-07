//https://developer.apple.com/documentation/metal/mtlfunctionconstantvalues?language=objc

#ifndef cmt_constant_values_h
#define cmt_constant_values_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
void
mtFunctionConstantValuesSetWithIndex(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsUInteger idx);

MT_EXPORT
void
mtFunctionConstantValuesSetWithName(MtFunctionConstantValues *funval, const void *value, MtDataType typ, const char* name);

MT_EXPORT
void
mtFunctionConstantValuesSetWithRange(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsRange range);

MT_EXPORT
void
mtFunctionConstantValuesReset(MtFunctionConstantValues *funval);

#ifdef __cplusplus
}
#endif
#endif /* cmt_constant_values_h */
