#include "cmt/capture/capture_manager.h"
#include "impl/common.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCaptureManager*
mtSharedCaptureManager(void){
    return [MTLCaptureManager sharedCaptureManager];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtSupportsDestination(MtCaptureManager *manager, MtCaptureDestination destination){
    return (bool)[(MTLCaptureManager*)manager supportsDestination:(MTLCaptureDestination)destination];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtStartCaptureWithDescriptor(MtCaptureManager *manager, MtCaptureDescriptor *descriptor, NsError **error){
    return (bool)[(MTLCaptureManager*)manager startCaptureWithDescriptor:descriptor error:(NSError **)error];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtStopCapture(MtCaptureManager *manager){
    [(MTLCaptureManager*)manager stopCapture];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtIsCapturing(MtCaptureManager *manager){
    return (bool)[(MTLCaptureManager*)manager isCapturing];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCaptureScope*
mtDefaultCaptureScope(MtCaptureManager *manager){
    return [(MTLCaptureManager*) manager defaultCaptureScope];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtDefaultCaptureScopeSet(MtCaptureManager *manager, MtCaptureScope *scope){
    [(MTLCaptureManager*) manager setDefaultCaptureScope: scope];
}
