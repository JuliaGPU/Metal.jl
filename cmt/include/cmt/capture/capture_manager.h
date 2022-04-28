
#ifndef cmt_capture_manager_h
#define cmt_capture_manager_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCaptureManager*
mtSharedCaptureManager(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtSupportsDestination(MtCaptureManager *manager, MtCaptureDestination destination);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtStartCaptureWithDescriptor(MtCaptureManager *manager, MtCaptureDescriptor *descriptor, NsError **error);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtStopCapture(MtCaptureManager *manager);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtIsCapturing(MtCaptureManager *manager);

#ifdef __cplusplus
}
#endif
#endif