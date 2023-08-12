# Array programming

The Metal array type, `MtlArray`, generally implements the Base array interface
and all of its expected methods.

However, there is the special function `mtl` for transferring an array over to the gpu. For compatibility reasons, it will automatically convert arrays of `Float64` to `Float32`.

```@docs
mtl
```