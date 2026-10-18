# Debugging and profiling with Xcode and Instruments

Xcode can open the GPU traces that `Metal.@capture` records (see [Frame capture](@ref)),
replay them, and profile the captured work. Instruments records a timeline of a whole
session instead: command buffers, kernels and their GPU time, next to what the CPU does.
This page describes how to record both, and what they show of Julia code.

## Capturing a trace

Frame capture has to be enabled when Julia starts, by setting the `METAL_CAPTURE_ENABLED`
environment variable to 1. Metal reads the variable when the process starts, so setting it
from within Julia (`ENV["METAL_CAPTURE_ENABLED"] = "1"`) has no effect; without it,
`Metal.@capture` fails with an error saying so.

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
[ Info: GPU frame capture saved to /Users/tim/saxpy_1.gputrace; open the resulting trace in Xcode
"/Users/tim/saxpy_1.gputrace"
```

The trace is named after the kernel that `@metal` launches, or the function that the
captured expression calls, and numbered so that it does not overwrite earlier traces. Pass
`name="..."` to choose another name, and `open=true` to open the trace in Xcode when the
capture finishes. Otherwise, open it with `open saxpy_1.gputrace` (or *File > Open* in
Xcode), then click *Replay* to replay it on the GPU. Replaying and profiling need the same
kind of GPU that recorded the trace.

A trace contains every Metal library and pipeline the process has created so far, not only
those of the captured kernels: Metal records all live objects of the device, and offers no
way to leave some out. Xcode lists the ones the capture does not use as unused resources,
but they still make the trace larger. To keep traces small and easy to navigate, capture in
a fresh session.

## Kernels, arrays and dispatches

In the trace, the compute pipeline, function and library of every kernel are labelled with
its Julia signature, e.g., `saxpy(::MtlDeviceVector{Float32, 1}, ::MtlDeviceVector{Float32,
1}, ::Float32)`. The generated function itself is named after the Julia function (`saxpy`),
the same for every specialization of the kernel, unless `@metal name=...` names it.

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

The *Call Stack* view (in the menu above the list of source files) breaks the kernel's time
down by call stack, but names every frame after the kernel, including those of functions
inlined into it: Xcode only knows the names of inlined functions in MSL sources.

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

## Profiling with Instruments

Instruments' *Metal System Trace* template records when command buffers and kernels run on
the GPU, how busy the GPU is, and what each CPU thread does in the meantime. It needs no
environment variable. To record a piece of code from within Julia, use
`Metal.@profile external=true`, which starts `xctrace`, Instruments' command-line tool, on
the running process:

```julia
julia> Metal.@profile external=true begin
           for i in 1:100
               @metal threads=1024 saxpy(y, x, 2f0)
           end
       end
[ Info: System trace saved to /Users/tim/julia_1.trace; open the resulting trace in Instruments
"/Users/tim/julia_1.trace"
```

It names the trace like `Metal.@capture` does, and takes the `name` and `open` keyword
arguments, as well as `template` to record with another Instruments template.

To record a whole script instead, including the compilation of its kernels, run Julia under
`xctrace`:

```
$ xcrun xctrace record --template 'Metal System Trace' --output saxpy.trace \
      --launch -- $(which julia) --project script.jl
```

`xctrace` needs the path of the executable, hence `$(which julia)` (the juliaup launcher
works too). To
record a session that is already running, attach to it by process ID (`getpid()` in Julia)
with `--attach PID` instead of `--launch`, and stop the recording with Ctrl-C. Open the
result with `open saxpy.trace`. To include Metal.jl's signposts (see below), build the
instrument that records them, and add it to the recording:

```
$ julia --project -e 'using Metal; Metal.OS.instruments_package(["org.juliagpu.metal"]; dir=".")'
$ xcrun xctrace record --template 'Metal System Trace' \
      --package Julia.instrdst --instrument 'Julia Signposts' --output saxpy.trace \
      --launch -- $(which julia) --project script.jl
```

The list of subsystems can include those of your own signposts too.

In the trace, the GPU's list of shaders names kernels after their function (e.g. `saxpy`),
while the Metal driver's signposts,
which mark when pipelines are compiled, show the Julia signatures that Metal.jl uses as
pipeline labels. Metal.jl
batches many kernels into one command buffer, so the GPU track shows a command buffer per
batch rather than per kernel. With resource labels enabled (when frame capture is enabled,
when running with `-g2`, or with the `label_resources` preference), command buffers are
labelled, e.g. `MTLCommandBuffer(batched queue)`; otherwise they show as `Command Buffer 0`.

A trace recorded with `--launch` stores the environment variables of the process, so
check them before sharing a trace.

The integrated profiler (`Metal.@profile` without `external=true`, see
[Profiling](@ref)) reports the GPU time of each operation in the REPL, and is the quicker
tool to find which kernel to look at.

### Signposts

Metal.jl marks what it does on the CPU with signposts (subsystem `org.juliagpu.metal`),
which `Metal.@profile external=true` records with the *Julia Signposts* instrument:

- **Compile** intervals, with the kernel's Julia signature as message, containing *Generate
  LLVM IR*, *Downgrade to AIR* and *Create Metal library* intervals.
- **Instantiate compute pipeline** intervals when a kernel is loaded onto the GPU, which
  also happens for kernels that were compiled before (e.g., during precompilation).
- A **Launch** interval for every kernel launch, with the kernel's signature and its
  `groups` and `threads` as message.
- **Wait for GPU** intervals when a task waits for GPU work to finish (`synchronize`,
  copying an array to the CPU), but only when the GPU was not done yet.

An interval that ends with the message `error` failed.

Launch and wait signposts are only emitted while an instrument asks for them, and cost a
few nanoseconds otherwise. The *Julia Signposts* instrument does so; `Metal.@profile
external=true` builds it with Xcode's `instrumentbuilder` the first time it is needed.
Signposts of your own code can be added with ObjectiveC.jl, as described in
[Application tracing](@ref).
