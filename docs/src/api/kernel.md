# Kernel programming

This section lists the package's public functionality that corresponds to special Metal
functions for use in device code. For more information about these functions,
please consult the [Metal Shading Language specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf).

This is made possible by interfacing with the Metal libraries by wrapping a subset of the ObjectiveC APIs using [ObjectiveC.jl](https://github.com/JuliaInterop/ObjectiveC.jl). These low-level wrappers are available in the MTL submodule exported by Metal.jl.


## Indexing and dimensions

```@docs
thread_index_in_quadgroup
thread_index_in_simdgroup
thread_index_in_threadgroup
thread_position_in_grid
thread_position_in_threadgroup
threadgroup_position_in_grid
threadgroups_per_grid
threads_per_grid
threads_per_simdgroup
threads_per_threadgroup
simdgroups_per_threadgroup
simdgroup_index_in_threadgroup
quadgroup_index_in_threadgroup
quadgroups_per_threadgroup
grid_size
grid_origin
thread_execution_width
```


## Device arrays

Metal.jl provides a primitive, lightweight array type to manage GPU data organized in an
plain, dense fashion. This is the device-counterpart to the `MtlArray`, and implements (part
of) the array interface as well as other functionality for use _on_ the GPU:

```@docs
MtlDeviceArray
Metal.Const
```

### Shared memory

```@docs
MtlThreadGroupArray
```

## Synchronization

```@docs
MemoryFlags
threadgroup_barrier
simdgroup_barrier
```
