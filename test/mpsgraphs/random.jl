using BFloat16s

if MPS.is_supported(device())

using .MPSGraphs: MPSGraphRandomOpDescriptor, MPSGraphRandomDistributionNormal, MPSGraphRandomDistributionTruncatedNormal, MPSGraphRandomDistributionUniform
@testset "MPSGraph random" begin
    # determined by looking at the error message when trying to construct
    #  an invalid distribution/type combination
    for (dist, T) in [(MPSGraphRandomDistributionNormal, Float32),
                      (MPSGraphRandomDistributionNormal, Float16),
                      (MPSGraphRandomDistributionNormal, BFloat16),
                      (MPSGraphRandomDistributionTruncatedNormal, Float32),
                      (MPSGraphRandomDistributionTruncatedNormal, Float16),
                      (MPSGraphRandomDistributionTruncatedNormal, BFloat16),
                      (MPSGraphRandomDistributionUniform, Int64),
                      (MPSGraphRandomDistributionUniform, Int32),
                      (MPSGraphRandomDistributionUniform, Float32),
                      (MPSGraphRandomDistributionUniform, Float16),
                      (MPSGraphRandomDistributionUniform, BFloat16),
                      ]
        @test MPSGraphRandomOpDescriptor(MPSGraphRandomDistributionNormal, Float32) isa MPSGraphRandomOpDescriptor
    end
end

end # MPS.is_supported(device())
