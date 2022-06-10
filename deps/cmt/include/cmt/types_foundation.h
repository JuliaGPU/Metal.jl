/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_types_foundation_h
#define cmt_types_foundation_h

#include "common.h"

#if INTPTR_MAX == INT64_MAX
// 64-bit
typedef unsigned long NsUInteger;
typedef long NsInteger;
#elif INTPTR_MAX == INT32_MAX
// 32-bit
typedef unsigned int NsUInteger;
typedef int NsInteger;
#endif

typedef double CfTimeInterval;

typedef struct NsRange {
    NsUInteger location;
    NsUInteger length;
} NsRange;

typedef void NsError;

typedef struct {
	char ** keys;
	char ** values;
} NsDictionaryStringString;

#endif /* cmt_types_foundation_h */
