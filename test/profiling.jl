@testset "profiling" begin
mktempdir() do tmpdir
cd(tmpdir) do

if parse(Bool, get(ENV, "CI", "false"))
@warn "Skipping profiling tests on CI due to sandboxing issues"
else

@testset "macro" begin
    Metal.@profile identity(nothing)
    @test isdir("julia_1.trace")
end

end

end
end
end
