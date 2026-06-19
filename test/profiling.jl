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
    @test isempty(res.host_trace.name)

    # trace mode renders host calls and device operations chronologically
    res_trace = Metal.@profile trace=true (b .= a .+ 1f0)
    @test res_trace isa Metal.Profiling.ProfileResults
    trace_output = sprint(show, res_trace)
    @test !isempty(trace_output)
    if !isempty(res_trace.host.name)
        @test !isempty(res_trace.host_trace.name)
        @test occursin("ID", trace_output)
        @test occursin("Start", trace_output)
        @test !occursin("Calls │ Name", trace_output)
    end

    # verbose synchronization polling is hidden unless raw=true is requested
    function result_with_host_calls(raw)
        names = ["[MTLCommandBuffer status]", "[NSObject retain]",
                 "[NSAutoreleasePool drain]",
                 "[MTLDevice newBufferWithLength:options:]"]
        Metal.Profiling.ProfileResults(;
            device=(name=String[], start=Float64[], stop=Float64[], ops=Vector{Any}[]),
            host=(name=names, calls=[10, 3, 2, 1], time=[1e-6, 1e-6, 1e-6, 2e-6]),
            host_trace=(id=[1, 2, 3, 4], start=[1e-6, 2e-6, 3e-6, 4e-6],
                        time=[1e-6, 1e-6, 1e-6, 2e-6], tid=[1, 1, 1, 1],
                        name=names),
            trace_start=0.0, wall=1e-3, trace=true, raw)
    end
    filtered = result_with_host_calls(false)
    filtered_output = sprint(show, filtered)
    @test !occursin("[MTLCommandBuffer status]", filtered_output)
    @test !occursin("[NSObject retain]", filtered_output)
    @test !occursin("[NSAutoreleasePool drain]", filtered_output)
    @test occursin("[MTLDevice newBufferWithLength:options:]", filtered_output)

    raw = result_with_host_calls(true)
    raw_output = sprint(show, raw)
    @test occursin("[MTLCommandBuffer status]", raw_output)
    @test occursin("[NSObject retain]", raw_output)
    @test occursin("[NSAutoreleasePool drain]", raw_output)

    # when the device reports GPU timestamps, the kernel and its timing should show up
    # (a paravirtualized GPU may not, so only assert when something was captured)
    if !isempty(res.device.name)
        @test any(n -> occursin("broadcast", n), res.device.name)
        @test all(>(0), res.device.stop .- res.device.start)
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
