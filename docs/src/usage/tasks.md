# Tasks and synchronization

Most GPU operations return after queueing work, before the GPU has finished. Metal.jl
orders dependent operations and waits when the CPU needs their results.

## Asynchronous execution

Kernel launches, broadcasts and most other array operations return before the GPU has
finished:

```julia
using Metal

a = Metal.rand(Float32, 10^8)
@time a .= sin.(a)                 # returns once the work is queued
@time Metal.@sync a .= sin.(a)     # waits for the GPU to finish
```

You rarely need to wait yourself, because Metal.jl waits wherever the CPU needs a result:

- copying to the CPU, with `Array(a)`, `copyto!` or `collect`;
- reductions that return a value to the CPU, such as `sum(a)`;
- reading or writing elements of a shared array from the CPU, including printing it, which
  waits for the GPU work that uses that array;
- the REPL, which waits for all GPU work at the end of every input.

You do need to wait yourself when you measure time, and when you access GPU memory through
an `Array` created with `unsafe_wrap` or a pointer (see [Sharing memory with CPU
arrays](@ref)).

## Waiting for the GPU

| Function | Waits for |
|---|---|
| [`synchronize`](@ref)`()` | the GPU work of the current task, and work left behind by tasks that have finished |
| `Metal.@sync ex` | evaluates `ex`, then calls `synchronize()` |
| [`device_synchronize`](@ref)`()` | the GPU work of all tasks |

By default, other Julia tasks can run on the thread while a task waits for the GPU. Set
`nonblocking_synchronization=false` to block the thread instead (see [Configuration](@ref)).

To time GPU code, synchronize before stopping the clock, e.g. with [`Metal.@sync`](@ref), or use
[`Metal.@time`](@ref) or the [integrated profiler](@ref "Integrated profiler"):

```julia
using BenchmarkTools
@btime Metal.@sync $a .= sin.($a)
```

## Ordering and command batching

Operations that a task submits execute in the order it submitted them, so a kernel always
sees the results of the operations before it.

Metal executes work in [command buffers](https://developer.apple.com/documentation/metal/mtlcommandbuffer).
To reduce submission overhead, Metal.jl collects consecutive operations into one command
buffer. By default, it submits the buffer after 32 operations or 64 MiB of copies, or sooner
when you synchronize or the CPU needs a result. Up to three command buffers are in flight at a time; submitting more
waits for the GPU to finish one. The limits are adjustable, and batching can be disabled
(see [Configuration](@ref)). While a GPU profiler is attached, each operation gets its own
command buffer.

## Using multiple tasks

Each Julia task has its own command queue (see [`Metal.global_queue`](@ref)), so tasks
submit work independently, and the GPU can execute work from different tasks concurrently.
Use tasks to overlap independent GPU work, or GPU work with CPU work:

```julia
using Metal

xs = [Metal.rand(Float32, 10^6) for _ in 1:4]
tasks = map(xs) do x
    Threads.@spawn x .= sqrt.(x)
end
foreach(wait, tasks)
all(x -> all(>=(0f0), x), xs)  # true
```

Metal.jl tracks which queue last used each array. When another task uses that array, it
waits for the previous queue's work; CPU access through the `MtlArray` waits too. Waiting
for a Julia task to finish does not itself mean its GPU work has finished.

This applies to arrays sharing an allocation, such as views and reshapes. Memory wrapped
separately (e.g. with `unsafe_wrap`) and raw pointers aren't tracked, and need explicit
synchronization. The tracking also doesn't determine which task should use an array first. Coordinate tasks
that share mutable data as you would on the CPU.

## [Errors](@id gpu-errors)

Errors on the GPU are reported when you synchronize, not when you launch: either at an
explicit `synchronize`, or wherever Metal.jl waits implicitly, e.g. at `Array(a)`:

```julia
using Metal

function oob(a)
    a[thread_position_in_grid().x] = 1f0
    return
end

a = Metal.zeros(Float32, 4)
@metal threads=8 oob(a)   # no error yet
synchronize()
```
```
ERROR: KernelException: A BoundsError was thrown on device Apple M1: Out-of-bounds array access
For more details, run Julia with `-g2`, or launch the kernel with `@metal debug_level=2`
```

The REPL waits at the end of every input, so there the error appears at the input that
launched the kernel.

There are two kinds of errors:

- a `KernelException` when the kernel threw a Julia exception, such as this bounds error (see
  [Errors and debug levels](@ref) for getting more detail);
- a [`CommandBufferError`](@ref) when Metal reports that a command buffer failed, e.g.
  because a kernel ran too long or accessed invalid memory. It includes Metal's error
  description.

When both occur, they are thrown together as a `CompositeException`. Kernel exceptions are
recorded per device, so with several tasks the exception can surface in a different task
than the one that launched the failing kernel.
