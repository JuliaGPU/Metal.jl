# Essentials

## Versions and Support
```@docs
macos_version
darwin_version
Metal.metal_support
Metal.metallib_support
Metal.air_support
Metal.metal_target
Metal.metallib_target
Metal.air_target
```

## Global State

```@docs
Metal.device!
Metal.devices
Metal.device
Metal.global_queue
synchronize
device_synchronize
```

## Low-Level Wrapper Ownership

Metal object wrappers are managed by default: Julia keeps an Objective-C reference
alive while the wrapper is reachable and releases it from a finalizer. The explicit
unmanaged exceptions are `MTLDevice`, `MTLBuffer`, and `MTLDrawable`.

`MTLDevice` is a process-level borrowed handle, `MTLBuffer` is owned by Metal.jl's
pool/`DataRef` layer, and `MTLDrawable` is a transient present-and-release object.
These wrappers are non-owning `isbits` handles; their lifetime is controlled by the
corresponding higher-level mechanism rather than by wrapper finalization.
