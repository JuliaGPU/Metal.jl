## lu

export MPSMatrixDecompositionLU, encode!

# @objcwrapper immutable=false MPSMatrixDecompositionLU <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionLU(dev, rows, columns)
    kernel = @objc [MPSMatrixDecompositionLU alloc]::id{MPSMatrixDecompositionLU}
    obj = MPSMatrixDecompositionLU(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixDecompositionLU} initWithDevice:dev::id{MTLDevice}
                                             rows:rows::NSUInteger
                                             columns:columns::NSUInteger]::id{MPSMatrixDecompositionLU}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::MPSMatrixDecompositionLU, sourceMatrix, resultMatrix, pivotIndices, status)
    @objc [kernel::id{MPSMatrixDecompositionLU} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                resultMatrix:resultMatrix::id{MPSMatrix}
                                                pivotIndices:pivotIndices::id{MPSMatrix}
                                                status:status::id{MTLBuffer}]::Nothing
end


## cholesky

export MPSMatrixDecompositionCholesky, encode!

# @objcwrapper immutable=false MPSMatrixDecompositionCholesky <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionCholesky(dev, lower, order)
    kernel = @objc [MPSMatrixDecompositionCholesky alloc]::id{MPSMatrixDecompositionCholesky}
    obj = MPSMatrixDecompositionCholesky(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixDecompositionCholesky} initWithDevice:dev::id{MTLDevice}
                                                   lower:lower::Bool
                                                   order:order::NSUInteger]::id{MPSMatrixDecompositionCholesky}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::MPSMatrixDecompositionCholesky, sourceMatrix, resultMatrix, status)
    @objc [kernel::id{MPSMatrixDecompositionCholesky} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                      sourceMatrix:sourceMatrix::id{MPSMatrix}
                                                      resultMatrix:resultMatrix::id{MPSMatrix}
                                                      status:status::id{MTLBuffer}]::Nothing
end
