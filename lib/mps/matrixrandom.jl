@cenum MPSMatrixRandomDistribution::UInt begin
    MPSMatrixRandomDistributionDefault = UInt(1)
    MPSMatrixRandomDistributionUniform = UInt(2)
    MPSMatrixRandomDistributionNormal  = UInt(3)
end
## bitwise operations lose type information, so allow conversions
Base.convert(::Type{MPSMatrixRandomDistribution}, x::Integer) = MPSMatrixRandomDistribution(x)

#
# matrix random descriptor
#

export MPSMatrixRandomDistributionDescriptor

@objcwrapper immutable=false MPSMatrixRandomDistributionDescriptor <: NSObject

@objcproperties MPSMatrixRandomDistributionDescriptor begin
    @autoproperty distributionType::MPSMatrixRandomDistribution
    @autoproperty maximum::Float32 setter=setMaximum
    @autoproperty mean::Float32 setter=setMean
    @autoproperty minimum::Float32 setter=setMimimum
    @autoproperty standardDeviation::Float32 setter=setStandardDeviation
end


function MPSMatrixRandomDefaultDistributionDescriptor()
    desc = @objc [MPSMatrixRandomDistributionDescriptor defaultDistributionDescriptor]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    # XXX: who releases this object?
    return obj
end

# Default constructor
MPSMatrixRandomDistributionDescriptor() = MPSMatrixRandomDefaultDistributionDescriptor()

function MPSMatrixRandomNormalDistributionDescriptor(mean, standardDeviation)
    desc = @objc [MPSMatrixRandomDistributionDescriptor normalDistributionDescriptorWithMean:mean::Float32
                                                        standardDeviation:standardDeviation::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    # XXX: who releases this object?
    return obj
end

function MPSMatrixRandomNormalDistributionDescriptor(mean, standardDeviation, minimum, maximum)
    desc = @objc [MPSMatrixRandomDistributionDescriptor normalDistributionDescriptorWithMean:mean::Float32
                                                        standardDeviation:standardDeviation::Float32
                                                        minimum:minimum::Float32
                                                        maximum:maximum::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    # XXX: who releases this object?
    return obj
end

function MPSMatrixRandomUniformDistributionDescriptor(minimum, maximum)
    desc = @objc [MPSMatrixRandomDistributionDescriptor uniformDistributionDescriptorWithMinimum:minimum::Float32
                                                        maximum:maximum::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    # XXX: who releases this object?
    return obj
end


@objcwrapper immutable=false MPSMatrixRandom <: MPSKernel

@objcproperties MPSMatrixRandom begin
    @autoproperty batchSize::NSUInteger
    @autoproperty batchStart::NSUInteger
    @autoproperty destinationDataType::id{MPSDataType}
    @autoproperty distributionType::id{MPSMatrixRandomDistributionDescriptor}
end

function encode!(cmdbuf::MTLCommandBuffer, kernel::K, destinationMatrix::MPSMatrix) where {K<:MPSMatrixRandom}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                         destinationMatrix:destinationMatrix::id{MPSMatrix}]::Nothing
end
function encode!(cmdbuf::MTLCommandBuffer, kernel::K, destinationVector::MPSVector) where {K<:MPSMatrixRandom}
    @objc [kernel::id{K} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                         destinationVector:destinationVector::id{MPSVector}]::Nothing
end

@objcwrapper immutable=false MPSMatrixRandomMTGP32 <: MPSMatrixRandom
@objcwrapper immutable=false MPSMatrixRandomPhilox <: MPSMatrixRandom

for R in [:MPSMatrixRandomMTGP32, :MPSMatrixRandomPhilox]
    @eval begin
        function $R(device)
            kernel = @objc [$R alloc]::id{$R}
            obj = $R(kernel)
            finalizer(release, obj)
            @objc [obj::id{$R} initWithDevice:device::id{MTLDevice}]::id{$R}
            return obj
        end
        function $R(device, destinationDataType, seed)
            kernel = @objc [$R alloc]::id{$R}
            obj = $R(kernel)
            finalizer(release, obj)
            @objc [obj::id{$R} initWithDevice:device::id{MTLDevice}
                                destinationDataType:destinationDataType::MPSDataType
                                seed:seed::NSUInteger]::id{$R}
            return obj
        end
        function $R(device, destinationDataType, seed, distributionDescriptor)
            kernel = @objc [$R alloc]::id{$R}
            obj = $R(kernel)
            finalizer(release, obj)
            @objc [obj::id{$R} initWithDevice:device::id{MTLDevice}
                                destinationDataType:destinationDataType::MPSDataType
                                seed:seed::NSUInteger
                                distributionDescriptor:distributionDescriptor::id{MPSMatrixRandomDistributionDescriptor}]::id{$R}
            return obj
        end
    end
end

synchronizeStateOnCommandBuffer(kern::MPSMatrixRandomMTGP32, cmdBuf::MTLCommandBuffer) =
    @objc [obj::id{MPSMatrixRandomMTGP32} synchronizeStateOnCommandBuffer:cmdBuf::id{MTLCommandBuffer}]::Nothing

@inline function _mpsmat_rand!(mpsvecormat::Union{MPSMatrix,MPSVector}, T::DataType;
                        desc::MPSMatrixRandomDistributionDescriptor = MPSMatrixRandomDistributionDescriptor(),
                        cmdBuf::MTLCommandBuffer = MTLCommandBuffer(global_queue(current_device())),
                        RandKern::Type{<:MPSMatrixRandom} = MPSMatrixRandomMTGP32,
                        seed = rand(UInt))
    randkern = RandKern(current_device(), T, seed, desc)
    MPS.encode!(cmdBuf, randkern, mpsvecormat)
    commit!(cmdBuf)
    wait_completed(cmdBuf)
    return
end

# XXX: Currently slower than GPUArrays random functionality
# using Random
# #
# # Overload rand! and randn! for Vectors and matrices
# #
# for (mtlarr, mpsarr) in ((MtlMatrix, MPSMatrix),(MtlVector, MPSVector))
#     @eval begin
#         function Random.rand!(A::$(mtlarr){T}) where T
#             mpsvecormat = $(mpsarr)(A)
#             _mpsmat_rand!(mpsvecormat, T; desc=MPSMatrixUniformDistributionDescriptor(0,1))
#             return A
#         end
#         function Random.randn!(A::$(mtlarr){T}) where T
#             mpsvecormat = $(mpsarr)(A)
#             _generic_rand!(mpsvecormat, T; desc=MPSMatrixNormalDistributionDescriptor(0,1))
#             return A
#         end
#     end
# end
