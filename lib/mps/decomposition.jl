## lu

export MPSMatrixDecompositionLU, encode!

# @objcwrapper managed = true MPSMatrixDecompositionLU <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionLU(dev, rows, columns)
    return @objc [[MPSMatrixDecompositionLU alloc]::id{MPSMatrixDecompositionLU} initWithDevice:dev::id{MTLDevice}
                                                                           rows:rows::NSUInteger
                                                                           columns:columns::NSUInteger]::MPSMatrixDecompositionLU
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixDecompositionLULike, sourceMatrix, resultMatrix, pivotIndices, status)
    @objc [kernel::id{MPSMatrixDecompositionLU} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                resultMatrix:resultMatrix::id{MPSMatrix}
                                                pivotIndices:pivotIndices::id{MPSMatrix}
                                                status:status::id{MTLBuffer}]::Nothing
end


## cholesky

export MPSMatrixDecompositionCholesky, encode!

# @objcwrapper managed = true MPSMatrixDecompositionCholesky <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionCholesky(dev, lower, order)
    return @objc [[MPSMatrixDecompositionCholesky alloc]::id{MPSMatrixDecompositionCholesky} initWithDevice:dev::id{MTLDevice}
                                                                                       lower:lower::Bool
                                                                                       order:order::NSUInteger]::MPSMatrixDecompositionCholesky
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixDecompositionCholeskyLike, sourceMatrix, resultMatrix, status)
    @objc [kernel::id{MPSMatrixDecompositionCholesky} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                      sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                      resultMatrix:resultMatrix::id{MPSMatrix}
                                                      status:status::id{MTLBuffer}]::Nothing
end
