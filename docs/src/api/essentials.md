# Essentials

Query the system, select a GPU and wait for GPU work. See
[Tasks and synchronization](../usage/tasks.md) for execution ordering.

```@docs
Metal
```

## Versions and support

Metal.jl generates code for the newest Metal Shading Language (MSL), AIR and metallib
versions the host macOS supports. See Apple's
[Detecting GPU features and Metal software versions](https://developer.apple.com/documentation/metal/detecting-gpu-features-and-metal-software-versions).

```@docs
Metal.functional
Metal.versioninfo
macos_version
darwin_version
Metal.metal_support
Metal.air_support
Metal.metallib_support
Metal.metal_target
Metal.air_target
Metal.metallib_target
```

## Devices and global state

Every Julia task has a current device and, per device, a command queue that its GPU work
is submitted to.

```@docs
device
device!
Metal.devices
MTL.MTLDevice
global_queue
BatchedCommandQueue
```

## Synchronization

GPU work executes asynchronously. These functions wait for it to finish, and throw the
errors it reported.

```@docs
synchronize
device_synchronize
Metal.@sync
Metal.KernelException
CommandBufferError
```

## KernelAbstractions

```@docs
MetalBackend
```
