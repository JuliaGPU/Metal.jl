/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/common.h"
#import "cmt/kernels/binary_archive.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtBinaryArchiveDescriptor*
mtNewBinaryArchiveDescriptor(void) {
    return [MTLBinaryArchiveDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
const char*
mtBinaryArchiveDescriptorURL(MtBinaryArchiveDescriptor *desc) {
  return (const char*)mtNSURLFileSystemRepresentation((NSURL*)[(MTLBinaryArchiveDescriptor*)desc url]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveDescriptorURLSet(MtBinaryArchiveDescriptor *desc, const char *path) {
    [(MTLBinaryArchiveDescriptor*)desc setUrl: mtNSURL(path)];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtBinaryArchive*
mtNewBinaryArchiveWithDescriptor(MtDevice *device, MtBinaryArchiveDescriptor *desc, NsError **error) {
  return [(id<MTLDevice>)device newBinaryArchiveWithDescriptor: (MtBinaryArchiveDescriptor *)desc error: (NSError**)error];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
MtDevice*
mtBinaryArchiveDevice(MtBinaryArchive *bin) {
	return [(id<MTLBinaryArchive>)bin device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
const char*
mtBinaryArchiveLabel(MtBinaryArchive *bin) {
	return Cstring([(id<MTLBinaryArchive>)bin label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveLabelSet(MtBinaryArchive *bin, const char* label) {
	((id<MTLBinaryArchive>)bin).label = mtNSString(label);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveAddComputePipelineFunctions(MtBinaryArchive *bin, MtComputePipelineDescriptor *desc, NsError **error) {
    [(id<MTLBinaryArchive>)bin addComputePipelineFunctionsWithDescriptor: (MTLComputePipelineDescriptor*)desc error: (NSError**)error];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveAddFunction(MtBinaryArchive *bin, MtFunctionDescriptor *desc, MtLibrary *lib, NsError **error) {
    [(id<MTLBinaryArchive>)bin addFunctionWithDescriptor: (MTLFunctionDescriptor*)desc library: (id<MTLLibrary>)lib error: (NSError**)error];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(11.0), mt_ios(14.0))
void
mtBinaryArchiveSerialize(MtBinaryArchive *bin, const char *path, NsError **error) {
    [(id<MTLBinaryArchive>)bin serializeToURL: mtNSURL(path) error: (NSError**)error];
}
