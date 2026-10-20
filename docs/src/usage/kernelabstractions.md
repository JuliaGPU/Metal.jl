# KernelAbstractions

[KernelAbstractions.jl](https://juliagpu.github.io/KernelAbstractions.jl/stable/) provides
portable kernels for CPUs and GPUs. Metal.jl's `MetalBackend` runs them on `MtlArray`s.
For Apple-specific kernel features, use [`@metal`](@ref); see
[Kernel programming](kernel.md).

```jldoctest ka
julia> using KernelAbstractions, Metal

julia> @kernel function axpy!(y, a, @Const(x))
           i = @index(Global)
           @inbounds y[i] += a * x[i]
       end;

julia> x = MtlArray(Float32.(1:1000)); y = Metal.ones(Float32, 1000);

julia> backend = get_backend(y)
MetalBackend()

julia> axpy!(backend)(y, 2f0, x; ndrange = length(y))

julia> KernelAbstractions.synchronize(backend)

julia> Array(y) ≈ 1 .+ 2 .* (1:1000)
true
```

`get_backend` returns `MetalBackend()` for any `MtlArray`, and `MetalBackend()` can also be
constructed directly, e.g. to allocate with `KernelAbstractions.zeros(MetalBackend(),
Float32, n)`. Launches are asynchronous and ordered with the other GPU work of the task, as
with `@metal` (see [Tasks and synchronization](tasks.md)). Write
`KernelAbstractions.synchronize(backend)` or `Metal.synchronize()` in full: with both
packages loaded, a bare `synchronize` is ambiguous.

## Mapping to Metal



| KernelAbstractions | Metal |
|:-------------------|:------|
| workitem | thread |
| workgroup (`@groupsize`) | threadgroup |
| `ndrange` | grid |
| sub-group | SIMD-group, 32 threads wide |
| `@localmem` | threadgroup memory |
| `@synchronize` | `threadgroup_barrier` ordering device and threadgroup memory |
| `@print` | [`@mtlprint`](@ref) |
| `@Const` | read-only, invariant loads ([`Metal.Const`](@ref)) |

For example, this kernel reverses each workgroup's chunk of the input through threadgroup
memory:

```jldoctest ka
julia> @kernel function reverse_groups!(out, @Const(inp))
           i = @index(Local)
           g = @index(Global)
           @uniform n = @groupsize()[1]
           tile = @localmem Float32 (n,)
           @inbounds tile[i] = inp[g]
           @synchronize
           @inbounds out[g] = tile[n - i + 1]
       end;

julia> a = MtlArray(Float32.(1:512)); b = similar(a);

julia> reverse_groups!(backend, 256)(b, a; ndrange = length(a))

julia> Array(b) == [256:-1:1; 512:-1:257]
true
```

The size of `@localmem` must be known when the kernel is compiled, so instantiate the
kernel with a static workgroup size (here `256`).

## Limitations

- `Float64` is not supported, as in all Metal kernels:
  `KernelAbstractions.supports_float64(MetalBackend())` is `false`.
- Atomic operations (`KernelAbstractions.@atomic`, from Atomix.jl) work on `Int32`, `UInt32`
  and `Float32` in device memory. `KernelAbstractions.supports_atomics` returns `true` only
  on macOS 27 and later (MSL 4.1), the first version whose atomic operations take a memory
  order; before it, Metal.jl implements ordered atomics with fences.
- The workgroup size is limited to the kernel's maximum number of threads per threadgroup,
  at most 1024.
