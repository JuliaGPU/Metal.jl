# [Troubleshooting](@id troubleshooting)



## Installation and loading

**`Metal.functional()` returns `false`, or [`Metal.versioninfo()`](@ref) lists no devices.**
Metal.jl logs the reason when it loads:

- *"Metal.jl is only supported on Apple Silicon"*: Metal.jl needs an Apple silicon Mac and
  the native `aarch64` build of Julia. An Intel build of Julia running under Rosetta reports
  `Sys.ARCH == :x86_64`; install the Apple silicon build, e.g. with
  [juliaup](https://github.com/JuliaLang/juliaup).
- *"Metal.jl requires macOS 15 or later"*: update macOS.
- *"Failed to load Metal"*: loading Apple's frameworks failed; the logged exception has the
  details.
- *"The \`command_api\` preference selects the Metal 4 command API, but …"*: remove the
  `command_api` preference, or see [Configuration](@ref).

**"Metal.jl is running on a virtualized Apple GPU; this is supported on a best-effort
basis"**: virtual machines, such as macOS CI runners, provide a paravirtualized GPU. Most
functionality works, but some features (e.g. capturing kernel log output and the Metal 4
command API) are unavailable.

## Element types

**"Metal does not support Float64 values, try using Float32 instead"**: Apple GPUs have no
double-precision arithmetic, so `MtlArray` rejects `Float64` elements, also inside structs
and complex numbers (and likewise `Int128` and `UInt128`). Convert data with [`mtl`](@ref),
which turns `Float64` into `Float32`, or with `MtlArray{Float32}(x)`. If the error comes from
an operation on `Float32` arrays, a `Float64` value promoted the result: `a .* 2.0` creates a
`Float64` array. Write `2f0` or `Float32(x)` instead.

**"InvalidIRError: … Reason: unsupported use of double value"**: a kernel computes with
`Float64`, e.g. because of a `Float64` argument or literal, or a function that converts to
`Float64` internally. The stack trace under each reason points to where the value comes from.
Pass `Float32` arguments and use `Float32` literals, even when compiler optimizations
happen to eliminate a `Float64` intermediate.

## Kernel compilation

**"InvalidIRError: … Reason: unsupported dynamic function invocation"** or **"unsupported
use of a non-constant global"**: the compiler cannot resolve a call or global value
statically. Resolving it at runtime would require unsupported Julia runtime functionality. Common causes are
non-`const` globals (pass the value as an argument or declare it `const`), and functions
whose return type depends on runtime values. Inspect the kernel with
[`@device_code_warntype`](@ref) to find the unstable variable:

```julia
@device_code_warntype @metal threads=4 kernel(a)
```

**"KernelError: kernel returns a value of type \`Float32\`"**: kernels must return
`nothing`. Julia functions return the value of their last expression, often an assignment,
so end the kernel with `return`.

**"Compilation to native code failed; see below for details."** with an `NSError` such as
*"Compilation failed due to an interrupted connection: XPC_ERROR_CONNECTION_INTERRUPTED"* or
*"Compiler encountered an internal error"*: Apple's GPU compiler, which runs in a separate
process, crashed on the generated code. This is a bug in Apple's compiler or in Metal.jl, not
in your code. Please [file an issue](https://github.com/JuliaGPU/Metal.jl/issues) with the
files listed in the error message, the kernel, and `Metal.versioninfo()`. To narrow the
crash down yourself, see [Reproducing and reducing backend compiler crashes](@ref). If the
message adds that Metal "returned a null GPU address for a new buffer", the GPU driver has
stopped servicing the process: restart Julia.

## Kernel launches

**"ArgumentError: Number of threads in group (2048) should not exceed 1024"**: a threadgroup
has at most 1024 threads, and a kernel may support fewer, depending on its resource usage.
Launch more threadgroups instead (see [Kernel programming](../usage/kernel.md)), and query the
kernel's limit to choose the size:

```julia
kernel = @metal launch=false my_kernel(a)
threads = min(length(a), kernel.maxthreads)
groups = cld(length(a), threads)
kernel(a; threads, groups)
```

**"KernelException: A BoundsError was thrown on device …"** (or another exception
name): the kernel threw an exception. It is reported when you next synchronize, not where you
launched the kernel (see [Errors](@ref gpu-errors)). Launch with `@metal debug_level=2` or start Julia
with `-g2` to see which thread threw it and where; see [Errors and debug levels](@ref).

**"CommandBufferError: Metal command buffer failed"**: Metal reports that executing a
command buffer failed. The `NSError` line that follows gives Metal's reason, such as a kernel
that ran too long or accessed invalid memory.

## Arrays and memory

**"Scalar indexing is disallowed."**: code accessed a private array element from the CPU,
either directly or through a fallback implementation. Use an array operation that runs
on the GPU, wrap code that should index the array in `Metal.@allowscalar`, or use shared
storage. See [Scalar indexing](@ref).

**"Cannot access the contents of a private buffer"**: you tried to access a private array's
memory from the CPU, e.g. with `unsafe_wrap(Array, a)`. Only shared arrays can be accessed
directly.

**Values read on the CPU are stale or zero**: an `Array` that shares memory with an
`MtlArray` (created with `unsafe_wrap`) doesn't wait for the GPU. Call [`synchronize`](@ref)
before accessing it. See [Sharing memory with CPU arrays](@ref).

## Numerical results

**`Float32` subnormals become zero on the GPU.** Apple GPUs flush subnormal `Float32`
operands and results to zero. Comparisons also treat subnormal operands as zero, so
`iszero(x)` and `x == 0` can be true for a nonzero value stored in memory, and multiplying a
subnormal input by a power of two does not recover its value:

```julia
julia> x = MtlArray([1f-40]);

julia> Array(x .* 2f0), Array(x .== 0f0)
(Float32[0.0], Bool[1])
```

The [Metal Shading Language specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
(section 8.1) permits flushing subnormals to zero, also for `Float16`, so don't assume that
disabling fast math preserves them. 
