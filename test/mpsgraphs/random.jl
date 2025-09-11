using .MPSGraphs: MPSGraphRandomOpDescriptor, MPSGraphRandomDistributionNormal, MPSGraphRandomDistributionTruncatedNormal, MPSGraphRandomDistributionUniform
# determined by looking at the error message when trying to construct
#  an invalid distribution/type combination
OP_TYPES = [(MPSGraphRandomDistributionNormal, Float32),
                    (MPSGraphRandomDistributionNormal, Float16),
                    (MPSGraphRandomDistributionTruncatedNormal, Float32),
                    (MPSGraphRandomDistributionTruncatedNormal, Float16),
                    (MPSGraphRandomDistributionUniform, Int64),
                    (MPSGraphRandomDistributionUniform, Int32),
                    (MPSGraphRandomDistributionUniform, Float32),
                    (MPSGraphRandomDistributionUniform, Float16),
                    (MPSGraphRandomDistributionNormal, BFloat16),
                    (MPSGraphRandomDistributionTruncatedNormal, BFloat16),
                    (MPSGraphRandomDistributionUniform, BFloat16),
                    ]

for (dist, T) in OP_TYPES
    @test MPSGraphRandomOpDescriptor(dist, T) isa MPSGraphRandomOpDescriptor
end
