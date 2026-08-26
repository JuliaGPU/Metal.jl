using GPUCompiler
using .MTL
using LLVM: LLVM

# Exercise the archive cache in temporary directories, including cross-process hits.

archive_kernel(x) = (i = thread_position_in_grid_1d(); @inbounds x[i] = x[i] * 2f0 + 1f0; return)

# A kernel spanning several CodeInstances (the `@noinline` callee and the exception
# machinery it reaches), which links in the runtime library: the case where Julia's
# per-CodeInstance link order used to make the metallib session-dependent.
@noinline archive_checked(x::Float32) = (x < 0f0 && throw(ArgumentError("negative")); sqrt(x))
function archive_throwing_kernel(x)
    i = thread_position_in_grid_1d()
    @inbounds x[i] = archive_checked(x[i])
    return
end

# A relocation-carrying kernel: its `DataType` header word arrives as run-time data through
# the kernel state, so the compiled pipeline depends on no session value and is archivable
# just like any other.
struct ArchiveRGB; r::Int32; g::Int32; b::Int32; end
@noinline archive_produce(cond::Bool, a::Int32) = cond ? a : ArchiveRGB(11, 22, 33)
function archive_reloc_kernel(out, cond::Bool, a::Int32)
    x = archive_produce(cond, a)
    @inbounds out[1] = x isa ArchiveRGB ? x.r : Int32(-2)
    return
end

function compile_archive_kernel(dev, f=archive_kernel, tt=Tuple{MtlDeviceVector{Float32,1}})
    cfg = Metal.compiler_config(dev; kernel=true, name=nothing)
    src = Metal.methodinstance(typeof(f), tt, Base.get_world_counter())
    job = GPUCompiler.CompilerJob(src, cfg, Base.get_world_counter())
    art = Metal.compile_to_metallib(job)
    return art.air, art.metallib, art.entry
end

function reset_archive_state!()
    Metal.reset_binary_archives!()
end

dev = Metal.device()
if MTL.is_virtual(dev)
    @warn "skipping binary-archive cache tests on a virtualized GPU"
else

@testset "in-process cycle" begin
    mktempdir() do dir
        withenv("JULIA_METAL_BINARY_ARCHIVES" => "true",
                "JULIA_METAL_BINARY_ARCHIVE_DIR" => dir) do
            @test Metal.binary_archives_enabled()

            air, metallib, entry = compile_archive_kernel(dev)
            path = Metal.binary_archive_path(dev, metallib, entry)
            @test dirname(dirname(path)) == dir
            @test length(chopsuffix(basename(path), Metal.binary_archive_ext)) == 64

            # first link: a miss compiles the native code and harvests it into the kernel's
            # archive, which is written right away
            reset_archive_state!()
            pso1 = Metal.link_pipeline(dev, air, metallib, entry)
            @test pso1 isa MTLComputePipelineState
            @test Metal.archive_misses[] == 1
            @test Metal.archive_hits[] == 0
            @test isfile(path)
            @test filesize(path) > 0
            @test count(endswith(Metal.binary_archive_ext), readdir(dirname(path))) == 1

            # a fresh per-device cache linking again: a hit serves the native code straight
            # from the archive, skipping the back-end compile
            reset_archive_state!()
            pso2 = Metal.link_pipeline(dev, air, metallib, entry)
            @test pso2 isa MTLComputePipelineState
            if shader_validation
                # shader validation relies on live shader instrumentation and is
                # incompatible with binary archives: archived (uninstrumented) binaries
                # never match, so every lookup gracefully degrades to a miss
                @test Metal.archive_hits[] == 0
                @test Metal.archive_misses[] == 1
            else
                @test Metal.archive_hits[] == 1
                @test Metal.archive_misses[] == 0
            end

            # a relocation-carrying kernel archives and hits the same way (its boxed-union
            # constant needs `demote_boxed_constants!`, LLVM 17+ / Julia 1.12+)
            if LLVM.version() >= v"17"
                reloc_art = compile_archive_kernel(
                    dev, archive_reloc_kernel, Tuple{MtlDeviceVector{Int32,1}, Bool, Int32})
                Metal.archive_hits[] = 0
                Metal.archive_misses[] = 0
                @test Metal.link_pipeline(dev, reloc_art...) isa MTLComputePipelineState
                @test Metal.archive_misses[] == 1
                @test Metal.link_pipeline(dev, reloc_art...) isa MTLComputePipelineState
                if shader_validation
                    @test Metal.archive_hits[] == 0
                    @test Metal.archive_misses[] == 2
                else
                    @test Metal.archive_hits[] == 1
                end
            end
        end
    end
    reset_archive_state!()
