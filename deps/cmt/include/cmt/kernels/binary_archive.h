/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_binary_archive_h
#define cmt_binary_archive_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/error.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtBinaryArchiveDescriptor*
mtNewBinaryArchiveDescriptor(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
const char*
mtBinaryArchiveDescriptorURL(MtBinaryArchiveDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveDescriptorURLSet(MtBinaryArchiveDescriptor *desc, const char *path);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtBinaryArchive*
mtNewBinaryArchiveWithDescriptor(MtDevice *device, MtBinaryArchiveDescriptor *desc, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtDevice*
mtBinaryArchiveDevice(MtBinaryArchive *bin);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
const char*
mtBinaryArchiveLabel(MtBinaryArchive *bin);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveLabelSet(MtBinaryArchive *bin, const char *label);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveAddComputePipelineFunctions(MtBinaryArchive *bin, MtComputePipelineDescriptor *desc, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveAddFunction(MtBinaryArchive *bin, MtFunctionDescriptor *desc, MtLibrary *lib, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveSerialize(MtBinaryArchive *bin, const char *path, NsError **error);

#ifdef __cplusplus
}
#endif
#endif /* cmt_binary_archive_h */
