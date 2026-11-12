# # Introduction
#
# Add two vectors on the GPU, first with array operations and then with a kernel you write
# yourself. You'll learn how threads and threadgroups divide the work and how to choose a
# launch configuration. Install Metal.jl as described on the [home page](../index.md)
# before starting. No GPU programming experience is needed.
#
# It is inspired by Mark Harris's [An Even Easier Introduction to
# CUDA](https://developer.nvidia.com/blog/even-easier-introduction-cuda/), and by the
# equivalent tutorial of CUDA.jl.


# ## A simple calculation on the CPU
#
# We'll add two vectors, a calculation where every element is updated independently of
# the others:

using Test

N = 100_000
x = fill(1.0f0, N)  # a vector filled with 1.0 (Float32)
y = fill(2.0f0, N)  # a vector filled with 2.0

y .+= x             # increment each element of y with the corresponding element of x

@test all(y .== 3.0f0)

# We use `Float32` because Apple GPUs don't support `Float64` arithmetic. The length `N`
# is not a multiple of the threadgroup size we'll use later.


# ## Array programming on the GPU
#
# The easiest way to use the GPU is to put the data in an [`MtlArray`](@ref) and keep using
# array operations. Metal.jl executes them on the GPU:

using Metal

x_d = Metal.fill(1.0f0, N)  # a vector stored on the GPU, filled with 1.0
y_d = Metal.fill(2.0f0, N)  # a vector stored on the GPU, filled with 2.0

y_d .+= x_d

@test all(Array(y_d) .== 3.0f0)

# The `_d` suffix stands for "device", as opposed to the "host" (the CPU). `Array(y_d)`
# copies the result to a CPU array, so that we can check it with ordinary Julia code.
#
# GPU operations are *asynchronous*: the CPU submits work to the GPU and continues without
# waiting for it to finish. Operations that need the result, such as `Array(y_d)`, wait
# automatically. When you time GPU code, though, you have to wait explicitly, or you only
# measure how long it took to submit the work. `Metal.@sync` runs an expression and then
# waits for the GPU. Here `@elapsed` reports the time in seconds, after a first call that
# compiles the operation:

Metal.@sync y_d .+= x_d
@elapsed Metal.@sync y_d .+= x_d

# Broadcasting, `map`, `reduce` and the other array operations are often all you need, and
# they are a good baseline to compare custom kernels against. See [Arrays](../usage/array.md)
# for what is available.


# ## Your first GPU kernel
#
# A *kernel* is a function that runs on the GPU. Start with a sequential loop:

function gpu_add1!(y, x)
    for i in 1:length(y)
        @inbounds y[i] += x[i]
    end
    return
end

fill!(y_d, 2)
@metal gpu_add1!(y_d, x_d)
@test all(Array(y_d) .== 3.0f0)

# Kernels must return `nothing`, so this function ends with `return` and writes its results
# to an array argument. The [`@metal`](@ref) macro compiles
# the function for the GPU the first time it's called with these argument types, and then
# launches it. Like other GPU operations, the launch is asynchronous.
#
# By default `@metal` launches a single thread, which processes one element after the
# other. A GPU executes such sequential code much slower than a CPU: its strength is running
# many threads at once.


# ## Running threads in parallel
#
# A kernel launch runs an instance of the kernel on each *thread*. Each thread uses its
# position to select the elements it processes. Threads are organized in a hierarchy:
#
# - threads are grouped into *threadgroups*, of at most 1024 threads. The threads of a
#   threadgroup can cooperate through fast threadgroup memory and synchronize with
#   barriers;
# - the threadgroups together form the *grid*, which covers the whole problem.
#
# You choose both sizes when launching the kernel: `threads` is the number of threads per
# threadgroup, and `groups` the number of threadgroups. Inside the kernel,
# [`thread_position_in_grid`](@ref) returns the position of the current thread in the
# grid, as a named tuple with `x`, `y` and `z` fields, counting from 1. For a vector, only
# `x` matters:

