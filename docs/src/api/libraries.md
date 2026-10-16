# Libraries

Metal stores compiled code in libraries (`.metallib` files): containers that hold one or
more AIR modules (LLVM bitcode) together with the metadata Metal needs to instantiate them.
Metal.jl generates such libraries for every kernel it compiles, and can read, inspect, edit
and write them, also when they were produced by Apple's toolchain.

```julia
julia> lib = read("shaders.metallib", Metal.MetalLib)
MetalLib(
  file: METALLIB_EXECUTE v1.2.9 [macOS]
  platform: METALLIB_PLATFORM_MACOS v26.0.0 [64-bit]
  functions:
    foo [AIR v2.8.0, Metal v4.0.0]
    bar [AIR v2.8.0, Metal v4.0.0]
)

julia> lib.functions[1].air_module       # the function's LLVM bitcode
3040-element Vector{UInt8}: ...

julia> write("foo.metallib", Metal.MetalLib(lib; functions = lib.functions[1:1]))
```

To load a library on a device, pass its bytes to `MTL.MTLLibraryFromData`, or the path of a
file to `MTL.MTLLibraryFromFile`.

```@docs
Metal.MetalLib
Metal.MetalLibFunction
Metal.FunctionConstant
Metal.DebugInfo
Metal.MetalLibFormatError
```
