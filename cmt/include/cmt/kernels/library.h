/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_library_h
#define cmt_library_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/error.h"

MT_EXPORT
MtLibrary*
mtNewDefaultLibrary(MtDevice *device);

MT_EXPORT
MtLibrary*
mtNewLibraryWithFile(MtDevice *device, char *filepath, NsError **error);

MT_EXPORT
MtLibrary*
mtNewLibraryWithSource(MtDevice *device, char *source, MtCompileOptions *Opts, NsError **error);

MT_EXPORT
void
mtLibraryRelease(MtLibrary *lib);

MT_EXPORT
MtDevice*
mtLibraryDevice(MtLibrary *device);

MT_EXPORT
const char*
mtLibraryLabel(MtLibrary *device);

MT_EXPORT
const char **
mtLibraryFunctionNames(MtLibrary *device);


#ifdef __cplusplus
}
#endif
#endif /* cmt_library_h */
