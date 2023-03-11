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

## Application profiling

For profiling large applications, simple timings are insufficient. Instead, we want a
overview of how and when the GPU was active, to avoid times where the device was idle and/or
find which kernels needs optimization.

As we cannot use the Julia profiler for this task, we will use Metal's GPU profiler directly.
Use the `Metal.@profile` macro to surround the code code of interest. This macro tells your system
to track GPU calls and usage statistics and will save this information in a temporary folder
ending in '.gputrace'. For later viewing, copy this folder to a stable location or use
the 'dir' argument of the profile macro to store the gputrace to a different location directly.

To profile GPU code from a Julia process, you must set the `METAL_CAPTURE_ENABLED` environment
variable. On the first Metal command detected, you should get a message stating "Metal GPU
Frame Capture Enabled" if the variable was set correctly.

```julia
$ METAL_CAPTURE_ENABLED=1 julia
...

julia> using Metal

julia> function vadd(a, b, c)
           i = thread_position_in_grid_1d()
           c[i] = a[i] + b[i]
           return
       end
vadd (generic function with 1 method)

julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);
... Metal GPU Frame Capture Enabled

julia> Metal.@profile @metal threads=length(c) vadd(a, b, c);
[ Info: GPU frame capture saved to /var/folders/x3/75r5z4sd2_bdwqs68_nfnxw40000gn/T/jl_WzKxYVMlon/jl_metal.gputrace/
```

To view these GPU traces though, Xcode, with its quite significant install size, needs to be
 installed.
