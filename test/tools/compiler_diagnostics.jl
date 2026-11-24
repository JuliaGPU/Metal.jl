@testset "compiler crash reports" begin
    # the shape of a real report: a JSON header line, then a pretty-printed JSON body
    report(pid, reasons) = """
        {"app_name":"MTLCompilerService","bug_type":"309"}
        {
          "pid" : 1234,
          "responsiblePid" : $pid,
          "responsibleProc" : "julia",
          "termination" : {"code":1,"namespace":"METAL","reasons":[$(join(map(repr, reasons), ","))]},
          "threads" : [{"frames":[{"symbol":"abort_with_reason"}]}]
        }
        """
    reasons = ["unable to legalize instruction: %7:_(s16) = 191 %0:_, %6:_", "Context:",
               "%0:_(s16) = 90 %2:_(p64) :: (load (s16) from `i16 addrspace(64)*`)",
               "(in function: agc.main)"]

    mktempdir() do dir
        write(joinpath(dir, "MTLCompilerService-stale.ips"), report(42, ["stale"]))
        sleep(0.01)
        started = time()
        write(joinpath(dir, "MTLCompilerService-other.ips"), report(43, ["other process"]))
        write(joinpath(dir, "ReportCrash-unrelated.ips"), report(42, ["unrelated"]))
        @test Metal.compiler_crash_report(started; dir, pid=42, timeout=0) === nothing

        path = joinpath(dir, "MTLCompilerService-ours.ips")
        write(path, report(42, reasons))
        @test Metal.compiler_crash_report(started; dir, pid=42, timeout=0) == (path, reasons)
    end

    @test Metal.crash_reasons(report(42, String[]), 42) === nothing
    @test Metal.compiler_crash_report(time(); dir="/nonexistent", timeout=0) === nothing
end

@testset "AIR verification" begin
    # a call to an AIR function that doesn't exist
    unknown_air_function(a) = (a[1] = ccall("extern air.unknown.f32", llvmcall, Float32, ()); nothing)
    a = MtlArray{Float32}(undef, 1)

    # asking for verification without a verifier fails instead of skipping it
    withenv("JULIA_METAL_VERIFY_AIR" => "true", "METAL_TOOLCHAIN" => mktempdir()) do
        @test_throws "metal-opt was not found" @metal launch=false unknown_air_function(a)
    end

    # the error of a rejected kernel names the verifier and points to the dumped artifacts
    function verifier_error(env...)
        dir = mktempdir()
        msg = withenv("JULIA_METAL_VERIFY_AIR" => "true", "JULIA_METAL_DUMP_DIR" => dir,
                      "BUILDKITE" => nothing, env...) do
            try
                @metal launch=false unknown_air_function(a)
                ""
            catch err
                sprint(showerror, err)
            end
        end
        files = readdir(dir; join=true)
        @test sort(map(f -> splitext(f)[2], files)) == [".air", ".ll", ".metallib"]
        @test all(f -> occursin(f, msg), files)
        return msg
    end

    # a verifier that can't be run counts as a rejection
    let dir = mktempdir()
        touch(joinpath(dir, "metal-opt"))   # not executable
        msg = verifier_error("METAL_TOOLCHAIN" => dir)
        @test occursin("Failed to run metal-opt", msg)
        @test occursin("(verifier: $(joinpath(dir, "metal-opt")), unknown version)", msg)
    end

    if Metal.verify_air()
        tool = Metal.air_verifier()
        msg = verifier_error()
        @test occursin("invalid AIR function air.unknown.f32", msg)
        @test occursin("(verifier: $tool, $(Metal.apple_tool_version(tool)))", msg)
        @test Metal.apple_tool_version(tool) != "unknown version"
    end
end

