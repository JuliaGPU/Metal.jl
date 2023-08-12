# Metal Performance Shaders

This section lists the package's public functionality that corresponds to the Metal
Performance Shaders functions. For more information about these functions, or to see
which functions have yet to be implemented in this package, please consult
the [Metal Performance Shaders Documentation](https://developer.apple.com/documentation/metalperformanceshaders?language=objc).

## Matrices and Vectors

```@docs
MPS.MPSMatrix
MPS.MPSVector
```

### Matrix Arithmetic Operators

```@docs
MPS.matmul!
MPS.matvecmul!
MPS.topk
MPS.topk!
```

### Linear Algebra

Many of the currently implemented MPS functions are for linear algebra operations.
Therefore, you use them by calling the corresponding LinearAlgebra function with an
`MtlArray`. They are nonetheless listed below:
