@testset "integrated profiler" begin
    a = Metal.rand(Float32, 256, 256)
    b = similar(a)

    b .= a .+ 1f0
    Metal.synchronize()

    res = Metal.@profile b .= a .+ 1f0
    @test res isa Metal.Profiling.ProfileResults
    @test !isempty(sprint(show, res))
    @test isempty(res.host_trace.name)

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

    function profile_result(raw, names=["[MTLCommandBuffer status]", "[NSObject retain]",
                                        "[MTLDevice newBufferWithLength:options:]"])
        Metal.Profiling.ProfileResults(;
            device=(name=String[], start=Float64[], stop=Float64[], ops=Vector{Any}[]),
            host=(name=names, calls=fill(1, length(names)), time=fill(1e-6, length(names))),
            host_trace=(id=collect(1:length(names)), start=collect(1:length(names)) .* 1e-6,
                        time=fill(1e-6, length(names)), tid=fill(1, length(names)),
                        name=names),
            trace_start=0.0, wall=1e-3, trace=true, raw)
    end
    filtered = profile_result(false)
    filtered_output = sprint(show, filtered)
    @test !occursin("[MTLCommandBuffer status]", filtered_output)
    @test !occursin("[NSObject retain]", filtered_output)
    @test occursin("[MTLDevice newBufferWithLength:options:]", filtered_output)

    filtered_only = profile_result(false, ["[MTLCommandBuffer status]",
                                           "[NSObject retain]"])
    @test occursin("No host-side activity was recorded", sprint(show, filtered_only))

    raw = profile_result(true)
    raw_output = sprint(show, raw)
    @test occursin("[MTLCommandBuffer status]", raw_output)
    @test occursin("[NSObject retain]", raw_output)

    if !isempty(res.device.name)
        @test any(n -> occursin("broadcast", n), res.device.name)
        @test all(>(0), res.device.stop .- res.device.start)
    end

    res_empty = Metal.@profile (1 + 1)
    @test occursin("No GPU operations", sprint(show, res_empty))

    res_bench = Metal.@bprofile time=0.1 (b .= a .+ 1f0)
    @test res_bench isa Metal.Profiling.ProfileResults

    @test_throws ArgumentError @macroexpand Metal.@profile external=1 (1 + 1)
    @test_throws ArgumentError @macroexpand Metal.@profile external=true trace=true (1 + 1)
    @test_throws ArgumentError @macroexpand Metal.@bprofile external=true (1 + 1)
end

@testset "trace names" begin
    @test Metal.trace_name(:(@metal threads=4 vadd(a, b, c))) == "vadd"
    @test Metal.trace_name(:(Metal.@sync @metal kernel!(x))) == "kernel!"
    @test Metal.trace_name(:(y = Metal.@sync f(x))) == "f"
    @test Metal.trace_name(:(b .= a .+ 1)) == "broadcast"
    @test Metal.trace_name(:(sin.(a))) == "broadcast"
    @test Metal.trace_name(:(Base.sum(x))) == "sum"
    @test Metal.trace_name(:(a * b)) == "julia"
    @test Metal.trace_name(:(begin f(x); g(x) end)) == "julia"
end

if !capturing
    # without METAL_CAPTURE_ENABLED, capturing fails with instructions to enable it
    @test_throws "METAL_CAPTURE_ENABLED=1" Metal.@capture identity(nothing)
end

if parse(Bool, get(ENV, "CI", "false"))
    @warn "Skipping external profiling tests on CI due to sandboxing issues"
elseif !success(`xctrace version`)
    @warn "Skipping external profiling tests because xctrace is not available; please install Xcode first"
else
    @testset "external profiler" begin
        mktempdir() do tmpdir
            cd(tmpdir) do
                path = Metal.@profile external=true identity(nothing)
                @test path == joinpath(pwd(), "identity_1.trace")
                @test isdir(path)

                # Metal.jl's signposts, including the dynamic tracing ones, are recorded
                a = MtlArray([1f0])
                path = Metal.@profile external=true name="signposts" a .= 2f0
                xpath = """/trace-toc/run[@number="1"]/data/table[@schema="os-signpost" and @subsystem='"org.juliagpu.metal"']"""
                xml = read(`xcrun xctrace export --input $path --xpath $xpath`, String)
                @test occursin("Launch", xml)
            end
        end
    end
end
