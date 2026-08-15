using GPUCompiler
using .MTL
using LLVM: LLVM

# The MTLBinaryArchive machine-code cache is opt-in (off by default; cross-session hits are
# blocked by metallib non-determinism — see src/compiler/archive.jl). These tests force it
# on and exercise the full harvest → serialize → reload → hit cycle within one process,
# where a kernel's metallib is stable.

archive_kernel(x) = (i = thread_position_in_grid_1d(); @inbounds x[i] = x[i] * 2f0 + 1f0; return)

# A relocation-carrying kernel: its `DataType` header word arrives as run-time data through
# the kernel state, so the compiled pipeline depends on no session value and is archivable
# just like any other. (Under the old function-constant delivery the pipeline came from a
# *specialized* `MTLFunction`, so these kernels never got archive coverage.)
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

dev = Metal.device()
if MTL.is_virtual(dev)
    @warn "skipping binary-archive cache tests on a virtualized GPU"
else
    mktempdir() do dir
        withenv("JULIA_METAL_BINARY_ARCHIVES" => "true",
                "JULIA_METAL_BINARY_ARCHIVE_DIR" => dir) do
            @test Metal.binary_archives_enabled()

            air, metallib, entry = compile_archive_kernel(dev)

            # first link: a miss compiles the native code and harvests it into the archive
            empty!(Metal.device_archives)
            Metal.archive_hits[] = 0
            Metal.archive_misses[] = 0
            pso1 = Metal.link_pipeline(dev, air, metallib, entry)
            @test pso1 isa MTLComputePipelineState
            @test Metal.archive_misses[] == 1
            @test Metal.archive_hits[] == 0

            # serialize and confirm the archive file was written
            Metal.serialize_binary_archives()
            files = readdir(dir; join=true)
            @test length(files) == 1
            @test filesize(only(files)) > 0

            # reload from disk (fresh per-device cache) and link again: a hit serves the
            # native code straight from the archive, skipping the back-end compile
            empty!(Metal.device_archives)
            Metal.archive_hits[] = 0
            Metal.archive_misses[] = 0
            pso2 = Metal.link_pipeline(dev, air, metallib, entry)
            @test pso2 isa MTLComputePipelineState
            @test Metal.archive_hits[] == 1
            @test Metal.archive_misses[] == 0

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
                @test Metal.archive_hits[] == 1
            end
        end
    end

    # a corrupt archive file is discarded and rebuilt rather than propagating an error
    mktempdir() do dir
        withenv("JULIA_METAL_BINARY_ARCHIVES" => "true",
                "JULIA_METAL_BINARY_ARCHIVE_DIR" => dir) do
            empty!(Metal.device_archives)
            write(Metal.binary_archive_path(dev), rand(UInt8, 512))  # garbage
            @test Metal.device_archive(dev) !== nothing               # recovered
            air, metallib, entry = compile_archive_kernel(dev)
            @test Metal.link_pipeline(dev, air, metallib, entry) isa MTLComputePipelineState
        end
    end

    empty!(Metal.device_archives)
end
