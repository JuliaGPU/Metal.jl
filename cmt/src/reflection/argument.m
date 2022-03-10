/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/reflection/argument.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
const char*
mtArgumentName(MtArgument *arg)  {
	return Cstring([(MTLArgument*)arg name]);
}    

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
bool
mtArgumentActive(MtArgument *arg)  {
	return [(MTLArgument*)arg isActive];
}      

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentIndex(MtArgument *arg)  {
	return [(MTLArgument*)arg index];
}      

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtArgumentType
mtArgumentType(MtArgument *arg)  {
	return (MtArgumentType)[(MTLArgument *)arg type];
}        

// Buffer
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentBufferAlignment(MtArgument *arg) {
	return [(MTLArgument*)arg bufferAlignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentBufferDataSize(MtArgument *arg) {
	return [(MTLArgument*)arg bufferDataSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtDataType
mtArgumentBufferDataType(MtArgument *arg) {
	return (MtDataType)[(MTLArgument *)arg bufferDataType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
MtStructType*
mtArgumentBufferStructType(MtArgument *arg) {
	return [(MTLArgument*)arg bufferStructType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtPointerType*
mtArgumentBufferPointerType(MtArgument *arg) {
	return [(MTLArgument*)arg bufferPointerType];
}

// Array
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
NsUInteger
mtArgumentArrayLength(MtArgument *arg) {
	return [(MTLArgument*)arg arrayLength];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentThreadgroupMemoryAlignment(MtArgument *arg) {
	return [(MTLArgument*)arg threadgroupMemoryAlignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.11), mt_ios(8.0))
NsUInteger
mtArgumentThreadgroupMemoryDataSize(MtArgument *arg) {
	return [(MTLArgument*)arg threadgroupMemoryDataSize];
}

