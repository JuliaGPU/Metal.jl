# Debugging and profiling with Xcode

Xcode can open the GPU traces that `Metal.@capture` records (see [Frame capture](@ref)),
replay them, and profile the captured work. This page describes what such a trace shows of
Julia code, and how to find it.

## Capturing a trace

Frame capture has to be enabled when Julia starts, by setting the `METAL_CAPTURE_ENABLED`
environment variable to 1:

```
$ METAL_CAPTURE_ENABLED=1 julia --project
```

```julia
julia> using Metal

julia> function saxpy(y, x, a)
           i = thread_position_in_grid().x
           y[i] = a * x[i] + y[i]
           return
       end

julia> x = MtlArray(rand(Float32, 1024)); y = MtlArray(rand(Float32, 1024));

julia> Metal.@capture @metal threads=1024 saxpy(y, x, 2f0)
[ Info: GPU frame capture saved to julia_1.gputrace; open the resulting trace in Xcode
```

Open the trace with `open julia_1.gputrace` (or *File > Open* in Xcode), then click *Replay*
to replay it on the GPU. Replaying and profiling need the same kind of GPU that recorded the
trace.

A trace contains every Metal library the process has loaded so far, not only those of the
captured kernels. To keep traces small and easy to navigate, capture in a fresh session.

## Kernels, arrays and dispatches

In the trace, the compute pipeline, function and library of every kernel are labelled with
its Julia signature, e.g., `saxpy(::MtlDeviceVector{Float32, 1}, ::MtlDeviceVector{Float32,
1}, ::Float32)`, in addition to the mangled name of the generated function.

When frame capture is enabled, or Julia runs with `-g2`, Metal.jl also:

- labels the buffers backing `MtlArray`s with their type and dimensions, e.g.,
  `MtlArray{Float32,1,Metal.PrivateStorage}(dims=(1024,))`;
- wraps every kernel dispatch in a debug group named after the kernel, which tells apart
  the many kernels Metal.jl batches into a single command buffer.

The `label_resources` preference forces these array labels and debug groups on or off. The
kernel labels, and the labels of Metal.jl's internal buffers (e.g. `Metal.jl exception info`),
are always set.

## Source code and per-line costs

When frame capture is enabled, Metal.jl embeds the sources of every kernel in the library it
loads, the way Apple's compiler does with `-frecord-sources`. Xcode then shows the Julia code
of a kernel, and after profiling, how much of the kernel's time each line accounts for:

1. In the trace's navigator, select a dispatch of the kernel (they are grouped under the
   kernel's debug group).
2. In the dispatch's *Bound Resources*, double-click the kernel's function to open its
   source.
3. To see per-line costs, click the *Profile GPU trace* button, and then *Profile*. Profiling takes a while; afterwards the source view shows the share of the
   kernel's time spent on each line, and the kernel's statistics.

The embedded sources are the Julia files that a kernel's debug info refers to, read when
the kernel is first loaded: the file that defines the kernel, and the files of the functions
it calls that are defined in packages (e.g. Metal.jl's own device code). Files larger than
1 MiB, or whose path is longer than the archive format allows (about 255 bytes), are left
out. Code inlined into
the kernel is attributed to the line of the kernel that called it.

To embed sources without enabling frame capture, or to stop embedding them, set the
`embed_sources` preference (with Preferences.jl's `set_preferences!`, or in
`LocalPreferences.toml`). Embedding the sources takes a few milliseconds per kernel when it
is loaded, and makes its library a few times larger (tens of kilobytes); kernels are not
recompiled for it.

### Limitations

- Debugging a kernel in Xcode's shader debugger (stepping through lines, inspecting
  variables) is not supported: the debugger needs to recompile the kernel from MSL source,
  and does not support AIR. Editing and reloading shaders in Xcode is not supported either.
- Xcode highlights the Julia source as if it were MSL.
- Sources are only available for kernels with debug info: running Julia with `-g0` disables
  them. Only files that exist on disk are embedded, so kernels defined at the REPL show no
  source, and neither do functions from Julia's `Base` (whose files Julia records by name
  only).
- The sources are read when a kernel is first loaded. If a file changed after the kernel was
  compiled (e.g., when using Revise), the lines Xcode shows may not match the code.
