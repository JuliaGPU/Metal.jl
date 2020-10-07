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
MtArgumentDescriptor*
mtNewArgumentDescriptor();

MT_EXPORT 
MtDataType
mtArgumentDescriptorDataType(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorDataTypeSet(MtArgumentDescriptor *desc, MtDataType dataType);

MT_EXPORT 
NsUInteger
mtArgumentDescriptorIndex(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorIndexSet(MtArgumentDescriptor *desc, NsUInteger index);

MT_EXPORT 
MtArgumentAccess
mtArgumentDescriptorAccess(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorAccessSet(MtArgumentDescriptor *desc, MtArgumentAccess access);

MT_EXPORT 
NsUInteger
mtArgumentDescriptorArrayLength(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorArrayLengthSet(MtArgumentDescriptor *desc, NsUInteger length);

MT_EXPORT 
NsUInteger
mtArgumentDescriptorConstantBlockAlignment(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorConstantBlockAlignmentSet(MtArgumentDescriptor *desc, NsUInteger alignment);

MT_EXPORT 
MtTextureType
mtArgumentDescriptorTextureType(MtArgumentDescriptor *desc);

MT_EXPORT 
void
mtArgumentDescriptorTextureTypeSet(MtArgumentDescriptor *desc, MtTextureType textype);


#ifdef __cplusplus
}
#endif
#endif /* cmt_argument_descriptor_h */
