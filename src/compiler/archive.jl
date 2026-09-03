## machine-code caching with MTLBinaryArchive

# Metal.jl caches each kernel's AIR-containing metallib across sessions. Creating a pipeline
# still compiles AIR to native GPU code; an `MTLBinaryArchive` caches that final stage.
#
# One archive *per kernel*, in a directory per (device, OS build), the compatibility boundary
# Apple specifies for cached native pipelines. Metal materializes every entry of an archive
# in memory when opening it and rewrites all entries when a loaded archive is modified, so a
# single growing archive would cost every session memory proportional to everything cached.
# Small per-kernel archives cost only what a session uses, are written immediately, and can
# be evicted independently.
#
# This is purely a speedup: every failure degrades silently to plain pipeline creation, and
# a stale or corrupt file is discarded and rebuilt.
#
# Archives content-key on metallib bytes, and files are named by a stable digest of the
# metallib and entry point.
# GPUCompiler makes the bytes reproducible and keeps relocations symbolic; an unexpected
# byte variant (or a hash collision) merely causes a cache miss, which Metal detects itself.
#
# Controlled by the `binary_archives` preference (see LocalPreferences.toml), overridable
# with `JULIA_METAL_BINARY_ARCHIVES`. When off, `device_archive` returns `nothing` and
# pipeline creation takes the plain path unchanged.
const _binary_archives_pref = @load_preference("binary_archives", true)::Bool

# Apple documents shader validation as incompatible with binary archives, so keep the
# archive path entirely disabled when the validation layer is active.
#
# Metal reads this environment variable before device creation. Capture it in `__init__`
# so later changes to `ENV` cannot make our state disagree with Metal's. The `nothing`
# case covers package precompilation, which runs before `__init__`.
const _shader_validation_enabled = Ref{Union{Nothing,Bool}}(nothing)
function shader_validation_enabled()
    enabled = _shader_validation_enabled[]
    return enabled === nothing ? get(ENV, "MTL_SHADER_VALIDATION", "0") != "0" : enabled
end

# The `JULIA_METAL_BINARY_ARCHIVES` env var overrides the preference (mainly for tests).
function binary_archives_enabled()
    shader_validation_enabled() && return false
    haskey(ENV, "JULIA_METAL_BINARY_ARCHIVES") &&
        return parse(Bool, ENV["JULIA_METAL_BINARY_ARCHIVES"])
    return _binary_archives_pref
end

# Directory holding the per-device archive directories. `JULIA_METAL_BINARY_ARCHIVE_DIR`
# overrides the scratch space (for tests / custom locations).
binary_archive_dir() = get(ENV, "JULIA_METAL_BINARY_ARCHIVE_DIR") do
    @get_scratch!("binary_archives")
end

# Total size of a device's archives on disk; the least recently used ones are evicted
# beyond this limit (see `prune_binary_archives`).
const _binary_archives_max_size_pref =
    @load_preference("binary_archives_max_size", 256 * 2^32)::Int
function binary_archives_max_size()
    haskey(ENV, "JULIA_METAL_BINARY_ARCHIVES_MAX_SIZE") &&
        return parse(Int, ENV["JULIA_METAL_BINARY_ARCHIVES_MAX_SIZE"])
    return _binary_archives_max_size_pref
end

struct DeviceArchive
    device::MTLDevice
    dir::String
    lock::ReentrantLock
end

const device_archives = Dict{MTLDevice, DeviceArchive}()
const device_archives_lock = ReentrantLock()

# native-code cache telemetry: how often the back-end compile was skipped (hit) vs run (miss)
const archive_hits = Threads.Atomic{Int}(0)
const archive_misses = Threads.Atomic{Int}(0)

# The OS build (e.g. "24A335") — not the marketing version — is what invalidates cached GPU
# code, per Apple's guidance. Computed once per session (see `reset_binary_archives!`).
const _os_build = Ref{Union{Nothing,String}}(nothing)
function os_build()
    build = _os_build[]
    build === nothing || return build
    _os_build[] = strip(read(`/usr/bin/sw_vers -buildVersion`, String))
end

# The precompile workload exercises this machinery too (its pipelines are served from, but
# never harvested into, an archive), so none of the state it leaves behind may survive into
# the package image: device handles, the hit/miss counters, and the OS build of the machine
# that precompiled. Called from `__init__`.
function reset_binary_archives!()
    Base.@lock device_archives_lock empty!(device_archives)
    archive_hits[] = 0
    archive_misses[] = 0
    _os_build[] = nothing
    return
end

# A device's archives live in `<device>-<OS build>/`, one
# `<hash>.binary.metallib` per kernel. The device name is sanitized to a conservative
# character set so that the build suffix can be recognized when cleaning up other builds.
const binary_archive_ext = ".binary.metallib"
const legacy_binary_archive_ext = ".bin"
device_archive_key(dev::MTLDevice) = replace(string(dev.name), r"[^0-9A-Za-z._]" => "_")
archive_build_suffix() = "-" * os_build()
function device_archive_dir(dev::MTLDevice)
    joinpath(binary_archive_dir(), device_archive_key(dev) * archive_build_suffix())
end
function binary_archive_name(metallib::Vector{UInt8}, entry::String)
    # Hashing the fixed-size metallib digest followed by the entry point unambiguously keys
    # both inputs without copying the (potentially large) metallib.
    ctx = SHA2_256_CTX()
    update!(ctx, sha256(metallib))
    update!(ctx, codeunits(entry))
    return bytes2hex(digest!(ctx)) * binary_archive_ext
end
function binary_archive_path(dev::MTLDevice, metallib::Vector{UInt8}, entry::String)
    joinpath(device_archive_dir(dev), binary_archive_name(metallib, entry))
end

