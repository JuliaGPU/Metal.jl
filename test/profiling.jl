@testset "profiling" begin

if MTL.is_m1(current_device()) && macos_version() >= v"14.4"
@warn "Skipping profiling tests because of an M1-related bug on macOS 14.4"
else

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
end
