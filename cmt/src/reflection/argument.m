#include "impl/common.h"
#include "cmt/reflection/argument.h"

MT_EXPORT
const char*
mtArgumentName(MtArgument *arg)  {
	return Cstring([(MTLArgument*)arg name]);
}    

MT_EXPORT
bool
mtArgumentActive(MtArgument *arg)  {
	return [(MTLArgument*)arg isActive];
}      

MT_EXPORT
NsUInteger
mtArgumentIndex(MtArgument *arg)  {
	return [(MTLArgument*)arg index];
}      

MT_EXPORT
MtArgumentType
mtArgumentType(MtArgument *arg)  {
	return [(MTLArgument*)arg type];
}        

// Buffer
MT_EXPORT
NsUInteger
mtArgumentBufferAlignment(MtArgument *arg) {
	return [(MTLArgument*)arg bufferAlignment];
}

MT_EXPORT
NsUInteger
mtArgumentBufferDataSize(MtArgument *arg) {
	return [(MTLArgument*)arg bufferDataSize];
}

MT_EXPORT
MtDataType
mtArgumentBufferDataType(MtArgument *arg) {
	return [(MTLArgument*)arg bufferDataType];
}

MT_EXPORT
MtStructType*
mtArgumentBufferStructType(MtArgument *arg) {
	return [(MTLArgument*)arg bufferStructType];
}

MT_EXPORT
MtPointerType*
mtArgumentBufferPointerType(MtArgument *arg) {
	return [(MTLArgument*)arg bufferPointerType];
}

// Array
MT_EXPORT
NsUInteger
mtArgumentArrayLength(MtArgument *arg) {
	return [(MTLArgument*)arg arrayLength];
}

MT_EXPORT
NsUInteger
mtArgumentThreadgroupMemoryAlignment(MtArgument *arg) {
	return [(MTLArgument*)arg threadgroupMemoryAlignment];
}

MT_EXPORT
NsUInteger
mtArgumentThreadgroupMemoryDataSize(MtArgument *arg) {
	return [(MTLArgument*)arg threadgroupMemoryDataSize];
}

