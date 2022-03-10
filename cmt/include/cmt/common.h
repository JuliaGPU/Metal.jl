/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_common_h
#define cmt_common_h

#define MT_EXPORT  __attribute__((visibility("default")))
#define MT_HIDE    __attribute__((visibility("hidden")))
#define MT_INLINE inline __attribute((always_inline))
#define MT_ALIGN(X) __attribute((aligned(X)))

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

/*
   MT_API_AVAILABLE usage:
   MT_API_AVAILABLE(minimum_macos_version, minimum_ios_version)
 */

#ifdef __APPLE__
#  include <os/availability.h>
#  define mt_macCatalyst macCatalyst
#  define mt_ios         ios
#  define mt_macos       macos
//#  define MT_API_AVAILABLE(M, I) API_AVAILABLE(macos(M), ios(I))
#  define MT_API_AVAILABLE(...) API_AVAILABLE(__VA_ARGS__)
#  define MT_API_UNAVAILABLE(X)  API_UNAVAILABLE(X)
#else
#  define mt_macCatalyst
#  define mt_ios
#  define mt_macos
#  define mt_API_AVAILABLE(M, I)
#endif

#endif /* cmt_common_h */
