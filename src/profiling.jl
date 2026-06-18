# Integrated, lightweight GPU profiler.
#
# Unlike `Metal.@profile external=true` (which drives Xcode's `xctrace`), this profiler runs
# entirely in-process and needs no developer tools. It works by hooking the single `commit!`
# chokepoint that all GPU work passes through (`MTL.profile_hook`), retaining every committed
# command buffer, and — after synchronizing — reading each buffer's `GPUStartTime`/`GPUEndTime`.
# Metal.jl issues roughly one command buffer per GPU operation, so per-buffer timing maps
# cleanly onto per-operation timing without any per-callsite instrumentation.

module Profiling

import ..Metal: MTL, synchronize, device_synchronize

using ObjectiveC.Foundation: retain, release
using ObjectiveC: @autoreleasepool

using Printf: @sprintf
using Statistics: mean, std, quantile

using PrettyTables: pretty_table, TextHighlighter
using Crayons: @crayon_str


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
# results
#

struct ProfileResults
    # one entry per captured GPU operation, in commit order
    name::Vector{String}
    start::Vector{Float64}  # GPU start time, in seconds (host clock)
    stop::Vector{Float64}   # GPU end time, in seconds (host clock)

    # display options
    trace::Bool
end

function profile_internally(@nospecialize(f); trace::Bool=false)
    records = Tuple{String,Any}[]

    # drain any work that was already in flight, so we only capture `f`'s operations
    device_synchronize()

    prev = MTL.profile_hook[]
    MTL.profile_hook[] = cmdbuf -> record_commit!(records, cmdbuf)
    try
        f()
    finally
        MTL.profile_hook[] = prev
    end

    # wait for all captured work to finish before reading its timestamps
    device_synchronize()

    name = String[]
    start = Float64[]
    stop = Float64[]
    @autoreleasepool begin
        for (opname, cmdbuf) in records
            # `GPUStartTime`/`GPUEndTime` are only valid once the buffer has completed; skip
            # anything that errored or never ran. (We do NOT fall back to
            # `kernelStartTime`/`kernelEndTime` — those measure CPU-side scheduling latency,
            # not GPU execution.)
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

    return ProfileResults(name, start, stop, trace)
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

function Base.show(io::IO, results::ProfileResults)
    n = length(results.name)
    if n == 0
        print(io, "No GPU operations were profiled.")
        return
    end

    trace_begin = minimum(results.start)
    span = maximum(results.stop) - trace_begin
    busy = busy_time(results.start, results.stop)

    print(io, "Profiled $n GPU operation$(n == 1 ? "" : "s") over $(format_time(span)); ",
          "GPU was busy $(format_time(busy)) ($(format_percentage(span == 0 ? 0.0 : busy/span))).")

    # avoid a zero denominator for instantaneous traces
    den = span == 0 ? 1.0 : span

    crop = if get(io, :is_pluto, false) || get(io, :jupyter, false)
        :none
    elseif io isa Base.TTY || get(io, :limit, false)::Bool
        :horizontal
    else
        :none
    end

    println(io)
    if results.trace
        # chronological trace
        perm = sortperm(results.start)
        df = (id    = collect(1:n),
              start = results.start[perm] .- trace_begin,
              time  = results.stop[perm] .- results.start[perm],
              name  = results.name[perm])

        header = [trace_column_names[k] for k in keys(df)]
        alignment = [k == :name ? :l : :r for k in keys(df)]
        formatter = function(v, i, j)
            if keys(df)[j] in (:start, :time)
                format_time(v)
            else
                v
            end
        end
        pretty_table(io, df; column_labels=header, alignment, formatters=[formatter],
                     highlighters=time_highlighters(df),
                     fit_table_in_display_horizontally=(crop == :horizontal),
                     fit_table_in_display_vertically=false)
    else
        # summary grouped by operation name
        df = summarize_trace(results.name, results.stop .- results.start, den)

        columns = [:time_ratio, :time, :calls]
        any(!ismissing, df.time_dist) && push!(columns, :time_dist)
        push!(columns, :name)
        df = NamedTuple{Tuple(columns)}(Tuple(df[c] for c in columns))

        header = [summary_column_names[k] for k in keys(df)]
        alignment = [k in (:name, :time_dist) ? :l : :r for k in keys(df)]
        formatter = function(v, i, j)
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
        pretty_table(io, df; column_labels=header, alignment, formatters=[formatter],
                     highlighters=time_highlighters(df),
                     fit_table_in_display_horizontally=(crop == :horizontal),
                     fit_table_in_display_vertically=false)
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

Metal.jl profiles the GPU operations performed by `code` in-process, without requiring Xcode,
and displays the result. By default a summary of the captured GPU operations is shown, grouped
by name. To display a chronological trace of the individual operations instead, set `trace=true`.

Slow operations are highlighted: entries in yellow are among the slowest 25%, those in red
among the slowest 5%.

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
