/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_argument_descriptor_h
#define cmt_argument_descriptor_h
#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"
#include "cmt/enums.h"
#include "cmt/resource.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentDescriptor*
mtNewArgumentDescriptor(void);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtDataType
mtArgumentDescriptorDataType(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorDataTypeSet(MtArgumentDescriptor *desc, MtDataType dataType);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorIndex(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorIndexSet(MtArgumentDescriptor *desc, NsUInteger index);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtArgumentAccess
mtArgumentDescriptorAccess(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorAccessSet(MtArgumentDescriptor *desc, MtArgumentAccess access);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorArrayLength(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorArrayLengthSet(MtArgumentDescriptor *desc, NsUInteger length);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
NsUInteger
mtArgumentDescriptorConstantBlockAlignment(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorConstantBlockAlignmentSet(MtArgumentDescriptor *desc, NsUInteger alignment);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtTextureType
mtArgumentDescriptorTextureType(MtArgumentDescriptor *desc);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
void
mtArgumentDescriptorTextureTypeSet(MtArgumentDescriptor *desc, MtTextureType textype);

#ifdef __cplusplus
}
#endif
#endif /* cmt_argument_descriptor_h */
