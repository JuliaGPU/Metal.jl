# Profiling

Profiling GPU code is harder than profiling Julia code executing on the CPU. For one,
kernels typically execute asynchronously, and thus require appropriate synchronization when
measuring their execution time. Furthermore, because the code executes on a different
processor, it is much harder to know what is currently executing.


## Time measurements

For robust measurements, it is advised to use the
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package which goes to
great lengths to perform accurate measurements. Due to the asynchronous nature of GPUs, you
need to ensure the GPU is synchronized at the end of every sample, e.g. by calling
`synchronize()` or, even better, wrapping your code in `Metal.@sync`:

Note that the allocations as reported by BenchmarkTools are CPU allocations.

## Integrated profiler

For profiling large applications, simple timings are insufficient. Instead, we want an
overview of how and when the GPU was active to avoid times where the device was idle and/or
find which kernels needs optimization.

The `Metal.@profile` macro profiles the GPU operations performed by the given code in-process,
without requiring Xcode, and prints a summary. By default the captured operations are grouped
by name; slow operations are highlighted (yellow for the slowest 25%, red for the slowest 5%).

```julia
julia> using Metal

julia> a = Metal.rand(Float32, 1024, 1024); b = similar(a); c = similar(a);

julia> b .= a .+ 1f0; Metal.synchronize();   # warm up kernel compilation

julia> Metal.@profile begin
           b .= a .+ 1f0
           c .= sqrt.(b)
       end
Profiled 2 GPU operations over 421.0 µs; GPU was busy 421.0 µs (100.00%).
┌──────────┬────────────┬───────┬───────────────────┬──────────────┐
│ Time (%) │ Total time │ Calls │ Time distribution │ Name         │
├──────────┼────────────┼───────┼───────────────────┼──────────────┤
│   54.21% │  228.3 µs  │     1 │                   │ broadcast_2d │
│   45.79% │  192.7 µs  │     1 │                   │ broadcast_2d │
└──────────┴────────────┴───────┴───────────────────┴──────────────┘
```

To display a chronological trace of the individual operations instead of a summary, set
`trace=true`:

```julia
julia> Metal.@profile trace=true begin
           b .= a .+ 1f0
           c .= sqrt.(b)
       end
```

To benchmark a piece of code by running it repeatedly, use `Metal.@bprofile` (which accepts an
optional `time` keyword argument, defaulting to one second):

```julia
julia> Metal.@bprofile time=2.0 b .= a .+ 1f0
```

Because Metal runs independent command buffers in parallel, operations may overlap in time;
the reported percentages are relative to the wall-clock GPU span, not the sum of the individual
durations.

!!! note
    The integrated profiler captures the GPU operations that go through Metal.jl's
    command-buffer submission path: compute kernels (`@metal`, broadcast, mapreduce, ...) and
    blit operations (copies, fills). Operations performed through Metal Performance Shaders or
    MPSGraph — most notably the default matrix-multiplication backend — submit their own command
    buffers and do not appear in the trace yet. Use the external profiler or frame capture
    (below) to inspect those.

## Application tracing

For a system-level view, or to inspect operations the integrated profiler does not capture,
`Metal.@profile external=true` uses Xcode to record a trace of the GPU work. This macro tells
your system to track GPU calls and usage statistics and will save this information in a
temporary folder ending in '.trace'. For later viewing in Xcode's Instruments app, copy this
folder to a stable location.

The resulting trace can be opened with the Instruments app, part of Xcode.

```julia
julia> using Metal

julia> function vadd(a, b, c)
           i = thread_position_in_grid().x
           c[i] = a[i] + b[i]
           return
       end
julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);

julia> Metal.@profile external=true @metal threads=length(c) vadd(a, b, c);
...
[ Info: System trace saved to julia_3.trace; open the resulting trace in Instruments
```

It is possible to augment the trace with additional information by using signposts: Similar
to NVTX markers and ranges in CUDA.jl, signpost intervals and events can be used to add
respectively time intervals and points of interest to the trace. This can be done by using
the signpost functionality from ObjectiveC.jl:

```julia
using ObjectiveC, .OS

@signpost_interval "My Interval" begin
    # code to profile
    @signpost_event "My Event"
end
```

For more information, e.g. how to pass additional messages to the signposts, or how to
use a custom logger, consult the ObjectiveC.jl documentation, or the docstrings of the
`@signpost_interval` and `@signpost_event` macros.

## Frame capture

For more details on specific operations, you can use Metal's frame capture feature to
generate a more detailed, and replayable trace of the GPU operations. This requires that
Julia is started with the `METAL_CAPTURE_ENABLED` environment variable set to 1. Frames are
captured by wrapping the code of interest in `Metal.@capture`, and the resulting trace can
be opened with Xcode.

```julia
$ METAL_CAPTURE_ENABLED=1 julia
...

julia> using Metal

julia> function vadd(a, b, c)
           i = thread_position_in_grid().x
           c[i] = a[i] + b[i]
           return
       end

julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);
... Metal GPU Frame Capture Enabled

julia> Metal.@capture @metal threads=length(c) vadd(a, b, c);
...
[ Info: GPU frame capture saved to julia_1.gputrace; open the resulting trace in Xcode
```

## Dumping compiled code

When a kernel fails to compile, Metal.jl writes the offending LLVM IR (`.ll`), AIR
(`.air`), and Metal library (`.metallib`) to disk and prints their paths in the error
message, so you can attach them to a bug report. On CI it also keeps them around: Buildkite
uploads them as build artifacts, and on GitHub Actions Metal.jl writes them to
`$RUNNER_TEMP/metal-compilation-dumps` and prints a workflow notice (collect them with an
`actions/upload-artifact` step that runs with `if: always()`).

Sometimes a kernel compiles here but fails the back-end compiler only on another machine.
To capture the IR in that case, set the `JULIA_METAL_DUMP_DIR` environment variable to a
directory. Metal.jl then dumps the `.ll`/`.air`/`.metallib` of every compiled kernel there,
not only the failing ones, and sends the on-failure dumps above to the same directory.

```julia
$ JULIA_METAL_DUMP_DIR=/tmp/metal-dumps julia
...

julia> using Metal

julia> @metal threads=length(c) vadd(a, b, c);

julia> readdir("/tmp/metal-dumps")
3-element Vector{String}:
 "jl_8kQ2Xv.air"
 "jl_8kQ2Xv.ll"
 "jl_8kQ2Xv.metallib"
```
