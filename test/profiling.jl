# integrated profiler (no Xcode required; runs everywhere)
@testset "integrated profiler" begin
    a = Metal.rand(Float32, 256, 256)
    b = similar(a)

    # warm up so kernel compilation doesn't dominate the trace
    b .= a .+ 1f0
    Metal.synchronize()

    res = Metal.@profile b .= a .+ 1f0
    @test res isa Metal.Profiling.ProfileResults
    @test !isempty(sprint(show, res))

    # trace mode renders too
    res_trace = Metal.@profile trace=true (b .= a .+ 1f0)
    @test res_trace isa Metal.Profiling.ProfileResults
    @test !isempty(sprint(show, res_trace))

    # when the device reports GPU timestamps, the kernel and its timing should show up
    # (a paravirtualized GPU may not, so only assert when something was captured)
    if !isempty(res.name)
        @test any(n -> occursin("broadcast", n), res.name)
        @test all(>(0), res.stop .- res.start)
    end

    # an empty region is handled gracefully
    res_empty = Metal.@profile (1 + 1)
    @test occursin("No GPU operations", sprint(show, res_empty))

    # benchmarking variant
    res_bench = Metal.@bprofile time=0.1 (b .= a .+ 1f0)
    @test res_bench isa Metal.Profiling.ProfileResults

    # invalid keyword arguments are rejected at expansion time
    @test_throws ArgumentError @macroexpand Metal.@profile external=1 (1 + 1)
    @test_throws ArgumentError @macroexpand Metal.@bprofile external=true (1 + 1)
end

# external profiler (drives Xcode's xctrace; gated like before)
run_external = false
if parse(Bool, get(ENV, "CI", "false"))
    @warn "Skipping external profiling tests on CI due to sandboxing issues"
elseif !success(`xctrace version`)
    @warn "Skipping external profiling tests because xctrace is not available; please install Xcode first"
else
    version_output = chomp(read(`xctrace version`, String))
    m = match(r"xctrace version (\d+).(\d+)", version_output)
    if m === nothing
        error("Could not parse xctrace version output:\n$version_output")
    else
        xcode_version = VersionNumber(parse(Int, m.captures[1]), parse(Int, m.captures[2]))
        if Metal.MTL.is_m1(device()) && Metal.macos_version() >= v"14.4" && xcode_version < v"15.3"
            @warn "Skipping external profiling tests because of an M1-related bug on macOS 14.4 and Xcode < 15.3; please upgrade Xcode first"
        else
            run_external = true
        end
    end
end

if run_external
    @testset "external profiler" begin
        mktempdir() do tmpdir
            cd(tmpdir) do
                Metal.@profile external=true identity(nothing)
                @test isdir("julia_1.trace")
            end
        end
    end
end
