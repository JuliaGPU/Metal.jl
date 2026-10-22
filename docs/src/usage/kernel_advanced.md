# Advanced kernel programming

Threads cooperate through threadgroup memory, SIMD-group functions, atomics and SIMD-group
matrices. Start with [Kernel programming](kernel.md) for launch configuration and indexing;
see the [kernel API reference](../api/kernel.md) for individual functions.


## Threadgroup memory

Threadgroup memory is fast memory shared by the threads of a threadgroup, and allocated
per threadgroup when the kernel launches. Allocate it in the kernel with
[`MtlThreadGroupArray`](@ref), whose element type and size must be known at compile time.
Apple GPUs provide 32 KB of threadgroup memory per threadgroup.

Threads that read what other threads wrote must first wait for them with
[`threadgroup_barrier`](@ref). Pass `Metal.MemoryFlagThreadGroup` to also order the
threadgroup memory accesses: without flags, `threadgroup_barrier()` only synchronizes
execution, and threads may not see each other's writes. Use `Metal.MemoryFlagDevice` for
device memory, i.e. `MtlArray`s, and combine flags with `|`. Barriers are needed even when
a threadgroup consists of a single SIMD-group
([Apple](https://developer.apple.com/documentation/apple-silicon/porting-your-metal-code-to-apple-silicon)),
and every thread of the threadgroup has to reach the same barrier.

This kernel sums each threadgroup's part of `x` with a tree reduction in threadgroup
memory, writing one partial sum per threadgroup:

```julia
using Metal

function partial_sums!(out, x)
    tid = thread_position_in_threadgroup().x
    i = thread_position_in_grid().x
    shared = MtlThreadGroupArray(Float32, 256)
    shared[tid] = i <= length(x) ? x[i] : 0f0
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)

    step = threads_per_threadgroup().x ÷ 2
    while step > 0
        if tid <= step
            shared[tid] += shared[tid + step]
        end
        threadgroup_barrier(Metal.MemoryFlagThreadGroup)
        step ÷= 2
    end

    if tid == 1
        out[threadgroup_position_in_grid().x] = shared[1]
    end
    return
end

x = Metal.rand(Float32, 10_000)
groups = cld(length(x), 256)
out = Metal.zeros(Float32, groups)
@metal threads=256 groups=groups partial_sums!(out, x)
sum(Array(out)) ≈ sum(Array(x))    # true
```

Launch this example with 256 threads per threadgroup. If you change that size, keep it a
power of two and update the allocation of `shared` to match. All threads execute every
barrier, including threads that do not add values.


## [SIMD-group functions](@id simdgroup-functions)

The threads of a SIMD-group can exchange values without going through memory.
[`simd_shuffle_down`](@ref)`(val, n)` returns `val` from the thread `n` positions further
in the SIMD-group, [`simd_shuffle_up`](@ref) from `n` positions earlier, [`simd_shuffle`](@ref) from a
given thread, and [`simd_shuffle_xor`](@ref) from the thread whose index differs by the
given bits. [`simd_ballot`](@ref), [`simd_vote_all`](@ref) and [`simd_vote_any`](@ref)
evaluate a condition across the SIMD-group: `simd_ballot` turns a `Bool` into a mask of
the threads for which it holds, which the vote functions test. The `quad_*` versions do the
same within quad-groups of four threads. The shuffles support 8-, 16- and 32-bit integers,
`Float16` and `Float32`.

A reduction over a SIMD-group takes five shuffles with 32 threads, and needs no barriers
as long as all threads of the SIMD-group take part in every shuffle. The
first thread of each SIMD-group then adds its result to the total with an atomic (see
below):

```julia
function simd_sum!(total, x)
    i = thread_position_in_grid().x
    val = i <= length(x) ? x[i] : 0f0
    offset = threads_per_simdgroup() ÷ 2
    while offset > 0
        val += simd_shuffle_down(val, offset)
        offset ÷= 2
    end
    if thread_index_in_simdgroup() == 1
        Metal.@atomic total[1] += val
    end
    return
end

x = Metal.rand(Float32, 10_000)
total = Metal.zeros(Float32, 1)
@metal threads=256 groups=cld(length(x), 256) simd_sum!(total, x)
Array(total)[1] ≈ sum(Array(x))    # true
```

Use [`threads_per_simdgroup`](@ref) rather than assuming 32, and launch threadgroups whose
size is a multiple of it, so that every SIMD-group is complete. Because the order in which
threads add to `total` varies, the result can differ in the last bits between runs.


## Atomics

Atomic operations let threads update the same memory location without losing updates. The
[`Metal.@atomic`](@ref) macro applies one to an array element, here to count values in a
histogram:

```julia
function histogram!(counts, data)
    i = thread_position_in_grid().x
    if i <= length(data)
        Metal.@atomic counts[data[i]] += Int32(1)
    end
    return
end

data = rand(1:16, 10_000)
counts = Metal.zeros(Int32, 16)
@metal threads=256 groups=cld(length(data), 256) histogram!(counts, MtlArray(Int32.(data)))
Array(counts) == [count(==(b), data) for b in 1:16]    # true
```

Metal supports atomic operations on `Int32`, `UInt32` and `Float32` values, in device and
threadgroup memory. Integers support `+`, `-`, `&`, `|`, `⊻`, `min` and `max`; `Float32`
supports `+` and `-`, for threadgroup memory only from Metal 4.1 (macOS 27). `Metal.@atomic`
implements other operations with a compare-and-exchange loop. Apple8 GPUs (M2) and newer
also support `min` and `max` on `UInt64` in device memory.

The `atomic_*_explicit` functions follow MSL's functions of the same name.
`Metal.atomic_fetch_add_explicit(pointer(a, i), val)`, for example, adds `val` and returns
the previous value. An optional [`memory_order`](@ref) controls ordering. The default,
`memory_order_relaxed`, only makes the operation itself atomic. Acquire and release orders also order the memory accesses around
it, e.g. to publish data written before setting a flag. Before Metal 4.1, Metal.jl
implements ordered atomics with fences. [`atomic_thread_fence`](@ref) orders memory
accesses without an atomic operation.


## SIMD-group matrices

Apple GPUs can multiply 8×8 matrices cooperatively in a SIMD-group, which Metal.jl's matrix
multiplication uses. An [`MtlSimdgroupMatrix`](@ref) holds such a matrix, distributed over
the threads of the SIMD-group. Load it from device or threadgroup memory with
[`simdgroup_load`](@ref), multiply with `*` or `muladd`, and store the result with
[`simdgroup_store`](@ref):

```julia
function matmul_8x8!(c, a, b)
    ma = simdgroup_load(MtlSimdgroupMatrix{Float32,8,8}, a)
    mb = simdgroup_load(MtlSimdgroupMatrix{Float32,8,8}, b)
    simdgroup_store(ma * mb, c)
    return
end

a = rand(Float32, 8, 8)
b = rand(Float32, 8, 8)
c = Metal.zeros(Float32, 8, 8)
@metal threads=32 matmul_8x8!(c, MtlArray(a), MtlArray(b))
Array(c) ≈ a * b    # true
```

All threads of the SIMD-group have to execute these operations together. The element type
can be `Float16`, `Float32` or `BFloat16`. Pass an origin to work on a tile of a larger
matrix, e.g. `simdgroup_load(MtlSimdgroupMatrix{Float32,8,8}, a, (9, 1))` loads
`a[9:16, 1:8]`. Larger products accumulate tiles with `muladd(ma, mb, mc)`, starting from
`zero(MtlSimdgroupMatrix{Float32,8,8})`.

On macOS 26 and later, Metal 4's tensor operations are available as `MtlInlineTensor` and
`TensorOpsMatmul2D`. This interface is experimental.


## Threadgroup size hints

Two keywords of `@metal` tell the compiler which threadgroup sizes the kernel will be
launched with:

- `maxthreads=n` limits threadgroups to `n` threads, like MSL's
  `max_total_threads_per_threadgroup`. A lower limit gives each thread more registers, which
  can avoid spilling in complex kernels.
- `minthreads=(x, y, z)` requires exactly that threadgroup size, like MSL's
  `required_threads_per_threadgroup`, so the compiler can specialize for it. It requires
  macOS 26, and launches with another size are rejected.

Both are reflected in the kernel's `maxthreads`:

```julia
julia> kernel = @metal launch=false maxthreads=256 random!(a);

julia> kernel.maxthreads
256
```


## Feature checks

[`metal_version`](@ref), [`air_version`](@ref) and [`apple_family`](@ref) return the Metal
version, AIR version and Apple GPU family targeted by the kernel. These values are known
at compile time, so unsupported operations can be placed in branches that are compiled out:

```julia
function update_max!(a, val)
    if apple_family() >= 8
        Metal.atomic_max_explicit(pointer(a), val)    # UInt64 atomics need Apple8
    else
        # fallback
    end
    return
end

@metal update_max!(Metal.zeros(UInt64, 1), UInt64(5))
```

On an M1 (Apple7), this kernel compiles the fallback; without the check, compilation fails
with `static assertion failed (64-bit atomic min/max requires Apple8 or newer.)`.

By default, kernels are compiled for the newest versions that the macOS version and the
GPU support. The `metal`, `macos` and `gpufamily` keywords of `@metal` select others; see
[`Metal.mtlfunction`](@ref).


## Random numbers

`rand` works in kernels, producing numbers from a counter-based generator:

```julia
function random!(a)
    i = thread_position_in_grid().x
    if i <= length(a)
        a[i] = rand(Float32)
    end
    return
end

a = Metal.zeros(Float32, 1024)
@metal threads=1024 random!(a)
```

Every launch is seeded differently, so repeated launches give different numbers. Calling
`Random.seed!(seed)` in the kernel (after `using Random`), with the same seed in all threads
and before drawing, makes the numbers reproducible; threads still draw different numbers.
The supported types are
`Int32`, `UInt32`, `Int64`, `UInt64`, `Float16` and `Float32`.


## Read-only arrays

Wrapping an array with `Metal.Const` (or `Base.Experimental.Const`) inside a kernel promises
that it won't be modified during the kernel. That lets the compiler cache and reorder loads
from it:

```julia
function scale!(y, x)
    i = thread_position_in_grid().x
    if i <= length(y)
        @inbounds y[i] = 2 * Metal.Const(x)[i]
    end
    return
end
```

Modifying memory read through `Const` during the kernel is undefined behavior, including
writes through another argument that aliases it.
