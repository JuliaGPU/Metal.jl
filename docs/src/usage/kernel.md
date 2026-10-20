# Kernel programming

```@meta
DocTestSetup = :(using Metal)
```

When array operations aren't flexible or fast enough, you can write GPU kernels as Julia
functions. This page covers writing, launching and debugging them; [Advanced kernel
programming](@ref) covers how threads cooperate. If you're new to GPU programming, start
with the [Introduction](../tutorials/introduction.md).


## Defining and launching kernels

A kernel returns `nothing` and writes its results to array arguments.
Launch it with [`@metal`](@ref), passing the number of threads per threadgroup (`threads`)
and the number of threadgroups (`groups`):

```jldoctest kernel
julia> function fill_index!(a)
           i = thread_position_in_grid().x
           if i <= length(a)
               a[i] = i
           end
           return
       end;

julia> a = Metal.zeros(Int32, 5);

julia> @metal threads=4 groups=2 fill_index!(a);

julia> Array(a)
5-element Vector{Int32}:
 1
 2
 3
 4
 5
```

The first launch with given argument types compiles the kernel. Launches are
asynchronous: operations that need the result, like `Array(a)`, wait for the kernel (see
[Tasks and synchronization](tasks.md)).


## Threads, threadgroups and the grid

A launch runs the kernel once per thread, in a hierarchy that Apple describes in
[Creating threads and
threadgroups](https://developer.apple.com/documentation/metal/creating-threads-and-threadgroups):

- A **threadgroup** is a set of up to 1024 threads that can share threadgroup memory and
  synchronize with barriers.
- The **grid** consists of all threadgroups of a launch.
- The GPU executes the threads of a threadgroup in **SIMD-groups** of 32 threads (the
  *thread execution width*), which can exchange values directly (see [SIMD-group
  functions](@ref simdgroup-functions)).

`@metal threads=t groups=g` launches `g` threadgroups of `t` threads, so the grid is
`g .* t` threads large. Both default to 1 and accept an integer or a tuple of up to three
dimensions. When rounding up the grid to cover the data, skip extra threads with a bounds
check like the `if` above.

These functions return thread positions and launch dimensions as `UInt32` values.
Positions and indices are 1-based; multidimensional results are named tuples with fields
`x`, `y` and `z`:

| Function | Returns |
|---|---|
| [`thread_position_in_grid`](@ref) | position of the thread in the grid |
| [`thread_position_in_threadgroup`](@ref) | position of the thread in its threadgroup |
| [`threadgroup_position_in_grid`](@ref) | position of the threadgroup in the grid |
| [`threads_per_threadgroup`](@ref) | threadgroup size (`threads`) |
| [`threadgroups_per_grid`](@ref) | number of threadgroups (`groups`) |
| [`threads_per_grid`](@ref) | grid size |
| [`thread_index_in_threadgroup`](@ref) | linear index of the thread in its threadgroup |
| [`thread_index_in_simdgroup`](@ref), [`simdgroup_index_in_threadgroup`](@ref) | position in the SIMD-group, and of the SIMD-group |

The grid position combines the others:
`thread_position_in_grid().x == (threadgroup_position_in_grid().x - 1) * threads_per_threadgroup().x + thread_position_in_threadgroup().x`.


## Choosing the launch configuration

A compiled kernel may support fewer than 1024 threads per threadgroup, depending on its
resource requirements. To find the limit, compile the kernel with
`launch=false`, and call the returned kernel object to launch it:

```julia
kernel = @metal launch=false fill_index!(a)
threads = min(length(a), kernel.maxthreads)
groups = cld(length(a), threads)
kernel(a; threads, groups)
```

`kernel.maxthreads` is the compute pipeline's
[`maxTotalThreadsPerThreadgroup`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/maxtotalthreadsperthreadgroup).
Exceeding it throws an error:

```julia
julia> @metal threads=2048 fill_index!(a)
ERROR: ArgumentError: Number of threads in group (2048) should not exceed 1024
```

For two-dimensional data, make the first dimension of the threadgroup a multiple of the
thread execution width, so that each SIMD-group accesses consecutive elements of a column:

```julia
function scale!(B, A, s)
    i, j = thread_position_in_grid().x, thread_position_in_grid().y
    if i <= size(A, 1) && j <= size(A, 2)
        @inbounds B[i, j] = s * A[i, j]
    end
    return
end

A = Metal.rand(Float32, 100, 300)
B = similar(A)
kernel = @metal launch=false scale!(B, A, 2f0)
width = Int(kernel.pipeline.threadExecutionWidth)    # 32
threads = (width, kernel.maxthreads ÷ width)         # (32, 32)
groups = cld.(size(A), threads)                      # (4, 10)
kernel(B, A, 2f0; threads, groups)
```

See also Apple's [Calculating threadgroup and grid
sizes](https://developer.apple.com/documentation/metal/calculating-threadgroup-and-grid-sizes),
and [Threadgroup size hints](@ref) for constraining the size at compile time.


## Kernel arguments

`@metal` converts every argument with [`Metal.mtlconvert`](@ref): an `MtlArray` becomes an
[`MtlDeviceArray`](@ref), which supports indexing, `size`, `length` and views in the kernel.
Other arguments must be *isbits* values, such as numbers, tuples and immutable structs
of them, which are copied to the GPU:

```julia
struct Affine
    a::Float32
    b::Float32
end

function apply!(y, x, f)
    i = thread_position_in_grid().x
    if i <= length(y)
        @inbounds y[i] = f.a * x[i] + f.b
    end
    return
end

x = MtlArray(Float32[1, 2, 3])
y = similar(x)
@metal threads=3 apply!(y, x, Affine(2, 1))    # y == [3, 5, 7]
```

CPU arrays are rejected with `ArgumentError: cannot use a CPU array (...) in a Metal
kernel`: convert them with `MtlArray`, or share their memory as described in [Sharing
memory with CPU arrays](@ref). To pass
structs containing `MtlArray`s, make them convertible with
[Adapt.jl](https://github.com/JuliaGPU/Adapt.jl)'s `Adapt.@adapt_structure`.


## What kernels can contain

Most Julia code works in kernels, including math functions, structs and tuples, with
these restrictions:

- Kernels must return `nothing` (`KernelError: kernel returns a value of type ...`).
- Every call has to be resolved at compile time. Type-unstable code fails with
  `InvalidIRError: ... unsupported dynamic function invocation`.
- Kernels can't allocate garbage-collected memory, such as `Array`s, or call into the Julia
  runtime or C libraries. Use tuples or [`MtlThreadGroupArray`](@ref) for temporary storage.
- Metal doesn't support `Float64` arithmetic (`InvalidIRError: ... unsupported use of
  double value`). Use `Float32` literals: write `2f0 * x`, not `2.0 * x`.

[Troubleshooting](../development/troubleshooting.md) explains these errors.


## Printing

To print from a kernel while debugging, use [`@mtlprintln`](@ref) or [`@mtlprint`](@ref)
for values and literal strings, [`@mtlshow`](@ref) to print an expression and its value,
and [`@mtlprintf`](@ref) for C-style formatting:

```julia
julia> function print_kernel(a)
           i = thread_position_in_grid().x
           @mtlprintln("Hello from thread ", i)
           @mtlprintf("a[%d] = %f\n", i, a[i])
           return
       end;

julia> @metal threads=2 print_kernel(Metal.ones(Float32, 2)); synchronize()
Hello from thread 1
Hello from thread 2
a[1] = 1.000000
a[2] = 1.000000
```

`@mtlprintf` follows [MSL's `printf`](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf):
the format must be a string literal, without `%n` or `%s`. Output appears when the kernel
completes; messages that overflow Metal's log buffer are dropped. Kernels that print bypass
command batching, which slows them down, and printing doesn't work on virtualized GPUs
such as those of CI virtual machines.


## Errors and debug levels

When a kernel throws, e.g. on an out-of-bounds access, the faulting thread records the
error and stops, while the other threads continue. The next synchronization, explicit or
implicit, throws a `KernelException` on the CPU. Only one error is recorded.

```julia
julia> function kernel(a)
           a[2] = 1f0   # out of bounds: `a` has length 1
           return
       end;

julia> @metal kernel(Metal.zeros(Float32, 1)); synchronize()
ERROR: KernelException: A BoundsError was thrown on device Apple M1: Out-of-bounds array access
For more details, run Julia with `-g2`, or launch the kernel with `@metal debug_level=2`
```

How much is reported depends on the debug level, which defaults to that of the Julia
session (the `-g` flag) and can be set per launch with `@metal debug_level=...`:

| Level | Reported |
|---|---|
| 0 | that an exception was thrown: `KernelException: An exception was thrown on device Apple M1` |
| 1 (default) | also the type and reason, for exceptions that Julia's runtime throws (bounds, domain, overflow and inexact errors, ...) |
| 2 | also the faulting thread and threadgroup, and a stack trace |

At level 2 (paths shortened):

```
ERROR: KernelException: A BoundsError was thrown by thread 1×1×1 in threadgroup 1×1×1 on device Apple M1: Out-of-bounds array access
Stacktrace:
 [1] macro expansion at Metal/src/device/utils.jl:17
 [2] throw_boundserror at Metal/src/device/quirks.jl:52
 [3] checkbounds at ./abstractarray.jl:702
 [4] arrayset at Metal/src/device/array.jl:86
 [5] setindex! at Metal/src/device/array.jl:128
 [6] kernel at ./none:3
```

Recording the position and stack trace adds overhead even when no exception is thrown.


## Compilation and caches

The first launch compiles a kernel in two stages: Metal.jl compiles the Julia code to AIR,
in a Metal library (`metallib`), and the Metal driver compiles that to GPU code. Both stages
are cached:

- The library is cached in memory for the session. Kernels compiled in a package's
  precompilation workload (e.g., with PrecompileTools.jl) are stored in the package image,
  so that a new session can launch them without running the Julia compiler.
- Metal caches the GPU code in a per-user shader cache
  (`$(getconf DARWIN_USER_CACHE_DIR)com.apple.metal`), keyed on the library's contents.
  Since Metal.jl generates the same library for a kernel in every session, later sessions
  normally skip the driver compilation. The cache is bounded, so compiling thousands of
  kernels evicts older entries.


## Inspecting generated code

Prefix a launch with a `@device_code_*` macro to see the code it compiles:
[`@device_code_typed`](@ref) and [`@device_code_warntype`](@ref) show Julia IR (useful to
find type instabilities), [`@device_code_llvm`](@ref) LLVM IR, and
[`@device_code_air`](@ref) the AIR passed to Metal. [`@device_code`](@ref) writes all of
them to files. Apple doesn't expose the GPU code; [Xcode and
Instruments](../development/xcode.md) relates performance to source lines.

```julia
julia> @device_code_warntype @metal threads=4 groups=2 fill_index!(a)
```
