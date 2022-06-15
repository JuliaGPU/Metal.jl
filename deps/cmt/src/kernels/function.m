/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#include "cmt/kernels/function.h"
#import "cmt/error.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtFunction*
mtNewFunctionWithName(MtLibrary *lib, const char *name) {
  return [(id<MTLLibrary>)lib newFunctionWithName: mtNSString(name)];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
MtFunction*
mtNewFunctionWithNameConstantValues(MtLibrary *lib, const char *name, MtFunctionConstantValues *constantValues, NsError **error) {
  return [(id<MTLLibrary>)lib newFunctionWithName: mtNSString(name)
  								   constantValues: (MtFunctionConstantValues *)constantValues
  								   			error: (NSError**)&error];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDevice*
mtFunctionDevice(MtFunction* fun) {
	return [(id<MTLFunction>)fun device];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
const char*
mtFunctionLabel(MtFunction* fun) {
	return Cstring([(id<MTLFunction>)fun label]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionLabelSet(MtFunction *fun, const char* label) {
	((id<MTLFunction>)fun).label = mtNSString(label);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtFunctionType
mtFunctionType(MtFunction* fun) {
	return (MtFunctionType)[(id<MTLFunction>)fun functionType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtFunctionName(MtFunction* fun) {
	return Cstring([(id<MTLFunction>)fun name]);
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
MtAttribute**
mtFunctionStageInputAttributes(MtFunction* fun) {
	NSArray<MTLAttribute *> *_attributes = [(id<MTLFunction>)fun stageInputAttributes];
	NSInteger n = [_attributes count];
	MtAttribute* *attributes = malloc(sizeof(MtAttribute*) * (n+1));
	for (int i=0; i < n; i++) {
      attributes[i] = [_attributes objectAtIndex:i];
    }
	attributes[n] = NULL;

	return attributes;
}
