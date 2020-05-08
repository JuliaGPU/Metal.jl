# MetalCore.jl

Wraps Metal. Takes ideas from CUDAdrv.jl.

Depends on a [small C/ObjC dynamic library](https://github.com/PhilipVinc/cmt) that wraps Metal Framework into a C layer that can be easily used from Julia.

The library is included as a submodule, and if you have CMake it should automatically build during the build phase. 

Julia wrappers are generated with Clang.jl by running `julia --startup-file=no --project=res/ res/wrap.jl` from this folder. 

Check the example folder.
