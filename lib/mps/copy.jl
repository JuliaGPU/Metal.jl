## descriptor

export MPSMatrixCopyDescriptor

# @objcwrapper MPSMatrixCopyDescriptor <: NSObject

function MPSMatrixCopyDescriptor(sourceMatrix, destinationMatrix, offsets = MPSMatrixCopyOffsets(Cuint(0), Cuint(0), Cuint(0), Cuint(0)))
    desc = @objc [MPSMatrixCopyDescriptor descriptorWithSourceMatrix:sourceMatrix::id{MPSMatrix}
                                          destinationMatrix:destinationMatrix::id{MPSMatrix}
                                          offsets:offsets::MPSMatrixCopyOffsets]::id{MPSMatrixCopyDescriptor}
    MPSMatrixCopyDescriptor(desc)
end


## kernel

export MPSMatrixCopy, encode!

# @objcwrapper immutable=false MPSMatrixCopy <: MPSKernel

function MPSMatrixCopy(dev, copyRows, copyColumns, sourcesAreTransposed, destinationsAreTransposed)
    kernel = @objc [MPSMatrixCopy alloc]::id{MPSMatrixCopy}
    obj = MPSMatrixCopy(kernel)
    finalizer(release, obj)
    @objc [obj::id{MPSMatrixCopy} initWithDevice:dev::id{MTLDevice}
                                  copyRows:copyRows::NSUInteger
                                  copyColumns:copyColumns::NSUInteger
                                  sourcesAreTransposed:sourcesAreTransposed::Bool
                                  destinationsAreTransposed:destinationsAreTransposed::Bool]::id{MPSMatrixCopy}
    return obj
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::MPSMatrixCopy, copyDescriptor)
    @objc [kernel::id{MPSMatrixCopy} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                     copyDescriptor:copyDescriptor::id{MPSMatrixCopyDescriptor}]::Nothing
end
