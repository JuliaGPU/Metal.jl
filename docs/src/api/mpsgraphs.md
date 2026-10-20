# Metal Performance Shaders Graph

`MPSGraphs` wraps Apple's [Metal Performance Shaders Graph](https://developer.apple.com/documentation/metalperformanceshadersgraph)
framework. The operations below build, cache and execute graphs on `MtlArray`s. Metal.jl
uses them to implement operations such as `mul!`, `sort!` and `accumulate!`; you can also
call them directly.

All operations write their result into a preallocated output array. Only the matrix
multiplications read it, to add `β` times its previous contents. They execute asynchronously, ordered with the other work submitted
from the current task (kernels, copies, and other MPS or MPSGraph operations), so no
synchronization is needed between them. Arrays may be views at an offset into their
buffer, like contiguous `view`s of an `MtlArray`.

Use [`MPSGraphs.supports`](@ref) to check a call before choosing an implementation:

```julia
using Metal
using Metal: MPSGraphs

A = MtlArray(rand(Float32, 512, 1000))
R = similar(A, 1, 1000)
if MPSGraphs.supports(MPSGraphs.reduce!, +, R, A)
    MPSGraphs.reduce!(+, R, A)
else
    sum!(R, A)
end
```

```@docs
Metal.MPSGraphs
MPSGraphs.supports
```

## Reductions and scans

```@docs
MPSGraphs.reduce!
MPSGraphs.accumulate!
```

## Sorting

```@docs
MPSGraphs.sort!
MPSGraphs.sortperm!
```

## Matrix multiplication

```@docs
MPSGraphs.matmul!
MPSGraphs.matvecmul!
MPSGraphs.MPSGRAPH_VALID_MATMUL_TYPES
MPSGraphs.MPSGRAPH_VALID_MATVECMUL_TYPES
```

## Neural network operations

```@docs
MPSGraphs.softmax!
MPSGraphs.logsoftmax!
MPSGraphs.softmax_grad!
MPSGraphs.logsoftmax_grad!
MPSGraphs.conv!
MPSGraphs.conv_data_grad!
MPSGraphs.conv_filter_grad!
MPSGraphs.maxpool!
MPSGraphs.maxpool_grad!
MPSGraphs.meanpool!
MPSGraphs.meanpool_grad!
```
