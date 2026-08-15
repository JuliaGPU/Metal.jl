## machine-code caching with MTLBinaryArchive

# GPUCompiler caches each kernel's metallib (AIR) across sessions; creating a pipeline
# state from it still runs the AIR→native back-end compile, the most expensive step of a
# cold launch. An `MTLBinaryArchive` serializes that native code, so a later session can
# skip the compile entirely.
#
# One archive per (device, OS build) — native code is portable across neither. This is
# purely a speedup: every failure degrades silently to plain pipeline creation, and a
# stale or corrupt archive is discarded and rebuilt.
#
# DISABLED BY DEFAULT. `MTLBinaryArchive` content-keys on the exact metallib bytes, but a
# kernel's metallib is not yet byte-stable *across processes*. Two former causes are now
# fixed — a bimodal `llvm-downgrade` residual (pointer-ordered type enumeration; needs a
# LLVMDowngrader_jll bump to ship) and Julia's per-session codegen counters in symbol and
# relocation names — leaving in-process compiles byte-identical. The remaining cross-session
# gap is debug-info: the linked module carries many identical `DICompileUnit`s and each
# `DISubprogram` picks a different one per session. Until that too is deduplicated, cross-
# session hits don't reliably materialize, so the tier stays off. The machinery below is
# kept, opt-in via the `binary_archives` preference, so it works the moment that lands. When
# off, `device_archive` returns `nothing` and pipeline creation takes the plain path unchanged.
const _binary_archives_pref = @load_preference("binary_archives", false)::Bool

# The `JULIA_METAL_BINARY_ARCHIVES` env var overrides the preference (mainly for tests).
function binary_archives_enabled()
    haskey(ENV, "JULIA_METAL_BINARY_ARCHIVES") &&
        return parse(Bool, ENV["JULIA_METAL_BINARY_ARCHIVES"])
    return _binary_archives_pref
end

# Directory holding the per-device archives. `JULIA_METAL_BINARY_ARCHIVE_DIR` overrides the
# scratch space (for tests / custom locations).
binary_archive_dir() = get(ENV, "JULIA_METAL_BINARY_ARCHIVE_DIR") do
    @get_scratch!("binary_archives")
end

mutable struct DeviceArchive
    const archive::MTLBinaryArchive
    const path::String
    dirty::Bool
    const lock::ReentrantLock
end

const device_archives = Dict{MTLDevice, DeviceArchive}()
const device_archives_lock = ReentrantLock()

# native-code cache telemetry: how often the back-end compile was skipped (hit) vs run (miss)
const archive_hits = Threads.Atomic{Int}(0)
const archive_misses = Threads.Atomic{Int}(0)

# The OS build (e.g. "24A335") — not the marketing version — is what invalidates cached GPU
# code, per Apple's guidance. Computed once.
const _os_build = Ref{String}()
function os_build()
    isassigned(_os_build) && return _os_build[]
    _os_build[] = strip(read(`/usr/bin/sw_vers -buildVersion`, String))
end

function binary_archive_path(dev::MTLDevice)
    key = replace("$(dev.name)-$(os_build())", r"[^0-9A-Za-z._-]" => "_")
    joinpath(binary_archive_dir(), key * ".bin")
end

# Look up (or lazily open) the per-device archive, or `nothing` when archiving is disabled
# or unavailable. A corrupt/incompatible file is discarded and replaced with an empty one.
function device_archive(dev::MTLDevice)
    binary_archives_enabled() || return nothing
    try
        Base.@lock device_archives_lock begin
            get!(device_archives, dev) do
                path = binary_archive_path(dev)
                archive = try
                    isfile(path) ? MTLBinaryArchive(dev, path) :
                                   MTLBinaryArchive(dev, MTLBinaryArchiveDescriptor())
                catch err
                    isa(err, NSError) || rethrow()
                    @debug "Discarding unreadable binary archive at $path" exception=err
                    rm(path; force=true)
                    MTLBinaryArchive(dev, MTLBinaryArchiveDescriptor())
                end
                DeviceArchive(archive, path, false, ReentrantLock())
            end
        end
    catch err
        @debug "Binary archive unavailable" exception=err
        nothing
    end
end

# Create a compute pipeline state for `fun`, serving its native code from the device's
# binary archive on a hit and harvesting it into the archive on a miss. Falls back to plain
# creation when archiving is unavailable. A real back-end compile failure propagates.
function archived_pipeline(dev::MTLDevice, fun::MTLFunction)
    da = device_archive(dev)
    da === nothing && return MTLComputePipelineState(dev, fun)

    Base.@lock da.lock begin
        desc = MTLComputePipelineDescriptor()
        desc.computeFunction = fun
        desc.binaryArchives = NSArray([da.archive])

        # serve straight from the archive when the native code is already there
        pso = try
            MTLComputePipelineState(dev, desc;
                                    options=MTL.MTLPipelineOptionFailOnBinaryArchiveMiss)
        catch err
            isa(err, NSError) || rethrow()
            nothing   # miss
        end
        if pso !== nothing
            Threads.atomic_add!(archive_hits, 1)
            return pso
        end
        Threads.atomic_add!(archive_misses, 1)

        # miss: compile normally, then harvest the fresh native code for next time. Skip
        # harvesting during precompilation — the archive holds no session-local handles,
        # but serializing it there would be wasted work.
        pso = MTLComputePipelineState(dev, fun)
        if ccall(:jl_generating_output, Cint, ()) != 1
            try
                harvest = MTLComputePipelineDescriptor()
                harvest.computeFunction = fun
                add_functions!(da.archive, harvest)
                da.dirty = true
            catch err
                isa(err, NSError) || rethrow()
                @debug "Failed to harvest kernel into binary archive" exception=err
            end
        end
        return pso
    end
end

# Serialize every dirty archive, atomically (write to a temp file, then rename over).
# Concurrent processes race on the rename; the loser's kernels just recompile next time.
function serialize_binary_archives()
    Base.@lock device_archives_lock begin
        for da in values(device_archives)
            Base.@lock da.lock begin
                da.dirty || continue
                try
                    tmp = tempname(dirname(da.path))
                    @autoreleasepool write(tmp, da.archive)
                    mv(tmp, da.path; force=true)
                    da.dirty = false
                catch err
                    @debug "Failed to serialize binary archive to $(da.path)" exception=err
                end
            end
        end
    end
end
