# MetalCore.jl

Wraps Metal in Julia. Takes ideas from other `GPGPU` packages in Julia.

* This is an experimental package. It will probably not work, and it's not documented (yet) *

## Requirements
- A Mac running macOs Catalina 10.15 (might also work on 10.14 but untested).
- A discrete GPU is not necessary.
- Cmake 3.9
- Command line XCode tools
- Julia 1.3

## Description
This package depends on a [small C/ObjC dynamic library](https://github.com/PhilipVinc/cmt) that exposes a C interface to julia and forwards those calls to Metal.
This library is built during the build phase of `MetalCore.jl`.

Julia wrappers to this small C library have been generated with Clang.jl by running `julia --startup-file=no --project=res/ res/wrap.jl` from the project folder.

The package contains one sub-packge, called `Metal`, which contains the wrappers to Metal and a small julian interface. All C functions start with prefix `Mt****`, as well as types. Julia types that wrap them are prefixed by `Mtl****`.

The `Metal` subpackage is organised as follows:
 - `src/Metal/api` contains the auto-generated wrappers
 - `src/Metal/wrappers` contains Julia wrappers to native-C types, that expose functions more conveniently and auto-convert the result of some function calls to julia types
 - `src/Metal/highlevel` contains the implementation of higher-level methods (like `unsafe_copyto!` or `unsafe_fill!`)


## Acknowledgements
The C library started by forking [rcp/cmt](https://github.com/recp/cmt), to whom goes the original credit.
This package builds upon the experience of several Julia contributors to `CuArrays.jl` and `RocArrays.jl`.