@testset "back-end check" begin
    a = MtlArray{Float32}(undef, 1)
    # (kernels loaded from the cache aren't checked, so every test compiles a new one)
    check(f, targets, env...) = withenv("JULIA_METAL_BACKEND_CHECK" => targets, env...) do
        @metal launch=false f(a)
    end

    @test_throws "Invalid JULIA_METAL_BACKEND_CHECK target 'g17g@x'" check(a -> nothing, "g17g@x")
    @test_throws "Invalid JULIA_METAL_BACKEND_CHECK target 'M5'" check(a -> nothing, "g13g, M5")
    @test_throws "Invalid JULIA_METAL_BACKEND_CHECK target ''" check(a -> nothing, "g13g,")

    # asking for a check without the back end fails instead of skipping it
    @test_throws "applegpu-nt was not found" check(a -> nothing, "g17g",
        "METAL_TOOLCHAIN" => mktempdir(), "JULIA_METAL_VERIFY_AIR" => nothing)

    # targets are compiled for as they would be on that system
    let cfg = Metal.compiler_config(device(); macos=v"27", fastmath=true)
        target = Metal.backend_config(cfg, 10, v"26").target
        @test (target.macos, target.air, target.metal) == (v"26", v"2.8", v"4.0")
        @test target.apple_family == 10 && target.fastmath
        # a newer system loads the kernel as it is
        target = Metal.backend_config(cfg, 11, v"28").target
        @test (target.macos, target.air, target.metal) == (v"27", v"2.9", v"4.1")
    end
    # (keeping versions that were lower already)
    let cfg = Metal.compiler_config(device(); macos=v"27", metal=v"3.2")
        target = Metal.backend_config(cfg, 10, v"26").target
        @test (target.macos, target.air, target.metal) == (v"26", v"2.8", v"3.2")
    end

    # (with the release toolchain for macOS 27, which `--validate` requires anyway)
    supported(target) = try
        Metal.backend_family(Metal.backend_tools(), only(withenv(Metal.backend_targets,
                                                                 "JULIA_METAL_BACKEND_CHECK" => target)))
        true
    catch
        false
    end
    if !all(supported, ("g13g@26", "g17g@26", "g17g@27"))
        @test_skip "Apple's back end for macOS 26 and 27 not available"
    else
        @test_throws "does not support applegpu_g18g on macOS 26.0" check(a -> nothing, "g18g@26")

        # an M5 running macOS 26 crashes on a float atomic add after a device fence, which
        # GPUCompiler avoids on Apple10 GPUs only: the kernel has to be compiled for one
        fenced_add(a) = (Metal.atomic_thread_fence(Metal.MemoryFlagDevice, Metal.memory_order_seq_cst);
                         Metal.atomic_fetch_add_explicit(pointer(a), 1f0); nothing)
        @test check(fenced_add, "g17g@26") isa Metal.HostKernel
        # ... which the back end would otherwise reject
        function raw_fenced_add(a)
            ccall("extern air.atomic.fence", llvmcall, Cvoid, (Int32, Int32, Int32), 1, 5, 2)
            ccall("extern air.atomic.global.add.f32", llvmcall, Float32,
                  (Core.LLVMPtr{Float32,1}, Float32, Int32, Int32, Bool), pointer(a), 1f0, 0, 2, true)
            return
        end
        dir = joinpath(mktempdir(), "with space")
        # (the verifier rejects the untyped pointer of the raw call)
        msg = try
            check(raw_fenced_add, "g13g@26,g17g@26", "JULIA_METAL_VERIFY_AIR" => nothing,
                  "JULIA_METAL_DUMP_DIR" => dir, "BUILDKITE" => nothing)
            ""
        catch err
            sprint(showerror, err)
        end
        @test occursin("for applegpu_g17g (Apple10) on macOS 26.0", msg)
        @test occursin("LLVM ERROR: cannot select", msg)
        @test !occursin("applegpu_g13g", msg)
        # with the files and the command to reproduce it
        files = filter(f -> occursin(f, msg), readdir(dir; join=true))
        @test sort(map(f -> splitext(f)[2], files)) == [".air", ".ll", ".metallib", ".mtlp-json"]
        command = only(filter(contains("-platform_version"), split(msg, '\n')))
        proc, out = Metal.run_tool(Cmd(Base.shell_split(command)))
        @test !success(proc)
        @test occursin("LLVM ERROR: cannot select", out)

        # kernels are compiled for the target's GPU family, which can be lower than the host's
        min64(a) = (Metal.atomic_min_explicit(pointer(a), UInt64(42)); nothing)
        withenv("JULIA_METAL_BACKEND_CHECK" => "g13g") do
            @test_throws r"back-end check of applegpu_g13g.*\n.*64-bit atomic min/max requires Apple8"s @metal launch=false gpufamily=MTL.MTLGPUFamilyApple8 min64(MtlArray{UInt64}(undef, 1))
        end

        # the offline back end can't encode floating-point log arguments, so those
        # kernels aren't checked (when this fails, Apple has fixed that)
        @test_logs (:debug, r"Skipping the back-end check") min_level=Base.CoreLogging.Debug match_mode=:any check(a -> (@mtlprintf("%f\n", a[1]); nothing), "g17g@27")
    end
end