# Look up (or lazily set up) the per-device archive directory, or `nothing` when archiving
# is disabled or unavailable. Archives of other OS builds and stray files are cleaned up
# on first use rather than only at exit, which a killed session never reaches.
function device_archive(dev::MTLDevice)
    binary_archives_enabled() || return nothing
    try
        Base.@lock device_archives_lock begin
            get!(device_archives, dev) do
                dir = device_archive_dir(dev)
                mkpath(dir)
                da = DeviceArchive(dev, dir, ReentrantLock())
                try
                    remove_stale_binary_archives(da)
                catch err
                    @debug "Failed to clean up stale binary archives" exception=err
                end
                da
            end
        end
    catch err
        @debug "Binary archive unavailable" exception=err
        nothing
    end
end

# Create a compute pipeline state for `fun`, serving its native code from the kernel's
# archive on a hit and harvesting it into a new archive on a miss. Falls back to plain
# creation when archiving is unavailable. A real back-end compile failure propagates.
function archived_pipeline(dev::MTLDevice, fun::MTLFunction, metallib::Vector{UInt8},
                           entry::String)
    da = device_archive(dev)
    da === nothing && return MTLComputePipelineState(dev, fun)
    path = binary_archive_path(dev, metallib, entry)

    Base.@lock da.lock begin
        # serve straight from the archive when the native code is already there. Metal
        # verifies the entry against the function's metallib, so a stale or colliding file
        # is a miss rather than a wrong kernel.
        pso = try
            if isfile(path)
                archive = MTLBinaryArchive(dev, path)
                desc = MTLComputePipelineDescriptor()
                desc.computeFunction = fun
                desc.binaryArchives = NSArray([archive])
                MTLComputePipelineState(dev, desc;
                                        options=MTL.MTLPipelineOptionFailOnBinaryArchiveMiss)
            else
                nothing
            end
        catch err
            isa(err, NSError) || rethrow()
            nothing   # miss, or an unreadable file (replaced below)
        end
        if pso !== nothing
            Threads.atomic_add!(archive_hits, 1)
            @debug "Binary archive hit for $(fun.name)"
            # keep the entry young for LRU eviction
            try touch(path) catch end
            return pso
        end
        Threads.atomic_add!(archive_misses, 1)
        @debug "Binary archive miss for $(fun.name)"

        # miss: compile normally, then harvest the fresh native code for next time. Skip
        # harvesting during precompilation — the archive holds no session-local handles,
        # but writing it there would be wasted work.
        pso = MTLComputePipelineState(dev, fun)
        if ccall(:jl_generating_output, Cint, ()) != 1
            try
                archive = MTLBinaryArchive(dev, MTLBinaryArchiveDescriptor())
                harvest = MTLComputePipelineDescriptor()
                harvest.computeFunction = fun
                add_functions!(archive, harvest)
                # write atomically: concurrent sessions may harvest the same kernel
                mkpath(dirname(path))
                tmp = tempname(dirname(path))
                try
                    @autoreleasepool write(tmp, archive)
                    mv(tmp, path; force=true)
                catch
                    rm(tmp; force=true)
                    rethrow()
                end
            catch err
                isa(err, NSError) || isa(err, SystemError) || isa(err, Base.IOError) ||
                    rethrow()
                @debug "Failed to harvest kernel into binary archive" exception=err
            end
        end
        return pso
    end
end

# Bound each used device's cache on disk: evict the least recently used archives beyond
# `binary_archives_max_size`, and remove archives of other OS builds (which can never be
# loaded again). Restricting cleanup to devices used in this session avoids touching
# unrelated files when the archive-directory override points at a shared path.
function prune_binary_archives()
    Base.@lock device_archives_lock begin
        for da in values(device_archives)
            Base.@lock da.lock begin
                try
                    evict_binary_archives(da.dir, binary_archives_max_size())
                    remove_stale_binary_archives(da)
                catch err
                    @debug "Failed to prune binary archives in $(da.dir)" exception=err
                end
            end
        end
    end
end

# Evict the oldest archives (by modification time, refreshed on every hit) until the
# directory fits `max_size`.
function evict_binary_archives(dir::String, max_size::Int)
    isdir(dir) || return
    files = [joinpath(dir, file) for file in readdir(dir) if endswith(file, binary_archive_ext)]
    entries = [(mtime(file), filesize(file), file) for file in files if isfile(file)]
    total = sum(entry[2] for entry in entries; init=0)
    total <= max_size && return
    sort!(entries)
    for (_, size, file) in entries
        rm(file; force=true)
        total -= size
        total <= max_size && break
    end
end

# Remove archive directories for other OS builds of this device, files from the obsolete
# `.bin` layouts, and temporary files left behind by killed sessions.
function remove_stale_binary_archives(da::DeviceArchive)
    root = dirname(da.dir)
    current = basename(da.dir)
    prefix = device_archive_key(da.device) * "-"
    for entry in readdir(root)
        entry == current && continue
        path = joinpath(root, entry)
        if startswith(entry, prefix) &&
           (isdir(path) || endswith(entry, legacy_binary_archive_ext))
            rm(path; force=true, recursive=true)
        elseif startswith(entry, "jl_") && isfile(path) && stale_tempfile(path)
            rm(path; force=true)
        end
    end
    for entry in readdir(da.dir)
        path = joinpath(da.dir, entry)
        if endswith(entry, legacy_binary_archive_ext) && isfile(path)
            rm(path; force=true)
        elseif !endswith(entry, binary_archive_ext) && isfile(path) && stale_tempfile(path)
            rm(path; force=true)
        end
    end
end

# A temporary file that is old enough not to belong to a session that is still writing it.
stale_tempfile(path::String) = time() - mtime(path) > 3600
