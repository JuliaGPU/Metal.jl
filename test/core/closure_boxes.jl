using KernelAbstractions, SpecialFunctions

# captured variables that get boxed (`Core.Box`) lose their type
if isdefined(Test, :detect_closure_boxes)
    @test Test.detect_closure_boxes(Metal, Metal.AS, Metal.MTL, Metal.MPS, Metal.MPSGraphs,
                                    Metal.MetalKernels, Metal.Profiling, Metal.MetalLibCLI,
                                    Base.get_extension(Metal, :SpecialFunctionsExt)) == []
end
