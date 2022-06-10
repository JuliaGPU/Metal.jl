/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_compile_opts_h
#define cmt_compile_opts_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtCompileOptions*
mtNewCompileOpts(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCompileOptsFastMath(MtCompileOptions *opts);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCompileOptsFastMathSet(MtCompileOptions *opts, bool val);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtLanguageVersion
mtCompileOptsLanguageVersion(MtCompileOptions *opts);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCompileOptsLanguageVersionSet(MtCompileOptions *opts, MtLanguageVersion val);

#ifdef __cplusplus
}
#endif
#endif /* cmt_compile_opts_h */
