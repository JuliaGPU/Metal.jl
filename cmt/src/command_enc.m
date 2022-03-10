/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "cmt/common.h"
#include "impl/common.h"
#include "cmt/command_enc.h"

MT_EXPORT
void
mtCommandEncoderEndEncoding(MtCommandEncoder *cce) {
    [(id<MTLCommandEncoder>)cce endEncoding];
}

MT_EXPORT
MtDevice*
mtCommandEncoderDevice(MtCommandEncoder *ce) {
    return [(id<MTLCommandEncoder>)ce device];
}

MT_EXPORT
const char*
mtCommandEncoderLabel(MtCommandEncoder *ce) {
    return Cstring([(id<MTLCommandEncoder>)ce label]);
}

MT_EXPORT
void
mtCommandEncoderInsertDebugSignpost(MtCommandEncoder *ce, char* string) {
    [(id<MTLCommandEncoder>)ce insertDebugSignpost: mtNSString(string)];
}

MT_EXPORT
void
mtCommandEncoderPushDebugGroup(MtCommandEncoder *ce, char* string) {
    [(id<MTLCommandEncoder>)ce pushDebugGroup: mtNSString(string)];
}

MT_EXPORT
void
mtCommandEncoderPopDebugGroup(MtCommandEncoder *ce) {
    [(id<MTLCommandEncoder>)ce popDebugGroup];
}



