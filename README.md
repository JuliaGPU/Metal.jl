# Metal.jl

*Metal programming in Julia*

[![][doi-img]][doi-url] [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] [![][buildkite-img]][buildkite-url] [![][codecov-img]][codecov-url]

[doi-img]: https://zenodo.org/badge/262279120.svg
[doi-url]: https://zenodo.org/badge/latestdoi/262279120

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://metal.juliagpu.org/stable/

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://metal.juliagpu.org/dev/

[buildkite-img]: https://badge.buildkite.com/a9b335b7d5d4d7ea90b031057728de9d1e9a73d5bcd9d89655.svg?branch=main
[buildkite-url]: https://buildkite.com/julialang/metal-dot-jl

[codecov-img]: https://codecov.io/gh/JuliaGPU/Metal.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaGPU/Metal.jl

With Metal.jl it's possible to program GPUs on macOS using the Metal programming
framework.

**The package is a work-in-progress.** There are bugs, functionality is missing,
and performance hasn't been optimized. Expect to have to make changes to this package
if you want to use it. PRs are very welcome!


## Requirements

-  Mac device with M-series chip
-  Julia 1.8-1.10
-  macOS 13 (Ventura) or 14 (Sonoma)

These requirements are fairly strict, and are due to our limited development
resources (manpower, hardware). Technically, they can be relaxed. If you are
interested in contributing to this, see [this
issue](https://github.com/JuliaGPU/Metal.jl/issues/22) for more details.
In practice, Metal.jl will probably work on any macOS 10.15+, and other
GPUs that are supported by Metal might also function (if only partially),
but such combinations are unsupported for now.


## Quick start

Metal.jl can be installed with the Julia package manager. From the Julia REPL, type `]` to
enter the Pkg REPL mode and run:

```
pkg> add Metal
```

Or, equivalently, via the `Pkg` API:

```julia
julia> import Pkg; Pkg.add("Metal")
```

For an overview of the toolchain in use, you can run the following command after
importing the package:

```julia
julia> using Metal

julia> Metal.versioninfo()
macOS 13.5.0, Darwin 22.6.0

Toolchain:
- Julia: 1.9.3
- LLVM: 14.0.6

Julia packages:
- Metal.jl: 0.5.0
- LLVMDowngrader_jll: 0.1.0+0

1 device:
- Apple M2 Max (64.000 KiB allocated)
```


## Array abstraction

The easiest way to work with Metal.jl, is by using its array abstraction.
The `MtlArray` type is both meant to be a convenient container for device
memory, as well as provide a data-parallel abstraction for using the GPU
without writing your own kernels:

```julia
julia> a = MtlArray([1])
1-element MtlArray{Int64, 1}:
 1

julia> a .+ 1
1-element MtlArray{Int64, 1}:
 2
```


## Kernel programming

The above array abstractions are all implemented using Metal kernels written
in Julia. These kernels follow a similar programming style to Julia's other
GPU back-ends, and with that deviate from how kernels are implemented in Metal C
(i.e., indexing intrinsics are functions not arguments, arbitrary aggregate arguments
are supported, etc):

```julia
julia> function vadd(a, b, c)
           i = thread_position_in_grid_1d()
           c[i] = a[i] + b[i]
           return
       end
vadd (generic function with 1 method)

julia> a = MtlArray([1,1,1,1]); b = MtlArray([2,2,2,2]); c = similar(a);

julia> @metal threads=2 groups=2 vadd(a, b, c)

julia> Array(c)
4-element Vector{Int64}:
 3
 3
 3
 3
```


## Metal API wrapper

Finally, all of the above functionality is made possible by interfacing with the Metal
libraries through [ObjectiveC.jl](https://github.com/JuliaInterop/ObjectiveC.jl). We provide low-level objects and functions that map  These
low-level API wrappers, along with some slightly higher-level Julia wrappers, are available
in the `MTL` submodule exported by Metal.jl:

```julia
julia> dev = MTLDevice(1)
<AGXG13XDevice: 0x14c17f200>
    name = Apple M1 Pro

julia> dev.name
NSString("Apple M1 Pro")
```


## Acknowledgements

This package builds upon the experience of several
Julia contributors to CUDA.jl, AMDGPU.jl and oneAPI.jl.
