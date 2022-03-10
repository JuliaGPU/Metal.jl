/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#include "cmt/argument_descriptor.h"
#include "impl/common.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentDescriptor*
mtNewArgumentDescriptor() {
    return [MTLArgumentDescriptor new];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDataType
mtArgumentDescriptorDataType(MtArgumentDescriptor *desc) {
  return (MtDataType)[(MTLArgumentDescriptor*)desc dataType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorDataTypeSet(MtArgumentDescriptor *desc, MtDataType dataType) {
    [(MTLArgumentDescriptor*)desc setDataType:(MTLDataType)dataType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorIndex(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc index];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorIndexSet(MtArgumentDescriptor *desc, NsUInteger index) {
    [(MTLArgumentDescriptor*)desc setIndex: index];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentAccess
mtArgumentDescriptorAccess(MtArgumentDescriptor *desc) {
  return (MtArgumentAccess)[(MTLArgumentDescriptor*)desc access];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorAccessSet(MtArgumentDescriptor *desc, MtArgumentAccess access) {
    [(MTLArgumentDescriptor*)desc setIndex: (MTLArgumentAccess)access];
}

MT_EXPORT 
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorArrayLength(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc arrayLength];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorArrayLengthSet(MtArgumentDescriptor *desc, NsUInteger index) {
    [(MTLArgumentDescriptor*)desc setArrayLength: index];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorConstantBlockAlignment(MtArgumentDescriptor *desc) {
    return [(MTLArgumentDescriptor*)desc constantBlockAlignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorConstantBlockAlignmentSet(MtArgumentDescriptor *desc, NsUInteger alignment) {
    [(MTLArgumentDescriptor*)desc setConstantBlockAlignment: alignment];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtTextureType
mtArgumentDescriptorTextureType(MtArgumentDescriptor *desc) {
  return (MtTextureType)[(MTLArgumentDescriptor*)desc textureType];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorTextureTypeSet(MtArgumentDescriptor *desc, MtTextureType textype) {
    [(MTLArgumentDescriptor*)desc setTextureType: (MTLTextureType)textype];
}
