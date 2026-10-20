# Configuration

Use preferences for project settings and environment variables for individual runs.
The defaults suit normal use.

## Preferences

Preferences are stored in a `LocalPreferences.toml` file next to your project's
`Project.toml`, under a `[Metal]` section. Set them with
[Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl):

```julia
using Preferences, Metal
set_preferences!(Metal, "default_storage" => "private")
```

or by editing the file:

```toml
[Metal]
default_storage = "private"
```

Restart Julia after changing preferences; Metal.jl recompiles with the new settings. [`Metal.versioninfo()`](@ref) lists the preferences that are
set (except `command_api`).

| Preference | Default | Effect |
|---|---|---|
| `default_storage` | `"shared"` | Storage mode of arrays created without one: `"shared"` or `"private"`. See [Storage modes](@ref storage-modes). |
| `nonblocking_synchronization` | `true` | Let other tasks run while a task waits for the GPU. With `false`, waiting blocks the thread. See [Waiting for the GPU](@ref). |
| `command_batching` | `true` | Collect consecutive operations into one command buffer. See [Ordering and command batching](@ref). |
| `command_batching_ops` | `32` | Number of operations after which a batch is submitted. Lower values return the first results sooner; higher values reduce overhead. |
| `command_batching_bytes` | `67108864` (64 MiB) | Amount of copied data after which a batch is submitted, which bounds the memory held by queued work. A single copy can be larger. |
| `command_batching_inflight` | `3` | Maximum number of submitted command buffers the GPU hasn't finished; submitting more waits. |
| `command_api` | `"auto"` | Metal API to submit work with: `"metal3"`, `"metal4"` (macOS 26 or later, not on virtualized GPUs), or `"auto"`, which selects `"metal3"`. |
| `label_resources` | see below | Name buffers and command buffers, and mark each kernel launch, for Xcode's frame capture. Defaults to `true` when Julia runs with `-g2` or with `METAL_CAPTURE_ENABLED=1`. See [Xcode and Instruments](xcode.md). |
| `embed_sources` | see below | Embed kernel sources in the compiled libraries, so that Xcode's frame capture can show them with per-line costs. Defaults to `true` with `METAL_CAPTURE_ENABLED=1`. |
| `precompile` | `true` | Compile common operations when Metal.jl is precompiled. Disabling it shortens precompilation, e.g. when developing Metal.jl, at the cost of a slower first use. |

The `command_api` preference is mainly for testing the Metal 4 implementation.

## Environment variables

Set environment variables before starting Julia; most are only read once:

```
$ METAL_CAPTURE_ENABLED=1 julia --project
```

| Variable | Effect |
|---|---|
| `JULIA_METAL_COMMAND_BATCHING_OPS`, `JULIA_METAL_COMMAND_BATCHING_BYTES`, `JULIA_METAL_COMMAND_BATCHING_INFLIGHT` | Override the corresponding preferences for one run, e.g. for benchmarking. |
| `METAL_CAPTURE_ENABLED=1` | Apple's switch that allows GPU frame capture, required by `Metal.@capture` and Xcode. Also enables `label_resources` and `embed_sources` by default. See [Xcode and Instruments](xcode.md). |
| `JULIA_METAL_DUMP_DIR` | Write the LLVM IR, AIR and Metal library of every compiled kernel to this directory. Without it, artifacts are only written when compilation fails, to a temporary directory. Debugging only. |
| `MTL_DEBUG_LAYER=1` | Apple's API validation layer: checks Metal API usage, at a cost in performance. Debugging only. |
| `MTL_SHADER_VALIDATION=1` | Apple's shader validation: checks memory accesses of kernels on the GPU, at a large cost in performance. Debugging only. |
| `METAL_TOOLCHAIN` | Directory with Apple's Metal tools, for `metallib validate --apple` (see [Hacking](../developers/hacking.md)). Debugging only. |

`Metal.versioninfo()` lists the environment variables that start with `JULIA_METAL`, `METAL`
or `MTL`. See Apple's documentation on [validating Metal API
usage](https://developer.apple.com/documentation/xcode/validating-your-apps-metal-api-usage)
and [shader usage](https://developer.apple.com/documentation/xcode/validating-your-apps-metal-shader-usage)
for the validation layers.

## Julia options

Starting Julia with `-g2` makes kernels record where an exception was thrown, at a cost in
performance (see [Errors and debug levels](@ref)), and enables `label_resources` by default.
