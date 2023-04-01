
@cenum MPSMatrixDecompositionStatus::Cint begin
    MPSMatrixDecompositionStatusSuccess =  0
    MPSMatrixDecompositionStatusFailure = -1
    MPSMatrixDecompositionStatusSingular = -2
    MPSMatrixDecompositionStatusNonPositiveDefinite = -3
end


export MPSMatrixDecompositionLU

@objcwrapper immutable=false MPSMatrixDecompositionLU <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionLU(device, rows, columns)
    kernel = @objc [MPSMatrixDecompositionLU alloc]::id{MPSMatrixDecompositionLU}
    obj = MPSMatrixDecompositionLU(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixDecompositionLU} initWithDevice:device::id{MTLDevice}
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


export MPSMatrixDecompositionCholesky

@objcwrapper immutable=false MPSMatrixDecompositionCholesky <: MPSMatrixUnaryKernel

function MPSMatrixDecompositionCholesky(device, lower, order)
    kernel = @objc [MPSMatrixDecompositionCholesky alloc]::id{MPSMatrixDecompositionCholesky}
    obj = MPSMatrixDecompositionCholesky(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixDecompositionCholesky} initWithDevice:device::id{MTLDevice}
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