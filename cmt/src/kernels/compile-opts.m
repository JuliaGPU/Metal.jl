#include "impl/common.h"
#include "cmt/common.h"
#include "cmt/kernels/compile-opts.h"

CF_RETURNS_RETAINED
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
bool
mtCompileOptsFastMath(MtCompileOptions *opts) {
	return [(MTLCompileOptions *)(opts) fastMathEnabled];
}

MT_EXPORT
void
mtCompileOptsFastMathSet(MtCompileOptions *opts, bool val) {
	[(MTLCompileOptions *)(opts) setFastMathEnabled:val];
}

MT_EXPORT
MtLanguageVersion
mtCompileOptsLanguageVersion(MtCompileOptions *opts) {
	return [(MTLCompileOptions *)(opts) languageVersion];
}

MT_EXPORT
void
mtCompileOptsLanguageVersionSet(MtCompileOptions *opts, MtLanguageVersion val) {
	return [(MTLCompileOptions *)(opts) setLanguageVersion:(MTLLanguageVersion)val];
}