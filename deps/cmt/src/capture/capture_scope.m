#include "impl/common.h"
#include "cmt/command_queue.h"
#include "cmt/capture/capture_scope.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCaptureScope*
mtNewCaptureScopeWithCommandQueue(MtCaptureManager *manager, MtCommandQueue *queue){
    return (MtCaptureScope*)[(MTLCaptureManager*)manager newCaptureScopeWithCommandQueue: queue];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtBeginScope(MtCaptureScope *scope){
[(id<MTLCaptureScope>)scope beginScope];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtEndScope(MtCaptureScope *scope){
    [(id<MTLCaptureScope>)scope endScope];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
const char*
mtCaptureScopeLabel(MtCaptureScope *scope) {
    return Cstring([(id<MTLCaptureScope>)scope label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCaptureScopeLabelSet(MtCaptureScope *scope, const char* label) {
    [(id<MTLCaptureScope>)scope setLabel: mtNSString(label)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDevice*
mtCaptureScopeDevice(MtCaptureScope *scope) {
    return [(id<MTLCaptureScope>)scope device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCommandQueue*
mtCaptureScopeCommandQueue(MtCaptureScope *scope) {
    return [(id<MTLCaptureScope>)scope commandQueue];
}
