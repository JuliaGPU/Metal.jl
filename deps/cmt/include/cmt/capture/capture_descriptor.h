#ifndef cmt_capture_descriptor_h
#define cmt_capture_descriptor_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtCaptureDescriptor*
mtNewCaptureDescriptor(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void*
mtCaptureDescriptorCaptureObject(MtCaptureDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetQueue(MtCaptureDescriptor *desc, MtCommandQueue *cmdq);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetDevice(MtCaptureDescriptor *desc, MtDevice *dev);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorCaptureObjectSetScope(MtCaptureDescriptor *desc, MtCaptureScope *scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
MtCaptureDestination
mtCaptureDescriptorDestination(MtCaptureDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorDestinationSet(MtCaptureDescriptor *desc, MtCaptureDestination dest);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
void
mtCaptureDescriptorOutputURLSet(MtCaptureDescriptor *desc, const char *path);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.15), mt_ios(13.0))
const char*
mtCaptureDescriptorOutputURL(MtCaptureDescriptor *desc);

#ifdef __cplusplus
}
#endif
#endif