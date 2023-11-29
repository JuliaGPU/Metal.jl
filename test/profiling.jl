@testset "profiling" begin
mktempdir() do tmpdir
cd(tmpdir) do

@testset "macro" begin
    Metal.@profile identity(nothing)
    @test isdir("julia_1.trace")
end

end
end
end
