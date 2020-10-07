#include "impl/common.h"
#include "cmt/reflection/pointer_type.h"

MT_EXPORT
MtDataType
mtPointerTypeElementType(MtPointerType *ptr)  {
	return [(MTLPointerType*)ptr elementType];
}        

MT_EXPORT
MtArgumentAccess
mtPointerTypeAccess(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr access];
}

MT_EXPORT
NsUInteger 
mtPointerTypeAlignment(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr alignment];
}

MT_EXPORT
NsUInteger 
mtPointerTypeDataSize(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr dataSize];
}

MT_EXPORT
bool
mtPointerTypeElementIsArgumentBuffer(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementIsArgumentBuffer];
}

MT_EXPORT
MtStructType*
mtPointerTypeElementStructType(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementStructType];
}

MT_EXPORT
MtArrayType*
mtPointerTypeElementArrayType(MtPointerType *ptr) {
	return [(MTLPointerType*)ptr elementArrayType];
}

