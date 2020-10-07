/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_error_h
#define cmt_error_h
#ifdef __cplusplus
extern "C" {
#endif

#include "common_internal.h"
#include "types_foundation.h"

MT_EXPORT
void
mtErrorRelease(NsError *err);

MT_EXPORT
NsInteger
mtErrorCode(NsError *err);

MT_EXPORT
const char*
mtErrorDomain(NsError *err);

MT_EXPORT
const char*
mtErrorUserInfo(NsError *err);

MT_EXPORT
const char*
mtErrorLocalizedDescription(NsError *err);

MT_EXPORT
const char**
mtErrorLocalizedRecoveryOptions(NsError *err);

MT_EXPORT
const char*
mtErrorLocalizedRecoverySuggestion(NsError *err);

MT_EXPORT
const char*
mtErrorLocalizedFailureReason(NsError *err);


#ifdef __cplusplus
}
#endif
#endif /* cmt_error_h */