end

@testset "corrupt or stale archives are rebuilt" begin
    mktempdir() do dir
        withenv("JULIA_METAL_BINARY_ARCHIVES" => "true",
                "JULIA_METAL_BINARY_ARCHIVE_DIR" => dir) do
            air, metallib, entry = compile_archive_kernel(dev)
            path = Metal.binary_archive_path(dev, metallib, entry)

            # a corrupt file is a miss and gets replaced rather than propagating an error
            reset_archive_state!()
            mkpath(dirname(path))
            write(path, rand(UInt8, 512))  # garbage
            @test Metal.link_pipeline(dev, air, metallib, entry) isa MTLComputePipelineState
            @test Metal.archive_misses[] == 1
            @test isfile(path)
            @test filesize(path) != 512
            reset_archive_state!()
            Metal.link_pipeline(dev, air, metallib, entry)
            @test Metal.archive_hits[] == (shader_validation ? 0 : 1)

            # a valid archive holding a different kernel (as after a hash collision or a
            # stale file) fails Metal's content check: a miss, and the file is replaced
            other = compile_archive_kernel(dev, archive_throwing_kernel,
                                           Tuple{MtlDeviceVector{Float32,1}})
            reset_archive_state!()
            Metal.link_pipeline(dev, other...)
            other_path = Metal.binary_archive_path(dev, other[2], other[3])
            @test other_path != path
            cp(other_path, path; force=true)
            reset_archive_state!()
            @test Metal.link_pipeline(dev, air, metallib, entry) isa MTLComputePipelineState
            @test Metal.archive_hits[] == 0
            @test Metal.archive_misses[] == 1
            @test read(path) != read(other_path)
            reset_archive_state!()
            Metal.link_pipeline(dev, air, metallib, entry)
            @test Metal.archive_hits[] == (shader_validation ? 0 : 1)
        end
    end
    reset_archive_state!()
end

@testset "bounded growth" begin
    mktempdir() do root
        dir = joinpath(root, "nested")
        withenv("JULIA_METAL_BINARY_ARCHIVES" => "true",
                "JULIA_METAL_BINARY_ARCHIVE_DIR" => dir) do
            art1 = compile_archive_kernel(dev)
            art2 = compile_archive_kernel(dev, archive_throwing_kernel,
                                          Tuple{MtlDeviceVector{Float32,1}})
            path1 = Metal.binary_archive_path(dev, art1[2], art1[3])
            path2 = Metal.binary_archive_path(dev, art2[2], art2[3])
            device_dir = dirname(path1)
            @test dirname(path2) == device_dir

            # the least recently used archives are evicted beyond the size limit
            reset_archive_state!()
            Metal.link_pipeline(dev, art1...)
            Metal.link_pipeline(dev, art2...)
            @test isfile(path1) && isfile(path2)
            # make sure `path2` counts as more recently used
            touch(path1); sleep(0.01); touch(path2)
            withenv("JULIA_METAL_BINARY_ARCHIVES_MAX_SIZE" => string(filesize(path2))) do
                Metal.prune_binary_archives()
            end
            @test !isfile(path1)
            @test isfile(path2)
            withenv("JULIA_METAL_BINARY_ARCHIVES_MAX_SIZE" => "1") do
                Metal.prune_binary_archives()
            end
            @test !isfile(path2)
            # the cache simply refills afterwards
            reset_archive_state!()
            Metal.link_pipeline(dev, art1...)
            @test Metal.archive_misses[] == 1
            @test isfile(path1)

            # archives of other OS builds for this device are removed, as are files from
            # the old `.bin` layouts, without touching unrelated files
            device_key = chopsuffix(basename(device_dir), Metal.archive_build_suffix())
            stale_dir = joinpath(dir, device_key * "-19A000")
            mkpath(stale_dir); touch(joinpath(stale_dir, "old.binary.metallib"))
            legacy = joinpath(dir, device_key * "-19A000.bin")
            touch(legacy)
            legacy_kernel = joinpath(device_dir, "0123456789abcdef.bin")
            touch(legacy_kernel)
            foreign_dir = joinpath(dir, "Some_Device-19A000")
            mkpath(foreign_dir); touch(joinpath(foreign_dir, "0123456789abcdef.bin"))
            other = joinpath(dir, "unrelated.txt")
            touch(other)
            Metal.prune_binary_archives()
            @test !isdir(stale_dir)
            @test !isfile(legacy)
            @test !isfile(legacy_kernel)
            @test isdir(foreign_dir)
            @test isfile(other)
            @test isfile(path1)

            # the same happens when a session first uses the device's archives, so that a
            # session killed before exit does not leave stale data behind forever
            mkpath(stale_dir); touch(joinpath(stale_dir, "old.binary.metallib"))
            touch(legacy)
            touch(legacy_kernel)
            reset_archive_state!()
            @test Metal.device_archive(dev) !== nothing
            @test !isdir(stale_dir)
            @test !isfile(legacy)
            @test !isfile(legacy_kernel)
            @test isdir(foreign_dir)
            @test isfile(path1)
        end
    end
    reset_archive_state!()
