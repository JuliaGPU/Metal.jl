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
`synchronize()` or, even better, wrapping your code in [`Metal.@sync`](@ref):

```julia
julia> using Metal, BenchmarkTools

julia> a = Metal.rand(Float32, 1024, 1024);

julia> @btime Metal.@sync sin.($a);
```

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

julia> b .= a .+ 1f0; c .= sqrt.(b); Metal.synchronize();   # warm up kernel compilation

julia> Metal.@profile begin
           b .= a .+ 1f0
           c .= sqrt.(b)
       end
```

The output contains separate host-side and device-side tables. The host table groups
Objective-C API calls, while the device table groups kernels and blit operations by name.

To display a chronological trace of the individual Objective-C calls and GPU operations
instead of summaries, set `trace=true`:

```julia
julia> Metal.@profile trace=true begin
           b .= a .+ 1f0
           c .= sqrt.(b)
       end
```

Runtime calls used by Metal.jl itself, such as synchronization polling, are hidden by default.
Set `raw=true` to include them.

To benchmark a piece of code by running it repeatedly, use `Metal.@bprofile` (which accepts an
optional `time` keyword argument, defaulting to one second):

```julia
julia> Metal.@bprofile time=2.0 b .= a .+ 1f0
```

Because Metal runs independent command buffers in parallel, operations may overlap in time;
the reported percentages are relative to the wall-clock time of the profiled code
(including waiting for the GPU to finish), not to the sum of the individual durations.

!!! note
    The integrated profiler captures the GPU operations that go through Metal.jl's
    command-buffer submission path: compute kernels (`@metal`, broadcast, mapreduce, ...) and
    blit operations (copies, fills). Operations performed through Metal Performance Shaders or
    MPSGraph — most notably the default matrix-multiplication backend — submit their own command
    buffers and do not appear in the trace yet. Use Instruments or frame capture (see
    [Xcode and Instruments](@ref)) to inspect those.

## Xcode and Instruments

The integrated profiler tells which operations take the time. To look deeper, Metal.jl works
with Apple's tools, described in
[Debugging and profiling with Xcode and Instruments](@ref):

- `Metal.@profile external=true` records the code with Instruments, for a timeline of GPU
  work, CPU activity, and Metal.jl's compilations, kernel launches and waits;
- `Metal.@capture` records a GPU frame capture that Xcode can replay, to inspect a kernel's
  arguments and buffers, and profile it line by line.

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


## API

```@docs
Metal.@profile
Metal.@bprofile
```
