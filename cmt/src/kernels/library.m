/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/common.h"
#import "cmt/kernels/library.h"

CF_RETURNS_RETAINED
MT_EXPORT
MtLibrary*
mtNewDefaultLibrary(MtDevice *device) {
  return [(id<MTLDevice>)device newDefaultLibrary];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtLibrary*
mtNewLibraryWithFile(MtDevice *device, char *filepath, NsError **error) {
  return [(id<MTLDevice>)device newLibraryWithFile: mtNSString(filepath) error:(NSError**)&error];
}

CF_RETURNS_RETAINED
MT_EXPORT
MtLibrary*
mtNewLibraryWithSource(MtDevice *device, char *source, MtCompileOptions *Opts, NsError **error) {
  NSError *_err;
  MtLibrary* lib = [(id<MTLDevice>)device newLibraryWithSource: mtNSString(source) 
  								                           options: (MTLCompileOptions*)Opts 
  								                             error: &_err];
  *error = _err;
  return lib;
}

/*CF_RETURNS_RETAINED
MT_EXPORT
MtLibrary*
mtLibraryWithData(MtDevice *device, char *filepath, NsError *error) {
  return [(id<MTLDevice>)device newLibraryWithFile: mtNSString(filepath) error:(NSError**)&error];
}*/

MT_EXPORT
void
mtLibraryRelease(MtLibrary *lib) {
  [(id<MTLLibrary>)lib release];
}

MT_EXPORT
MtDevice*
mtLibraryDevice(MtLibrary *lib) {
	return [(id<MTLLibrary>)lib device];
}

MT_EXPORT
const char*
mtLibraryLabel(MtLibrary *lib) {
	return Cstring([(id<MTLLibrary>)lib label]);
}


MT_EXPORT
const char**
mtLibraryFunctionNames(MtLibrary *lib) {

  NSArray<NSString*> *_names = [(id<MTLLibrary>)lib functionNames];
  int n = [_names count];
  const char **names = malloc(sizeof(char*) * (n + 1));
  for (int i=0; i < n; i++) {
  	names[i] = Cstring([_names objectAtIndex:i]);
  }
  names[n] = NULL;

  return names;

}