end

@testset "byte-stable metallibs" begin
    # The archive content-keys on metallib bytes; GPUCompiler covers cross-session stability.
    for (f, tt) in [(archive_kernel,          Tuple{MtlDeviceVector{Float32,1}}),
                    (archive_throwing_kernel, Tuple{MtlDeviceVector{Float32,1}})]
        _, metallib1, _ = compile_archive_kernel(dev, f, tt)
        _, metallib2, _ = compile_archive_kernel(dev, f, tt)
        @test metallib1 == metallib2
    end
    if LLVM.version() >= v"17"
        tt = Tuple{MtlDeviceVector{Int32,1}, Bool, Int32}
        _, metallib1, _ = compile_archive_kernel(dev, archive_reloc_kernel, tt)
        _, metallib2, _ = compile_archive_kernel(dev, archive_reloc_kernel, tt)
        @test metallib1 == metallib2
    end
end

@testset "cross-process hits" begin
    if shader_validation
        # Validation instruments pipelines at creation time, so an archive harvested from
        # the uninstrumented descriptor intentionally cannot satisfy a lookup.
        @test_skip false
    else
        # Process B must hit the archives written by process A, including for a kernel
        # spanning multiple CodeInstances and one carrying relocations.
        workload = raw"""
        using Metal
        using LLVM: LLVM

        archive_kernel(x) = (i = thread_position_in_grid_1d(); @inbounds x[i] = x[i] * 2f0 + 1f0; return)

        @noinline archive_checked(x::Float32) = (x < 0f0 && throw(ArgumentError("negative")); sqrt(x))
        function archive_throwing_kernel(x)
            i = thread_position_in_grid_1d()
            @inbounds x[i] = archive_checked(x[i])
            return
        end

        struct ArchiveRGB; r::Int32; g::Int32; b::Int32; end
        @noinline archive_produce(cond::Bool, a::Int32) = cond ? a : ArchiveRGB(11, 22, 33)
        function archive_reloc_kernel(out, cond::Bool, a::Int32)
            x = archive_produce(cond, a)
            @inbounds out[1] = x isa ArchiveRGB ? x.r : Int32(-2)
            return
        end

        let x = MtlArray(Float32[1, 2, 3])
            Metal.@sync @metal threads=3 archive_kernel(x)
            @assert Array(x) == Float32[3, 5, 7]
        end
        let x = MtlArray(Float32[4, 9, 16])
            Metal.@sync @metal threads=3 archive_throwing_kernel(x)
            @assert Array(x) == Float32[2, 3, 4]
        end
        if LLVM.version() >= v"17"
            out = Metal.zeros(Int32, 1)
            Metal.@sync @metal threads=1 archive_reloc_kernel(out, false, Int32(7))
            @assert Array(out)[1] == 11
        end
        println("HITS=", Metal.archive_hits[], " MISSES=", Metal.archive_misses[])
        """
        # the kernels launched explicitly; helpers like `Metal.zeros` launch more
        nkernels = LLVM.version() >= v"17" ? 3 : 2

        function run_workload(dir)
            env = copy(ENV)
            env["JULIA_METAL_BINARY_ARCHIVES"] = "true"
            env["JULIA_METAL_BINARY_ARCHIVE_DIR"] = dir
            cmd = `$(Base.julia_cmd()) --startup-file=no --project=$(Base.active_project()) -e $workload`
            out = read(setenv(cmd, env), String)
            m = match(r"HITS=(\d+) MISSES=(\d+)", out)
            m === nothing && error("workload did not report archive statistics:\n$out")
            return parse(Int, m.captures[1]), parse(Int, m.captures[2])
        end

        mktempdir() do dir
            # process A: everything misses and is harvested into per-kernel archives
            hits_a, misses_a = run_workload(dir)
            @test hits_a == 0
            @test misses_a >= nkernels
            device_dir = only(readdir(dir; join=true))
            @test count(endswith(Metal.binary_archive_ext), readdir(device_dir)) == misses_a

            # process B: a fresh session is served from the archive for every kernel
            hits_b, misses_b = run_workload(dir)
            @test hits_b == misses_a
            @test misses_b == 0
        end
    end
end

end
