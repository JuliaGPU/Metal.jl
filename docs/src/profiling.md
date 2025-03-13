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

## Application tracing

For profiling large applications, simple timings are insufficient. Instead, we want an
overview of how and when the GPU was active to avoid times where the device was idle and/or
find which kernels needs optimization.

As we cannot use the Julia profiler for this task, we will use Metal's GPU profiler
directly. Use the `Metal.@profile` macro to surround the code code of interest. This macro
tells your system to track GPU calls and usage statistics and will save this information in
a temporary folder ending in '.trace'. For later viewing in Xcode's Instruments app,
copy this folder to a stable location.

The resulting trace can be opened with the Instruments app, part of Xcode.

```julia
julia> using Metal

julia> function vadd(a, b, c)
           i = thread_position_in_grid_1d()
           c[i] = a[i] + b[i]
           return
       end
julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);

julia> Metal.@profile @metal threads=length(c) vadd(a, b, c);
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
           i = thread_position_in_grid_1d()
           c[i] = a[i] + b[i]
           return
       end

julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);
... Metal GPU Frame Capture Enabled

julia> Metal.@capture @metal threads=length(c) vadd(a, b, c);
...
[ Info: GPU frame capture saved to julia_1.gputrace; open the resulting trace in Xcode
```
