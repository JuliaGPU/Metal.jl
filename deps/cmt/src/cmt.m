/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"

CF_RETURNS_RETAINED
MT_EXPORT
void*
mtRetain(void *obj) {
  return [(id)obj retain];
}

MT_EXPORT
void
mtRelease(void * CF_RELEASES_ARGUMENT obj) {
  [(id)obj release];
}
