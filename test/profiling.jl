@testset "profiling" begin

# determine if we can even run these tests
run_tests = false
if parse(Bool, get(ENV, "CI", "false"))
    @warn "Skipping profiling tests on CI due to sandboxing issues"
elseif !success(`xctrace version`)
    @warn "Skipping profiling tests because xctrace is not available; please install Xcode first"
else
    version_output = chomp(read(`xctrace version`, String))
    m = match(r"xctrace version (\d+).(\d+)", version_output)
    if m === nothing
        error("Could not parse xctrace version output:\n$version_output")
    else
        xcode_version = VersionNumber(parse(Int, m.captures[1]), parse(Int, m.captures[2]))
        if MTL.is_m1(current_device()) && macos_version() >= v"14.4" && xcode_version < v"15.3"
            @warn "Skipping profiling tests because of an M1-related bug on macOS 14.4 and Xcode < 15.3; please upgrade Xcode first"
        else
            run_tests = true
        end
    end
end

if run_tests
mktempdir() do tmpdir
cd(tmpdir) do

@testset "macro" begin
    Metal.@profile identity(nothing)
    @test isdir("julia_1.trace")
end

end
end
end

end
