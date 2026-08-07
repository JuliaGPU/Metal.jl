export MtlSparseVector, MtlSparseMatrixCSC, MtlSparseMatrixCSR

import LinearAlgebra
using LinearAlgebra: Adjoint, Transpose
using SparseArrays
using KernelAbstractions: @index

include("sparse/types.jl")
include("sparse/conversions.jl")
include("sparse/adapt.jl")
include("sparse/gpuarrays.jl")
include("sparse/multiplication.jl")
