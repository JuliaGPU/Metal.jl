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
MtCompileOptions*
mtNewCompileOpts(void);

MT_EXPORT
void
mtCompileOptsRelease(MtCompileOptions *opts);

MT_EXPORT
bool
mtCompileOptsFastMath(MtCompileOptions *opts);

MT_EXPORT
void
mtCompileOptsFastMathSet(MtCompileOptions *opts, bool val);

MT_EXPORT
MtLanguageVersion
mtCompileOptsLanguageVersion(MtCompileOptions *opts);

MT_EXPORT
void
mtCompileOptsLanguageVersionSet(MtCompileOptions *opts, MtLanguageVersion val);

#ifdef __cplusplus
}
#endif
#endif /* cmt_compile_opts_h */