function gpu_add2!(y, x)
    i = thread_position_in_grid().x
    if i <= length(y)
        @inbounds y[i] += x[i]
    end
    return
end

threads = 256
groups = cld(N, threads)    # round up, so that groups * threads >= N

fill!(y_d, 2)
@metal threads=threads groups=groups gpu_add2!(y_d, x_d)
@test all(Array(y_d) .== 3.0f0)

# Each thread now adds a single element. Since `N` isn't a multiple of 256, we launched
# slightly more threads than there are elements:

groups * threads - N

# The `if i <= length(y)` check keeps those extra threads from writing past the end of the
# arrays. Without it, and with `@inbounds`, they would access memory out of bounds, which
# is undefined behavior.
#
# You might wonder why we didn't launch a single threadgroup of `N` threads. A threadgroup
# is limited in size, so a large problem needs many of them, and many threadgroups keep all
# of the GPU's cores busy:

try
    @metal threads=N gpu_add2!(y_d, x_d)
catch err
    err
end

# Timing the parallel kernel the same way as before:

Metal.@sync @metal threads=threads groups=groups gpu_add2!(y_d, x_d)
@elapsed Metal.@sync @metal threads=threads groups=groups gpu_add2!(y_d, x_d)

# Results depend on the GPU and problem size. This kernel performs the same work as the
# broadcast; writing it by hand does not necessarily make it faster.


# ## Choosing a launch configuration
#
# The value 256 above was arbitrary. The maximum number of threads in a threadgroup
# depends on the kernel: one that uses many registers or much threadgroup memory may support
# fewer than the 1024 threads per threadgroup that Apple GPUs otherwise allow. To query the limit,
# compile the kernel without launching it, by passing `launch=false` to `@metal`. That
# returns a kernel object, which you can inspect and then call with the same arguments and
# the launch configuration:

kernel = @metal launch=false gpu_add2!(y_d, x_d)
kernel.maxthreads

# `kernel.maxthreads` is the compiled pipeline's
# [`maxTotalThreadsPerThreadgroup`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/maxtotalthreadsperthreadgroup).
# For this kernel, start with the largest allowed threadgroup, capped by the number of
# elements, and enough threadgroups to cover the vector:

threads = min(N, kernel.maxthreads)
groups = cld(N, threads)

fill!(y_d, 2)
kernel(y_d, x_d; threads, groups)
@test all(Array(y_d) .== 3.0f0)

# This covers the vector with one thread per element, plus any extra threads skipped by
# the bounds check. See [Kernel programming](../usage/kernel.md) for multidimensional
# launches and other launch-size considerations.


# ## Errors in kernels
#
# Without `@inbounds`, indexing an array in a kernel checks its bounds, as on the CPU. When
# a thread fails such a check, the kernel doesn't stop: the error is recorded, and the next
# synchronization throws it on the CPU as a `KernelException`:
#
# ```julia
# julia> function gpu_add3!(y, x)
#            i = thread_position_in_grid().x
#            y[i] += x[i]     # no guard for threads beyond the end of the arrays
#            return
#        end
#
# julia> @metal threads=256 groups=cld(N, 256) gpu_add3!(y_d, x_d)
#
# julia> synchronize()
# ERROR: KernelException: A BoundsError was thrown on device Apple M1: Out-of-bounds array access
# For more details, run Julia with `-g2`, or launch the kernel with `@metal debug_level=2`
# ```
#
# The [Kernel programming](../usage/kernel.md) page explains how to get more detail, and how
# to print values from a kernel while debugging.


# ## Next steps
#
# - [Kernel programming](../usage/kernel.md) describes the execution model, launch
#   configuration, what code kernels can contain, printing and errors.
# - [Advanced kernel programming](../usage/kernel_advanced.md) covers threadgroup memory,
#   SIMD-group functions, atomics and SIMD-group matrices.
# - [Profiling](../development/profiling.md) and [Xcode and
#   Instruments](../development/xcode.md) show where the time goes in your GPU code.
