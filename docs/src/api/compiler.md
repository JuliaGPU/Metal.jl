# Compiler

See [Kernel programming](../usage/kernel.md) for compiling, launching and inspecting kernels.

## Launching kernels

```@docs
@metal
Metal.HostKernel
Metal.mtlfunction
Metal.mtlconvert
```

Kernels that weren't compiled by Metal.jl, e.g., from a precompiled Metal library, can be
launched with `metalcall`:

```@docs
metalcall
Metal.metalcall_tuple
```

## Inspecting generated code

The `@device_code_*` macros evaluate an expression and show the code of every kernel it
compiles, like the `@code_*` macros of InteractiveUtils. The `code_*` functions do the same
for a function and argument types.

```@docs
@device_code_lowered
@device_code_typed
@device_code_warntype
@device_code_llvm
@device_code_air
@device_code_metal
@device_code
Metal.code_typed
Metal.code_warntype
Metal.code_llvm
Metal.code_air
Metal.code_native
```
