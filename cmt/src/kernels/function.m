/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#include "cmt/kernels/function.h"
#import "cmt/error.h"


CF_RETURNS_RETAINED
MT_EXPORT
MtFunction*
mtNewFunctionWithName(MtLibrary *lib, const char *name) {
  return [(id<MTLLibrary>)lib newFunctionWithName: mtNSString(name)];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtFunction*
mtNewFunctionWithNameConstantValues(MtLibrary *lib, const char *name, MtFunctionConstantValues *constantValues, NsError **error) {
  return [(id<MTLLibrary>)lib newFunctionWithName: mtNSString(name)
  								   constantValues: (MtFunctionConstantValues *)constantValues
  								   			error: (NSError**)&error];
}

MT_EXPORT
void
mtFunctionRelease(MtFunction* fun) {
	[(id<MTLFunction>)fun release];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtDevice*
mtFunctionDevice(MtFunction* fun) {
	return [(id<MTLFunction>)fun device];
}

MT_EXPORT
const char*
mtFunctionLabel(MtFunction* fun) {
	return Cstring([(id<MTLFunction>)fun label]);
}

MT_EXPORT
MtFunctionType
mtFunctionType(MtFunction* fun) {
	return [(id<MTLFunction>)fun functionType];
}

MT_EXPORT
const char*
mtFunctionName(MtFunction* fun) {
	return Cstring([(id<MTLFunction>)fun name]);
}

MT_EXPORT
MtAttribute**
mtFunctionStageInputAttributes(MtFunction* fun) {
	NSArray<MTLAttribute *> *_attributes = [(id<MTLFunction>)fun stageInputAttributes];
	int n = [_attributes count];
	MtAttribute* *attributes = malloc(sizeof(MtAttribute*) * (n+1));
	for (int i=0; i < n; i++) {
      attributes[i] = [_attributes objectAtIndex:i];
    }
	attributes[n] = NULL;

	return attributes;
}
