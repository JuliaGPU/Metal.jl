# Integrated, lightweight profiler.
#
# Unlike `Metal.@profile external=true` (which drives Xcode's `xctrace`), this profiler runs
# entirely in-process and needs no developer tools. It captures two things and shows them as
# separate tables, both on one (mach) clock:
#
#  - device-side GPU operations: by hooking the single `commit!` chokepoint all GPU work
#    passes through (`MTL.profile_hook`), retaining each committed command buffer, and reading
#    its `GPUStartTime`/`GPUEndTime` after synchronizing. Metal.jl issues ~one command buffer
#    per GPU operation, so per-buffer timing maps cleanly onto per-operation timing.
#
#  - host-side Objective-C API calls: by subscribing to ObjectiveC.jl's runtime call tracer
#    (`ObjectiveC.tracing_subscribe`), aggregating calls per (class, selector). This surfaces host
#    behavior such as APIs being called too often — the analog of CUDA.jl's CUPTI host trace.

module Profiling

import ..Metal: MTL, synchronize, device_synchronize

import ObjectiveC
using ObjectiveC.Foundation: retain, release
using ObjectiveC: @autoreleasepool

using Printf: @sprintf
using Statistics: mean, std, quantile

using PrettyTables: pretty_table, TextHighlighter
using Crayons: @crayon_str

# raw monotonic clock, shared domain with `GPUStartTime` (NOT `time_ns`); convert via the
# ObjectiveC tracer's timebase.
@inline _mach_now() = ccall(:mach_absolute_time, UInt64, ())
_maxthreadid() = isdefined(Threads, :maxthreadid) ? Threads.maxthreadid() : Threads.nthreads()


#
# data collection
#

# kernel labels are set as "MTLCommandBuffer(<fn>)"; show just the operation name.
function clean_label(name::String)
    m = match(r"^MTLCommandBuffer\((.*)\)$", name)
    m === nothing ? name : String(m.captures[1])
end

# invoked from `MTL.commit!` for every committed command buffer while profiling is active.
# runs synchronously on the calling (Julia) thread, so it only appends to `records`; the
# actual GPU timestamps are read later, after synchronization (see `profile_internally`).
function record_commit!(records, cmdbuf)
    label = cmdbuf.label
    # command buffers without a label (e.g. the empty sentinels committed by
    # `nonblocking_synchronization`) are bookkeeping, not user work — skip them.
    label === nothing && return
    name = String(label)
    isempty(name) && return

    # keep the command buffer alive until we've read its timestamps: Metal only retains a
    # committed buffer until it completes, and our `last_committed` slot holds just the most
    # recent one, so an intermediate buffer could otherwise be freed before we read it.
    retain(cmdbuf)
    push!(records, (clean_label(name), cmdbuf))
    return
end


#
# host-side Objective-C API trace
#

# running count + total time per (class, selector). bounded by the number of distinct calls
# (so `@bprofile`'s long runs stay bounded), and accumulated per-thread to avoid locking.
mutable struct ApiStat
    count::Int
    ticks::UInt64
end

struct HostCollector
    tables::Vector{Dict{Tuple{Symbol,Symbol},ApiStat}}
end
HostCollector() = HostCollector([Dict{Tuple{Symbol,Symbol},ApiStat}() for _ in 1:_maxthreadid()])

# the ObjectiveC tracing callback: runs on the calling thread for every `@objc` call
@inline function (hc::HostCollector)(class::Symbol, sel::Symbol, t0::UInt64, t1::UInt64)
    tid = Threads.threadid()
    tid <= length(hc.tables) || return
    tbl = @inbounds hc.tables[tid]
    st = get!(() -> ApiStat(0, UInt64(0)), tbl, (class, sel))
    st.count += 1
    st.ticks += t1 - t0
    return
end

function merge_tables(hc::HostCollector)
    merged = Dict{Tuple{Symbol,Symbol},ApiStat}()
    for tbl in hc.tables, (k, st) in tbl
        m = get!(() -> ApiStat(0, UInt64(0)), merged, k)
        m.count += st.count
        m.ticks += st.ticks
    end
    return merged
end


#
# results
#

struct ProfileResults
    # device-side GPU operations, one entry per captured command buffer (commit order)
    name::Vector{String}
    start::Vector{Float64}  # GPU start time, in seconds (mach clock)
    stop::Vector{Float64}   # GPU end time, in seconds (mach clock)

    # host-side Objective-C API calls, aggregated per "[class selector]"
    host_name::Vector{String}
    host_calls::Vector{Int}
    host_time::Vector{Float64}  # total time spent in this call, in seconds

    wall::Float64  # wall-clock duration of the profiled region, in seconds
    trace::Bool    # display the device side chronologically rather than as a summary
