# Compiler

## Execution

The main entry-point to the compiler is the `@metal` macro:

```@docs
@metal
```

If needed, you can use a lower-level API that lets you inspect the compiler kernel:

```@docs
Metal.mtlconvert
Metal.mtlfunction
```


## Reflection

If you want to inspect generated code, you can use macros that resemble functionality from
the InteractiveUtils standard library:

```
@device_code_lowered
@device_code_typed
@device_code_warntype
@device_code_llvm
@device_code_native
@device_code_agx
@device_code
```

For more information, please consult the GPUCompiler.jl documentation. `code_agx` is
actually `code_native`:
