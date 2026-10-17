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

## Reflection data

Libraries built by Apple's toolchain describe each function with reflection data: its
arguments, return values, attributes, function constants and the types involved. Metal.jl
decodes it with the schema Apple's tools use, but does not generate it for its own kernels,
and the Metal runtime does not need it.

```julia
julia> r = Metal.reflection(lib.functions[1])
AIRR reflection v0.4.0 with 3 nodes
  #0 KernelFunction(name="foo", arguments=[#1, #2])
  #1 BufferArg(function_constant=false, location_index=UIntValue(value=0), ..., type_name="float", name="a", unused=false)
  #2 ThreadPositionInGridArg(function_constant=false, type_name="uint", name="i", unused=false)
  kernel_functions: [#0]

julia> r[r.kernel_functions[1]].name
"foo"
```

[`Metal.reflection_data`](@ref) encodes reflection objects again, e.g. after editing them or
building them with the [`Metal.ReflectionObject`](@ref) constructor.

```@docs
Metal.reflection
Metal.reflection_data
Metal.ReflectionObject
Metal.ReflectionEnum
Metal.UnknownReflectionNode
Metal.FlatBufferError
```
