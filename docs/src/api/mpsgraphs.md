# Metal Performance Shaders Graph

`MPSGraphs` wraps Apple's [Metal Performance Shaders Graph](https://developer.apple.com/documentation/metalperformanceshadersgraph)
framework. Besides the low-level graph-building API, it provides operations on `MtlArray`s
that build, cache and execute a graph for you. Metal.jl uses some of these to implement
`mul!`, `sort!` and `accumulate!`; they are also available for direct use, e.g. by
packages that select an implementation per operation.

All operations write their result into a preallocated output array, which is overwritten
rather than added to. They execute asynchronously, ordered with the other work submitted
from the current task (kernels, copies, and other MPS or MPSGraph operations), so no
synchronization is needed between them. Arrays may be views at an offset into their
buffer, like contiguous `view`s of an `MtlArray`.

Each operation documents which arguments it supports. [`MPSGraphs.supports`](@ref) checks
whether a call is supported without executing it, which avoids duplicating these
requirements when choosing between MPSGraph and another implementation:

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