end

function profile_internally(@nospecialize(f); trace::Bool=false)
    records = Tuple{String,Any}[]
    host = HostCollector()

    # drain any work that was already in flight, so we only capture `f`'s operations
    device_synchronize()

    prev = MTL.profile_hook[]
    MTL.profile_hook[] = cmdbuf -> record_commit!(records, cmdbuf)
    ObjectiveC.tracing_subscribe(host)
    t_start = _mach_now()
    try
        f()
    finally
        # stop host tracing before our own synchronization, so the trace reflects `f`'s calls
        ObjectiveC.tracing_unsubscribe()
        MTL.profile_hook[] = prev
    end

    # wait for all captured work to finish before reading its timestamps
    device_synchronize()
    wall = (_mach_now() - t_start) * ObjectiveC.tracing_timebase() / 1e9

    # device side: read each completed buffer's GPU timestamps. `GPUStartTime`/`GPUEndTime`
    # are only valid once completed; skip anything that errored or never ran. (We do NOT fall
    # back to `kernelStartTime`/`kernelEndTime` — those are CPU-side scheduling latency, not
    # GPU execution.)
    name = String[]
    start = Float64[]
    stop = Float64[]
    @autoreleasepool begin
        for (opname, cmdbuf) in records
            if cmdbuf.status == MTL.MTLCommandBufferStatusCompleted
                t0 = cmdbuf.GPUStartTime
                t1 = cmdbuf.GPUEndTime
                if t1 > t0
                    push!(name, opname)
                    push!(start, t0)
                    push!(stop, t1)
                end
            end
            release(cmdbuf)
        end
    end

    # host side: flatten the per-thread aggregation
    tb = ObjectiveC.tracing_timebase()
    host_name = String[]
    host_calls = Int[]
    host_time = Float64[]
    for ((class, sel), st) in merge_tables(host)
        push!(host_name, "[$class $sel]")
        push!(host_calls, st.count)
        push!(host_time, st.ticks * tb / 1e9)
    end

    return ProfileResults(name, start, stop, host_name, host_calls, host_time, wall, trace)
end


#
# display
#

format_percentage(x::Number) = @sprintf("%.2f%%", x * 100)

function format_time(ts::Number...)
    # the first number determines the scale and unit
    t = ts[1]
    range, unit = if abs(t) < 1e-6
        1e9, "ns"
    elseif abs(t) < 1e-3
        1e6, "µs"
    elseif abs(t) < 1
        1e3, "ms"
    else
        1, "s"
    end

    strs = String[]
    let io = IOBuffer()
        Base.print(io, round(t * range, digits=2), " ", unit)
        push!(strs, String(take!(io)))
    end
    for t in ts[2:end]
        let io = IOBuffer()
            Base.print(io, round(t * range, digits=2))
            push!(strs, String(take!(io)))
        end
    end

    length(strs) == 1 ? strs[1] : strs
end

# the GPU time actually spent busy, as the union of all (possibly overlapping) operation
# intervals — Metal runs independent command buffers in parallel, so summing durations would
# overcount. Used only for the informational header.
function busy_time(start, stop)
    isempty(start) && return 0.0
    perm = sortperm(start)
    total = 0.0
    cur_start = start[perm[1]]
    cur_stop = stop[perm[1]]
    for k in 2:length(perm)
        s, e = start[perm[k]], stop[perm[k]]
        if s > cur_stop
            total += cur_stop - cur_start
            cur_start, cur_stop = s, e
        else
            cur_stop = max(cur_stop, e)
        end
    end
    total + (cur_stop - cur_start)
end

# group per-operation times by name into total/calls/distribution/ratio, sorted by ratio.
# `span` (wall-clock GPU span) is the ratio denominator, NOT the sum of times: with
# overlapping command buffers a sum-based denominator could push ratios past 100%.
function summarize_trace(names, times, span)
    groups = Dict{String,Vector{Float64}}()
    for (name, t) in zip(names, times)
        push!(get!(Vector{Float64}, groups, name), t)
    end

    n = length(groups)
    out_name = Vector{String}(undef, n)
    out_time = Vector{Float64}(undef, n)
    out_calls = Vector{Int}(undef, n)
    out_dist = Vector{Union{Missing,@NamedTuple{std::Float64, mean::Float64, min::Float64, max::Float64}}}(undef, n)
    for (i, (name, ts)) in enumerate(groups)
        out_name[i] = name
        out_time[i] = sum(ts)
        out_calls[i] = length(ts)
        out_dist[i] = length(ts) == 1 ? missing :
            (; std=std(ts), mean=mean(ts), min=minimum(ts), max=maximum(ts))
    end
    out_ratio = out_time ./ span

    perm = sortperm(out_ratio; rev=true)
    return (name=out_name[perm], time=out_time[perm], calls=out_calls[perm],
            time_dist=out_dist[perm], time_ratio=out_ratio[perm])
