/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_h
#define cmt_h
#ifdef __cplusplus
extern "C" {
#endif

#include "macros.h"
#include "common.h"

#include "types.h"
#include "enums.h"
#include "error.h"
#include "pixelformat.h"

#include "event.h"
#include "resource.h"
#include "device.h"

#include "compute/compute-pipeline.h"

#include "kernels/attribute.h"
#include "kernels/attribute_vertex.h"
#include "kernels/compile-opts.h"
#include "kernels/constant_values.h"
#include "kernels/function.h"
#include "kernels/library.h"

#include "memory/buffer.h"
#include "memory/heap-descriptor.h"
#include "memory/heap.h"
#include "memory/vertex.h"

#include "rendering/depthstencil.h"
#include "rendering/pass.h"
#include "rendering/pipeline.h"

#include "reflection/argument.h"
#include "reflection/descriptor.h"
#include "reflection/pointer_type.h"

#include "command_buf.h"
#include "command_buf_indirect.h"

#include "command_enc.h"
#include "command_enc_blit.h"
#include "command_enc_compute.h"
#include "command_enc_render.h"

#include "command_queue.h"

#include "argument_descriptor.h"
#include "argument_encoder.h"

MT_EXPORT
void*
mtRetain(void *obj);

MT_EXPORT
void
mtRelease(void *obj);

#ifdef __cplusplus
}
#endif
#endif /* cmt_h */
