#ifndef cmt_capture_scope_h
#define cmt_capture_scope_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCaptureScope*
mtNewCaptureScopeWithCommandQueue(MtCaptureManager *manager, MtCommandQueue *queue);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtBeginScope(MtCaptureScope *scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtEndScope(MtCaptureScope *scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
const char*
mtCaptureScopeLabel(MtCaptureScope *scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtCaptureScopeLabelSet(MtCaptureScope *scope, const char* label);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDevice*
mtCaptureScopeDevice(MtCaptureScope *scope);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtCommandQueue*
mtCaptureScopeCommandQueue(MtCaptureScope *scope);

#ifdef __cplusplus
}
#endif
#endif