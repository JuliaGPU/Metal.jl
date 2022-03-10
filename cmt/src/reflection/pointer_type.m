/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "impl/common.h"
#include "cmt/reflection/pointer_type.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDataType
mtPointerTypeElementType(MtPointerType *ptr)  {
	return (MtDataType)[(MTLPointerType *)ptr elementType];
}        

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentAccess
mtPointerTypeAccess(MtPointerType *ptr) {
	return (MtArgumentAccess)[(MTLPointerType*)ptr access];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger 
mtPointerTypeAlignment(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr alignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger 
mtPointerTypeDataSize(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr dataSize];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
bool
mtPointerTypeElementIsArgumentBuffer(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementIsArgumentBuffer];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtStructType*
mtPointerTypeElementStructType(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementStructType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArrayType*
mtPointerTypeElementArrayType(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementArrayType];
}
