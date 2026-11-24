using SpecialFunctions

@testset "$T" for T in (Float32, Float16)
    let # erf
        arr = T[-1.0, -0.5, 0.0, 1.0e-3, 1.0, 2.0, 5.5]
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erf.(arr)
        @test Array(SpecialFunctions.erf.(buffer)) ≈ cpures
    end

    let # erfc
        arr = T.(collect(LinRange(nextfloat(-3.0f0), 3.0f0, 20)))
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erfc.(arr)
        @test Array(SpecialFunctions.erfc.(buffer)) ≈ cpures
    end

    let # erfinv
        arr = T.(collect(LinRange(-1.0f0, 1.0f0, 20)))
        buffer = MtlArray(arr)
        cpures = SpecialFunctions.erfinv.(arr)
        @test Array(SpecialFunctions.erfinv.(buffer)) ≈ cpures
    end
end
