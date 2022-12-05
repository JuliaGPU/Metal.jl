#include "cmt/capture/capture_descriptor.h"
#include "impl/common.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtCaptureDescriptor*
mtNewCaptureDescriptor() {
    return [MTLCaptureDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void*
mtCaptureDescriptorCaptureObject(MtCaptureDescriptor *desc) {
    return (void*)[(MTLCaptureDescriptor*)desc captureObject];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetQueue(MtCaptureDescriptor *desc, MtCommandQueue *cmdq) {
    [(MTLCaptureDescriptor*)desc setCaptureObject:(id<MTLCommandQueue>)cmdq];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetDevice(MtCaptureDescriptor *desc, MtDevice *dev) {
    [(MTLCaptureDescriptor*)desc setCaptureObject:(id<MTLDevice>)dev];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetScope(MtCaptureDescriptor *desc, MtCaptureScope *scope) {
    [(MTLCaptureDescriptor*)desc setCaptureObject:(id<MTLCaptureScope>)scope];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtCaptureDestination
mtCaptureDescriptorDestination(MtCaptureDescriptor *desc) {
    return (MtCaptureDestination)[(MTLCaptureDescriptor*)desc destination];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorDestinationSet(MtCaptureDescriptor *desc, MtCaptureDestination dest) {
    [(MTLCaptureDescriptor*)desc setDestination:(MTLCaptureDestination)dest];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
const char*
mtCaptureDescriptorOutputURL(MtCaptureDescriptor *desc) {
    return (const char*)mtNSURLFileSystemRepresentation((NSURL*)[(MTLCaptureDescriptor*)desc outputURL]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorOutputURLSet(MtCaptureDescriptor *desc, const char *path) {
    [(MTLCaptureDescriptor*)desc setOutputURL:mtNSURL(path)];
}