end

# highlight slow entries (by the `:time` column): red for the slowest 5%, yellow for 25%.
function time_highlighters(df)
    relevant = df.time[df.time .>= 1e-8]
    isempty(relevant) && return TextHighlighter[]
    p75 = quantile(relevant, 0.75)
    p95 = quantile(relevant, 0.95)

    hl_p95 = TextHighlighter((data, i, j) -> (keys(data)[j] == :time) && (data[j][i] >= p95),
                             crayon"red")
    hl_p75 = TextHighlighter((data, i, j) -> (keys(data)[j] == :time) && (data[j][i] >= p75),
                             crayon"yellow")
    hl_bold = TextHighlighter((data, i, j) -> (keys(data)[j] == :name) && (data.time[i] >= p75),
                              crayon"bold")
    TextHighlighter[hl_p95, hl_p75, hl_bold]
end

const trace_column_names = Dict(:id => "ID", :start => "Start", :time => "Time", :name => "Name")
const summary_column_names = Dict(:time_ratio => "Time (%)", :time => "Total time",
                                  :calls => "Calls", :time_dist => "Time distribution",
                                  :name => "Name")

function _summary_formatter(df)
    return function(v, i, j)
        col = keys(df)[j]
        if col == :time_ratio
            format_percentage(v)
        elseif col == :time
            format_time(v)
        elseif col == :time_dist
            v === missing && return ""
            m, s, lo, hi = format_time(v.mean, v.std, v.min, v.max)
            @sprintf("%9s ± %-6s (%6s ‥ %s)", m, s, lo, hi)
        else
            v
        end
    end
end

function _print_summary(io, df, crop)
    header = [summary_column_names[k] for k in keys(df)]
    alignment = [k in (:name, :time_dist) ? :l : :r for k in keys(df)]
    pretty_table(io, df; column_labels=header, alignment, formatters=[_summary_formatter(df)],
                 highlighters=time_highlighters(df),
                 fit_table_in_display_horizontally=(crop == :horizontal),
                 fit_table_in_display_vertically=false)
end

function _crop(io)
    if get(io, :is_pluto, false) || get(io, :jupyter, false)
        :none
    elseif io isa Base.TTY || get(io, :limit, false)::Bool
        :horizontal
    else
        :none
    end
end

function Base.show(io::IO, r::ProfileResults)
    ndev, nhost = length(r.name), length(r.host_name)
    if ndev == 0 && nhost == 0
        print(io, "No GPU operations or Objective-C calls were profiled.")
        return
    end

    den = r.wall == 0 ? 1.0 : r.wall   # avoid a zero denominator
    crop = _crop(io)
    println(io, "Profiled over $(format_time(r.wall)).")

    # host-side activity: the Objective-C API trace, grouped by call
    if nhost > 0
        ncalls, htotal = sum(r.host_calls), sum(r.host_time)
        println(io, "\nHost-side activity: $ncalls Objective-C calls taking $(format_time(htotal)) ",
                    "($(format_percentage(htotal / den)) of wall-clock)")
        perm = sortperm(r.host_time; rev=true)
        df = (time_ratio = r.host_time[perm] ./ den,
              time       = r.host_time[perm],
              calls      = r.host_calls[perm],
              name       = r.host_name[perm])
        _print_summary(io, df, crop)
    end

    # device-side activity: the GPU operations, as a summary or a chronological trace
    if ndev > 0
        busy = busy_time(r.start, r.stop)
        println(io, "\nDevice-side activity: GPU was busy $(format_time(busy)) ",
                    "($(format_percentage(busy / den)) of wall-clock)")
        if r.trace
            trace_begin = minimum(r.start)
            perm = sortperm(r.start)
            df = (id    = collect(1:ndev),
                  start = r.start[perm] .- trace_begin,
                  time  = r.stop[perm] .- r.start[perm],
                  name  = r.name[perm])
            header = [trace_column_names[k] for k in keys(df)]
            alignment = [k == :name ? :l : :r for k in keys(df)]
            formatter = (v, i, j) -> keys(df)[j] in (:start, :time) ? format_time(v) : v
            pretty_table(io, df; column_labels=header, alignment, formatters=[formatter],
                         highlighters=time_highlighters(df),
                         fit_table_in_display_horizontally=(crop == :horizontal),
                         fit_table_in_display_vertically=false)
        else
            s = summarize_trace(r.name, r.stop .- r.start, den)
            columns = [:time_ratio, :time, :calls]
            any(!ismissing, s.time_dist) && push!(columns, :time_dist)
            push!(columns, :name)
            df = NamedTuple{Tuple(columns)}(Tuple(s[c] for c in columns))
            _print_summary(io, df, crop)
        end
    end
