@cenum MPSMatrixRandomDistribution::UInt begin
    MPSMatrixRandomDistributionDefault = 1
    MPSMatrixRandomDistributionUniform = 2
    MPSMatrixRandomDistributionNormal  = 3
end

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
    return obj
end

# Default constructor
MPSMatrixRandomDistributionDescriptor() = MPSMatrixRandomDefaultDistributionDescriptor()

function MPSMatrixRandomNormalDistributionDescriptor(mean, standardDeviation)
    desc = @objc [MPSMatrixRandomDistributionDescriptor normalDistributionDescriptorWithMean:mean::Float32
                                                        standardDeviation:standardDeviation::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    return obj
end

function MPSMatrixRandomNormalDistributionDescriptor(mean, standardDeviation, minimum, maximum)
    desc = @objc [MPSMatrixRandomDistributionDescriptor normalDistributionDescriptorWithMean:mean::Float32
                                                        standardDeviation:standardDeviation::Float32
                                                        minimum:minimum::Float32
                                                        maximum:maximum::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
    return obj
end

function MPSMatrixRandomUniformDistributionDescriptor(minimum, maximum)
    desc = @objc [MPSMatrixRandomDistributionDescriptor uniformDistributionDescriptorWithMinimum:minimum::Float32
                                                        maximum:maximum::Float32]::id{MPSMatrixRandomDistributionDescriptor}
    obj = MPSMatrixRandomDistributionDescriptor(desc)
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

synchronize_state(kern::MPSMatrixRandomMTGP32, cmdbuf::MTLCommandBuffer) =
    @objc [kern::id{MPSMatrixRandomMTGP32} synchronizeStateOnCommandBuffer:cmdbuf::id{MTLCommandBuffer}]::Nothing


@inline function _mpsmat_rand!(randkern::MPSMatrixRandom, dest::MtlArray{T}, ::Type{T2};
                        queue::MTLCommandQueue = global_queue(randkern.device),
                        async::Bool=false) where {T,T2}
    byteoffset = dest.offset * sizeof(T)
    bytesize = sizeof(dest)

    # Even though `append_copy`` seems to work with any size or offset values, the documentation at
    # https://developer.apple.com/documentation/metal/mtlblitcommandencoder/1400767-copyfrombuffer?language=objc
    # mentions that both must be multiples of 4 bytes in MacOS so error when they are not
    (bytesize % 4 == 0) || error(lazy"Destination buffer bytesize ($(bytesize)) must be a multiple of 4.")
    (byteoffset % 4 == 0) || error(lazy"Destination buffer offset ($(byteoffset)) must be a multiple of 4.")

    cmdbuf = if bytesize % 16 == 0 && dest.offset == 0
        MTLCommandBuffer(queue) do cmdbuf
            vecDesc = MPSVectorDescriptor(bytesize ÷ sizeof(T2), T2)
            mpsdest = MPSVector(dest, vecDesc)
            encode!(cmdbuf, randkern, mpsdest)
        end
    else
        MTLCommandBuffer(queue) do cmdbuf
            len = UInt(ceil(bytesize / sizeof(T2)) * 4)
            vecDesc = MPSVectorDescriptor(len, T2)
            tempVec = MPSTemporaryVector(cmdbuf, vecDesc)
            encode!(cmdbuf, randkern, tempVec)
            MTLBlitCommandEncoder(cmdbuf) do enc
                MTL.append_copy!(enc, dest.data[], byteoffset, tempVec.data, tempVec.offset, bytesize)
            end
        end
    end

    async || wait_completed(cmdbuf)
    return
end
