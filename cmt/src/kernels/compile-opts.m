/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/common.h"
#include "cmt/kernels/compile-opts.h"

CF_RETURNS_RETAINED
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MT_EXPORT
MtCompileOptions*
mtNewCompileOpts() {
	return [MTLCompileOptions new];
}

MT_EXPORT
void
mtCompileOptsRelease(MtCompileOptions *opts) {
	return [(MTLCompileOptions *)opts release];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtCompileOptsFastMath(MtCompileOptions *opts) {
	return [(MTLCompileOptions *)(opts) fastMathEnabled];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCompileOptsFastMathSet(MtCompileOptions *opts, bool val) {
	[(MTLCompileOptions *)(opts) setFastMathEnabled:val];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtLanguageVersion
mtCompileOptsLanguageVersion(MtCompileOptions *opts) {
	return [(MTLCompileOptions *)(opts) languageVersion];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
void
mtCompileOptsLanguageVersionSet(MtCompileOptions *opts, MtLanguageVersion val) {
	return [(MTLCompileOptions *)(opts) setLanguageVersion:(MTLLanguageVersion)val];
}