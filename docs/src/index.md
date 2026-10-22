# Metal.jl

Metal.jl lets you program the GPU of an Apple silicon Mac from Julia, using GPU arrays or
kernels written in Julia. It compiles Julia code to Apple's intermediate representation (AIR)
and hands it to the GPU driver through the [Metal](https://developer.apple.com/documentation/metal)
framework, so you don't need Xcode or a Metal toolchain.

Requirements:

- a Mac with Apple silicon (M1 or newer);
- macOS 15 or newer;
- Julia 1.10 or newer, the native Apple silicon (`aarch64`) build rather than the Intel one
  running under Rosetta.

Install the package and check that it finds your GPU:

```julia
using Pkg
Pkg.add("Metal")

using Metal
Metal.versioninfo()
```

[`Metal.versioninfo()`](@ref) reports your system, package versions and available GPUs. If it finds
no devices, see [Troubleshooting](@ref troubleshooting).

A first array operation:

```julia
julia> a = MtlArray(Float32[1, 2, 3]);

julia> a .+ 1f0
3-element MtlVector{Float32, Metal.SharedStorage}:
 2.0
 3.0
 4.0
```

For direct access to Apple's frameworks,
`Metal.MTL` and `Metal.MPS` wrap [Metal](https://developer.apple.com/documentation/metal)
and [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders).
They follow Apple's API closely; consult Apple's documentation for their concepts.

## Where to go next

- [Introduction](tutorials/introduction.md): a tutorial from broadcasting to a parallel kernel.
- [Arrays](@ref): constructing `MtlArray`s, supported element types and array operations.
- [Memory](@ref) and [Tasks and synchronization](@ref): how GPU memory and asynchronous
  execution work, and when you need to wait for the GPU.
- [Kernel programming](usage/kernel.md): writing your own kernels with `@metal`.
- [Profiling](@ref) and [Performance](development/performance.md): measuring and improving performance.
- [Troubleshooting](@ref troubleshooting): common error messages and what they mean.

## Getting help and contributing

Ask questions in the [GPU domain of the Julia Discourse](https://discourse.julialang.org/c/domain/gpu)
or the `#gpu` channel of the [Julia Slack](https://julialang.org/slack/). Report bugs and
missing functionality on the [issue tracker](https://github.com/JuliaGPU/Metal.jl/issues),
including the output of `Metal.versioninfo()`. To work on Metal.jl itself, see
[Contributing](@ref).

If you use Metal.jl in research, please cite it using the
[CITATION.cff](https://github.com/JuliaGPU/Metal.jl/blob/main/CITATION.cff) file in the
repository. Metal.jl is maintained by Tim Besard (@maleadt) and Christian Guinard
(@christiangnrd).
