# Array programming

The Metal array type, `MtlArray`, generally implements the Base array interface
and all of its expected methods.

However, there is the special function `mtl` for transferring an array over to the gpu. For compatibility reasons, it will automatically convert arrays of `Float64` to `Float32`.

```@docs
mtl
MtlArray
MtlVector
MtlMtrix
MtlVecOrMat
```

## Storage modes

The Metal API has various storage modes that dictate how a resource can be accessed. `MtlArray`s are `Private` by default, but they can also be `Shared` or `Managed`. For more information on storage modes, see the official [Metal documentation](https://developer.apple.com/documentation/metal/resource_fundamentals/setting_resource_storage_modes).

```@docs
Private
Shared
Managed
CPUStorage
```

There also exist the following convenience functions to check if an MtlArray is using a specific storage mode:

```@docs
is_private
is_shared
is_managed
```