end


#
# benchmarking
#

function benchmark_and_profile(@nospecialize(f); time::Real=1.0, kwargs...)
    f()            # warm-up (compilation etc.), outside the profiled region
    synchronize()

    function harness()
        t0 = Base.time_ns()
        while (Base.time_ns() - t0) / 1e9 < time
            f()
            synchronize()
        end
    end

    profile_internally(harness; kwargs...)
end

end # module Profiling


"""
    Metal.@profile [trace=false] code...
    Metal.@profile external=true code...

Profile the GPU execution of `code`.

There are two modes of operation, selected by the `external` keyword argument.

## Integrated profiler (`external=false`, the default)

Metal.jl profiles `code` in-process, without requiring Xcode, and displays two tables:

  - **Host-side activity**: the Objective-C API calls made while running `code`, grouped by
    method and sorted by time. Useful to spot host inefficiencies, such as APIs being called
    too often.
  - **Device-side activity**: the GPU operations (kernels, blits), grouped by name. To display
    a chronological trace of the individual operations instead, set `trace=true`.

Slow entries are highlighted: yellow is among the slowest 25%, red among the slowest 5%.

Note that, because Metal runs independent command buffers in parallel, operations may overlap
in time; the reported percentages are relative to the wall-clock GPU span, not the sum of the
individual durations.

!!! note
    The integrated profiler captures GPU operations that go through Metal.jl's command-buffer
    submission path: compute kernels (`@metal`, broadcast, mapreduce, the `:simd`/`:tensor`
    matmul kernels, ...) and blit operations (copies, fills). Operations performed through
    Metal Performance Shaders or MPSGraph — most notably the default matrix-multiplication
    backend — submit their own command buffers and do **not** appear in the trace yet. Use
    `Metal.@profile external=true` (or [`Metal.@capture`](@ref)) to inspect those.

## External profiler (`external=true`)

Drives Xcode's `xctrace` to record a system trace of `code`, which can then be opened in the
Instruments app. This requires Xcode to be installed. See also [`Metal.@capture`](@ref) for
Metal's GPU frame capture.
"""
macro profile(ex...)
    code = ex[end]
    kwargs = ex[1:end-1]

    external = false
    remaining = Expr[]
    for kwarg in kwargs
        Meta.isexpr(kwarg, :(=)) ||
            throw(ArgumentError("Invalid keyword argument to Metal.@profile: $kwarg"))
        key, value = kwarg.args
        if key === :external
            isa(value, Bool) ||
                throw(ArgumentError("Invalid value for keyword argument `external`: got `$value`, expected literal boolean value"))
            external = value
        else
            push!(remaining, Expr(:kw, key, esc(value)))
        end
    end

    if external
        isempty(remaining) ||
            throw(ArgumentError("Metal.@profile external=true does not accept other keyword arguments"))
        quote
            $profiled() do
                $(esc(code))
            end
        end
    else
        quote
            $(Profiling.profile_internally)(; $(remaining...)) do
                $(esc(code))
            end
        end
    end
end

"""
    Metal.@bprofile [time=1.0] [trace=false] code...

Benchmark the GPU execution of `code` by running it repeatedly for `time` seconds, and report
the aggregated results using the integrated profiler ([`Metal.@profile`](@ref)).

The `time` keyword argument is optional and defaults to `1.0` seconds; the remaining keyword
arguments are forwarded to `Metal.@profile`.
"""
macro bprofile(ex...)
    code = ex[end]
    kwargs = ex[1:end-1]

    remaining = Expr[]
    for kwarg in kwargs
        Meta.isexpr(kwarg, :(=)) ||
            throw(ArgumentError("Invalid keyword argument to Metal.@bprofile: $kwarg"))
        key, value = kwarg.args
        key === :external &&
            throw(ArgumentError("The `external` keyword argument is not supported by Metal.@bprofile"))
        push!(remaining, Expr(:kw, key, esc(value)))
    end

    quote
        $(Profiling.benchmark_and_profile)(; $(remaining...)) do
            $(esc(code))
        end
    end
end
