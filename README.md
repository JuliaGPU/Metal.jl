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
-  Julia 1.8
-  macOS 13 (Ventura)

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
macOS 12.2.0, Darwin 21.3.0

Toolchain:
- Julia: 1.8.0-beta3
- LLVM: 13.0.1

1 device:
- Apple M1 Pro (64.000 KiB allocated)
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

julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);

julia> @metal threads=length(c) vadd(a, b, c)

julia> Array(c)
1-element Vector{Int64}:
 3
```

## Profiling

This package also supports profiling GPU execution for later visualization with Apple's
Xcode tools. The easiest way to generate a GPU report is to use the `Metal.@profile` macro as seen
below. To profile GPU code from a Julia process,
you must set the `METAL_CAPTURE_ENABLED` environment variable. On the first Metal
command detected, you should get a message stating "Metal GPU Frame Capture Enabled" if the
variable was set correctly.

```julia
$ METAL_CAPTURE_ENABLED=1 julia
...

julia> using Metal

julia> function vadd(a, b, c)
           i = thread_position_in_grid_1d()
           c[i] = a[i] + b[i]
           return
       end
vadd (generic function with 1 method)

julia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);
... Metal GPU Frame Capture Enabled

julia> Metal.@profile @metal threads=length(c) vadd(a, b, c);
[ Info: GPU frame capture saved to /var/folders/x3/75r5z4sd2_bdwqs68_nfnxw40000gn/T/jl_WzKxYVMlon/jl_metal.gputrace/
```

This will generate a `.gputrace` folder in a temporary directory. To view the profile, open
the folder with Xcode. Since the temporary directory is destroyed when the Julia process
ends though, be sure to copy the `.gputrace` directory to a stable location on your system
for later viewing.

Note: Xcode is a large install, and there are some peculiarities with viewing Julia-created
GPU traces. It's recommended to only have one trace open at a time, and the shader profiler
may fail to start.

## Metal API wrapper

Finally, all of the above functionality is made possible by interfacing with
the Metal libraries through a [small C library](https://github.com/JuliaGPU/cmt)
that wraps the ObjectiveC APIs.

These low-level wrappers, along with some slightly higher-level Julia wrappers,
are available in the `MTL` submodule exported by Metal.jl. All wrapped C
functions and types start with the `mt` prefix, whereas the Julia wrappers are
prefixed with `Mtl`:

```julia
julia> dev = MtlDevice(1)
MtlDevice:
 name:             Apple M1 Pro
 lowpower:         false
 headless:         false
 removable:        false
 unified memory:   true
 registry id:      4294969448
 transfer rate:    0

julia> dev.name
"Apple M1 Pro"
```


## Hacking

Metal.jl relies on two binary dependencies (provided as JLLs):

- [cmt](https://github.com/JuliaGPU/Metal.jl/tree/main/deps/cmt)
- [LLVM with an AIR back-end](https://github.com/JuliaGPU/llvm-metal)

Normally, these dependencies are built on
[Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/).
If you need to make changes to these dependencies, have a look at the
`build_cmt.jl` and `build_llvm.jl` scripts in the `deps/` folder. These
scripts build a local version of the dependency, and configure a local
preference such that any environment depending on the corresponding JLLs will
pick-up the modified version (i.e., do `julia --project` in a clone
of `Metal.jl`):

```
$ julia --project -e 'using Metal; @show MTL.cmt.libcmt'
MTL.libcmt = "/Users/tim/Julia/depot/artifacts/6adc0ed9a8370ff1e3bb8fbaf36e8519ee11fd96/lib/libcmt.dylib"

$ julia --project=deps deps/build_cmt.jl
...
[100%] Built target cmt

$ julia --project -e 'using Metal; @show MTL.cmt.libcmt'
MTL.libcmt = "/Users/tim/Julia/depot/scratchspaces/dde4c033-4e86-420c-a63e-0dd931031962/cmt/lib/libcmt.dylib"
```

These scripts are integrated with our CI, and will be triggered if
the `ci.build_cmt` or `ci.build_llvm` labels are set on a pull request.


## Acknowledgements

The C library started by forking [rcp/cmt](https://github.com/recp/cmt), to whom
goes the original credit. This package builds upon the experience of several
Julia contributors to CUDA.jl, AMDGPU.jl and oneAPI.jl.
