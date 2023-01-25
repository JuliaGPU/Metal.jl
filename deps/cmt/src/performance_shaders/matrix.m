/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "impl/common.h"
#import "cmt/performance_shaders/matrix.h"

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(11.0))
MtMPSMatrixDescriptor*
mtNewMatrixDescriptorWithRows(NSUInteger rows, NSUInteger columns, NSUInteger rowBytes,
                              uint32_t dataType){
    return [MPSMatrixDescriptor matrixDescriptorWithRows: (NSUInteger)rows
                                columns: (NSUInteger)columns
                                rowBytes: (NSUInteger)rowBytes
                                dataType: (uint32_t)dataType];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtMPSMatrix*
mtNewMPSMatrixInitWithBuffer(MtBuffer *buffer, MtMPSMatrixDescriptor *descriptor){
    return (MtMPSMatrix*)[[MPSMatrix alloc] initWithBuffer: (id<MTLBuffer>)buffer
                                    descriptor: (MPSMatrixDescriptor*)descriptor];
}

CF_RETURNS_RETAINED
MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
MtMPSMatrixMultiplication*
mtNewMPSMatrixMultiplication(MtDevice *device, bool transposeLeft, bool transposeRight,
                             NsUInteger resultRows, NsUInteger resultColumns,
                             NsUInteger interiorColumns, double alpha, double beta){

return (MtMPSMatrix *)[[MPSMatrixMultiplication alloc] initWithDevice:(id<MTLDevice>)device
                                                transposeLeft:(BOOL)transposeLeft
                                                transposeRight:(BOOL)transposeRight
                                                    resultRows:(NSUInteger)resultRows
                                                resultColumns:(NSUInteger)resultColumns
                                            interiorColumns:(NSUInteger)interiorColumns
                                                        alpha:(double)alpha
                                                        beta:(double)beta];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.13), mt_ios(10.0))
void
mtMPSMatMulEncodeToCommandBuffer(MtMPSMatrixMultiplication *matMul, MtCommandBuffer *commandBuffer, MtMPSMatrix * leftMatrix,
                                 MtMPSMatrix *rightMatrix, MtMPSMatrix *resultMatrix){
 [(MPSMatrixMultiplication *)matMul encodeToCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
                   leftMatrix:(MPSMatrix *)leftMatrix
                  rightMatrix:(MPSMatrix *)rightMatrix
                 resultMatrix:(MPSMatrix *)resultMatrix];
}
