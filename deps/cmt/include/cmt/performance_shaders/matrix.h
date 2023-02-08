/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#ifndef cmt_mps_matrix_h
#define cmt_mps_matrix_h

#ifdef __cplusplus
extern "C" {
#endif

#include "cmt/common.h"
#include "cmt/types.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtMPSMatrixDescriptor*
mtNewMatrixDescriptorWithRows(NsUInteger rows, NsUInteger columns, NsUInteger rowBytes,
                              uint32_t dataType);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtMPSMatrix*
mtNewMPSMatrixInitWithBuffer(MtBuffer *buffer, MtMPSMatrixDescriptor *descriptor);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtMPSMatrixMultiplication*
mtNewMPSMatrixMultiplication(MtDevice *device, bool transposeLeft, bool transposeRight,
                             NsUInteger resultRows, NsUInteger resultColumns,
                             NsUInteger interiorColumns, double alpha, double beta);

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtMPSMatMulEncodeToCommandBuffer(MtMPSMatrixMultiplication *matMul, MtCommandBuffer *commandBuffer, MtMPSMatrix * leftMatrix,
                                 MtMPSMatrix *rightMatrix, MtMPSMatrix *resultMatrix);

#ifdef __cplusplus
}
#endif
#endif /* cmt_mps_matrix_h */
