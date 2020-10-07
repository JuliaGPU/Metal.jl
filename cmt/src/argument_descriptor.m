#include "cmt/argument_descriptor.h"
#include "impl/common.h"

CF_RETURNS_RETAINED
MT_EXPORT 
MtArgumentDescriptor*
mtNewArgumentDescriptor() {
    return [MTLArgumentDescriptor new];
}

MT_EXPORT 
MtDataType
mtArgumentDescriptorDataType(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc dataType];
}


MT_EXPORT 
void
mtArgumentDescriptorDataTypeSet(MtArgumentDescriptor *desc, MtDataType dataType) {
    [(MTLArgumentDescriptor*)desc setDataType:(MTLDataType)dataType];
}

MT_EXPORT 
NsUInteger
mtArgumentDescriptorIndex(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc index];
}

MT_EXPORT 
void
mtArgumentDescriptorIndexSet(MtArgumentDescriptor *desc, NsUInteger index) {
    [(MTLArgumentDescriptor*)desc setIndex: index];
}

MT_EXPORT 
MtArgumentAccess
mtArgumentDescriptorAccess(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc access];
}

MT_EXPORT 
void
mtArgumentDescriptorAccessSet(MtArgumentDescriptor *desc, MtArgumentAccess access) {
    [(MTLArgumentDescriptor*)desc setIndex: (MTLArgumentAccess)access];
}

MT_EXPORT 
NsUInteger
mtArgumentDescriptorArrayLength(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc arrayLength];
}

MT_EXPORT 
void
mtArgumentDescriptorArrayLengthSet(MtArgumentDescriptor *desc, NsUInteger index) {
    [(MTLArgumentDescriptor*)desc setArrayLength: index];
}

MT_EXPORT 
NsUInteger
mtArgumentDescriptorConstantBlockAlignment(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc constantBlockAlignment];
}

MT_EXPORT 
void
mtArgumentDescriptorConstantBlockAlignmentSet(MtArgumentDescriptor *desc, NsUInteger alignment) {
    [(MTLArgumentDescriptor*)desc setConstantBlockAlignment: alignment];
}

MT_EXPORT 
MtTextureType
mtArgumentDescriptorTextureType(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc textureType];
}

MT_EXPORT 
void
mtArgumentDescriptorTextureTypeSet(MtArgumentDescriptor *desc, MtTextureType textype) {
    [(MTLArgumentDescriptor*)desc setTextureType: (MTLTextureType)textype];
}
