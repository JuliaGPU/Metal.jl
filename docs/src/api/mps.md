# Metal Performance Shaders

`Metal.MPS` wraps Apple's [Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders)
framework. This page documents selected array operations and wrappers; consult Apple for
framework concepts. See [Numerical operations](../usage/numerical.md) for the LinearAlgebra
interfaces and implementation choices.

## Matrix multiplication

```@docs
MPS.matmul!
MPS.matvecmul!
MPS.MPS_VALID_MATMUL_TYPES
MPS.MPS_VALID_MATVECMUL_TYPES
```

## Top-k selection

```@docs
MPS.topk
MPS.topk!
```

## Random numbers

```@docs
MPS.RNG
```

## Matrix and vector descriptors

`MPSMatrix` and `MPSVector` describe an `MtlArray` to the MPS kernels.

```@docs
MPS.MPSMatrix
MPS.MPSVector
```
