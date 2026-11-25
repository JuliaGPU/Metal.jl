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

A kernel compiled by Metal.jl can also be launched in a way Metal.jl doesn't manage, e.g.,
from an indirect command buffer that is encoded once and executed many times. Such a launch
has to provide the kernel's state and the buffers it points to:

```@docs
Metal.KernelState
Metal.kernel_resources
```

## Extending the compiler

Packages can compile functions of their own kind with Metal.jl's device library, e.g. the
stages of a render pipeline. They do so with GPUCompiler jobs whose parameters subtype
`AbstractMetalCompilerParams`, and add device functionality with Metal.jl's macros.

```@docs
Metal.AbstractMetalCompilerParams
Metal.compiler_config
Metal.compile_to_metallib
Metal.@device_override
Metal.@device_function
Metal.AS
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
