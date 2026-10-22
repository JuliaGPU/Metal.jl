## descriptor

export MPSMatrixDescriptor

# @objcwrapper MPSMatrixDescriptor <: NSObject

function MPSMatrixDescriptor(rows, columns, rowBytes, dataType)
    return @objc [MPSMatrixDescriptor matrixDescriptorWithRows:rows::NSUInteger
                                      columns:columns::NSUInteger
                                      rowBytes:rowBytes::NSUInteger
                                      dataType:dataType::MPSDataType]::MPSMatrixDescriptor
end

function MPSMatrixDescriptor(rows, columns, matrices, rowBytes, matrixBytes, dataType)
    return @objc [MPSMatrixDescriptor matrixDescriptorWithRows:rows::NSUInteger
                                      columns:columns::NSUInteger
                                      matrices:matrices::NSUInteger
                                      rowBytes:rowBytes::NSUInteger
                                      matrixBytes:matrixBytes::NSUInteger
                                      dataType:dataType::MPSDataType]::MPSMatrixDescriptor
end


## high-level object

export MPSMatrix

# @objcwrapper managed = true MPSMatrix <: NSObject

function MPSMatrix(buf, descriptor::MPSMatrixDescriptor, offset::Integer=0)
    return @objc [[MPSMatrix alloc]::id{MPSMatrix} initWithBuffer:buf::id{MTLBuffer}
                                             offset:offset::NSUInteger
                                             descriptor:descriptor::id{MPSMatrixDescriptor}]::MPSMatrix
end

function MPSMatrix(dev::MTLDevice, descriptor::MPSMatrixDescriptor)
    return @objc [[MPSMatrix alloc]::id{MPSMatrix} initWithDevice:dev::id{MTLDevice}
                                             descriptor:descriptor::id{MPSMatrixDescriptor}]::MPSMatrix
end

"""
    MPSMatrix(mat::MtlMatrix)

Metal matrix representation used in Performance Shaders.

Note that this results in a transposed view of the input,
as Metal stores matrices row-major instead of column-major.
"""
function MPSMatrix(mat::MtlMatrix{T}) where T
    n_cols, n_rows = size(mat)
    desc = MPSMatrixDescriptor(n_rows, n_cols, sizeof(T)*n_cols, T)
    return MPSMatrix(mat, desc, mat.offset)
end

"""
    MPSMatrix(vec::MtlVector)

Metal matrix representation used in Performance Shaders.

Note that this results in a transposed view of the input,
as Metal stores matrices row-major instead of column-major.
"""
function MPSMatrix(vec::MtlVector{T}) where T
    n_cols, n_rows = length(vec), 1
    desc = MPSMatrixDescriptor(n_rows, n_cols, sizeof(T)*n_cols, T)
    return MPSMatrix(vec, desc, vec.offset)
end

"""
    MPSMatrix(arr::MtlArray{T,3})

Metal batched matrix representation used in Performance Shaders.

Note that this results in a transposed view of the input,
as Metal stores matrices row-major instead of column-major.
"""
function MPSMatrix(arr::MtlArray{T,3}) where T
    n_cols, n_rows, n_matrices = size(arr)
    row_bytes = sizeof(T)*n_cols
    desc = MPSMatrixDescriptor(n_rows, n_cols, n_matrices, row_bytes, row_bytes * n_rows, T)
    return MPSMatrix(arr, desc, arr.offset)
end

function Base.size(mat::MPS.MPSMatrix)
    if mat.matrices > 1
        return Int.((mat.matrices, mat.rows, mat.columns))
    else
        return Int.((mat.rows, mat.columns))
    end
end

## matrix multiplication

export MPSMatrixMultiplication, encode!, matmul!

# @objcwrapper managed = true MPSMatrixMultiplication <: MPSKernel

function MPSMatrixMultiplication(dev, transposeLeft, transposeRight, resultRows,
                                 resultColumns, interiorColumns, alpha, beta)
    return @objc [[MPSMatrixMultiplication alloc]::id{MPSMatrixMultiplication} initWithDevice:dev::id{MTLDevice}
                                                                         transposeLeft:transposeLeft::Bool
                                                                         transposeRight:transposeRight::Bool
                                                                         resultRows:resultRows::NSUInteger
                                                                         resultColumns:resultColumns::NSUInteger
                                                                         interiorColumns:interiorColumns::NSUInteger
                                                                         alpha:alpha::Cdouble
                                                                         beta:beta::Cdouble]::MPSMatrixMultiplication
end

function encode!(cmdbuf::MTLCommandBufferLike, matmul::MPSMatrixMultiplicationLike, left, right, result)
    @objc [matmul::id{MPSMatrixMultiplication} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                               leftMatrix:left::id{MPSMatrix}
                                               rightMatrix:right::id{MPSMatrix}
                                               resultMatrix:result::id{MPSMatrix}]::Nothing
end

# MPS supports real element types only, for which the adjoint is the transpose
function mps_transpose(t::AbstractChar)
    t == 'N' && return false
    (t == 'T' || t == 'C') && return true
    throw(ArgumentError("transpose flag must be 'N', 'T' or 'C', got '$t'"))
end

"""
    MPS.matmul!(C, A, B, α=true, β=false; tA='N', tB='N') -> C

Compute `C = α * opA(A) * opB(B) + β * C` using `MPSMatrixMultiplication`, where `opA`
and `opB` are the identity (`'N'`) or the transpose (`'T'` or `'C'`), as selected by `tA`
and `tB`.

`A`, `B` and `C` are `MtlArray` matrices, or 3D arrays holding equally many matrices along
the last dimension. Their element types are one of the combinations in
`MPS.MPS_VALID_MATMUL_TYPES`. The multiplication executes asynchronously, ordered with the
other work submitted from the current task.

`LinearAlgebra.mul!` selects between this, [`Metal.MPSGraphs.matmul!`](@ref) and Metal.jl's own
kernels; use this function to select MPS explicitly.
"""
function matmul!(c::MtlArray{T1,N}, a::MtlArray{T2,N}, b::MtlArray{T3,N},
                 alpha::Number=true, beta::Number=false;
                 tA::AbstractChar='N', tB::AbstractChar='N') where {T1, T2, T3, N}
    transpose_a = mps_transpose(tA)
    transpose_b = mps_transpose(tB)
    # NOTE: MPS uses row major, while Julia is col-major. Instead of transposing
    #       the inputs (by passing !transpose_[ab]) and afterwards transposing
    #       the output, we use the property that (AB)ᵀ = BᵀAᵀ
    cols_a = size(a, transpose_a ? 1 : 2)
    cols_c, rows_c = size(c)

    # Create MPS-compatible matrix from the MtlArrays
    mps_a = MPSMatrix(a)
    mps_b = MPSMatrix(b)
    mps_c = MPSMatrix(c)

    mat_mul_kernel = MPSMatrixMultiplication(device(),
                                             transpose_b, transpose_a,
                                             rows_c, cols_c, cols_a,
                                             alpha, beta)


    # Encode and commit matmul kernel
    cmdbuf = MTLCommandBuffer(global_queue(device()))
    encode!(cmdbuf, mat_mul_kernel, mps_b, mps_a, mps_c)
    commit!(cmdbuf)

    return c
end

function matmul!(c::MtlArray, a::MtlArray, b::MtlArray, alpha::Number, beta::Number,
                 transpose_a::Bool, transpose_b::Bool=false)
    Base.depwarn("`MPS.matmul!(c, a, b, α, β, transpose_a::Bool, transpose_b::Bool)` is deprecated, use `MPS.matmul!(c, a, b, α, β; tA, tB)` with 'N' or 'T' instead.",
                 :matmul!)
    return matmul!(c, a, b, alpha, beta; tA=transpose_a ? 'T' : 'N',
                   tB=transpose_b ? 'T' : 'N')
end


## topk

export MPSMatrixFindTopK, encode!

# @objcwrapper managed = true MPSMatrixFindTopK <: MPSMatrixUnaryKernel

function MPSMatrixFindTopK(dev, numberOfTopKValues)
    return @objc [[MPSMatrixFindTopK alloc]::id{MPSMatrixFindTopK} initWithDevice:dev::id{MTLDevice}
                                                             numberOfTopKValues:numberOfTopKValues::NSUInteger]::MPSMatrixFindTopK
end

function encode!(cmdbuf::MTLCommandBufferLike, kernel::MPSMatrixFindTopKLike, inputMatrix, resultIndexMatrix, resultValueMatrix)
    @objc [kernel::id{MPSMatrixFindTopK} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                                      inputMatrix:inputMatrix::id{MPSMatrix}
                                                      resultIndexMatrix:resultIndexMatrix::id{MPSMatrix}
                                                      resultValueMatrix:resultValueMatrix::id{MPSMatrix}]::Nothing
end

"""
    MPS.topk!(A::MtlMatrix{T}, I::MtlMatrix{UInt32}, V::MtlMatrix{T}, k) -> (I, V)

Find the `k` largest values in each column of `A`, with `T` `Float32` or `Float16`, using
[`MPSMatrixFindTopK`](https://developer.apple.com/documentation/metalperformanceshaders/mpsmatrixfindtopk).
Write their 1-based row indices to the first `k` rows of `I`, and the values to those of
`V`, in descending order. `k` can be at most 16. This interface is experimental, and might
change without deprecation.

See also [`MPS.topk`](@ref).
"""
function topk!(A::MtlMatrix{T}, I::MtlMatrix{UInt32}, V::MtlMatrix{T}, k) where {T<:MtlFloat}
    size(I,1) >= k         || throw(ArgumentError("Matrix 'I' must be large enough for k rows"))
    size(I,2) >= size(A,2) || throw(ArgumentError("Matrix 'I' must have at least as many columns as A"))
    size(V,1) >= k         || throw(ArgumentError("Matrix 'V' must be large enough for k rows"))
    size(V,2) >= size(A,2) || throw(ArgumentError("Matrix 'V' must have at least as many columns as A"))

    return _topk!(A,I,V,k)
end
@inline function _topk!(A::MtlMatrix{T}, I::MtlMatrix{UInt32}, V::MtlMatrix{T}, k) where {T<:MtlFloat}
    size(A,1) >= k || throw(ArgumentError("Matrix 'A' must must have more rows than k"))
    k <= 16        || throw(ArgumentError("MPSMatrixFindTopK does not support values of k > 16"))

    # Create MPS-compatible matrix from the MtlArrays
    mps_a = MPSMatrix(A)
    mps_i = MPSMatrix(I)
    mps_v = MPSMatrix(V)

    topk_kernel = MPSMatrixFindTopK(device(), k)
    topk_kernel.indexOffset = 1

    # Encode and commit topk kernel
    cmdbuf = MTLCommandBuffer(global_queue(device()))
    encode!(cmdbuf, topk_kernel, mps_a, mps_i, mps_v)
    commit!(cmdbuf)

    return I, V
end

"""
    MPS.topk(A::MtlMatrix{T}, k) -> (I, V)

Like [`MPS.topk!`](@ref), but return new `k`-row matrices of indices `I` and values `V`.

```julia
julia> A = MtlArray(Float32[1 6; 4 5; 2 9]);

julia> I, V = MPS.topk(A, 2);

julia> Array(I)
2×2 Matrix{UInt32}:
 0x00000002  0x00000003
 0x00000003  0x00000001

julia> Array(V)
2×2 Matrix{Float32}:
 4.0  9.0
 2.0  6.0
```
"""
function topk(A::MtlMatrix{T,S}, k) where {T<:MtlFloat,S}
    s = (k,size(A,2))
    I = MtlMatrix{UInt32,S}(undef, s)
    V = MtlMatrix{T,S}(undef, s)

    return _topk!(A, I, V, k)
end


## softmax

export MPSMatrixSoftMax, MPSMatrixLogSoftMax, encode!

# @objcwrapper managed = true MPSMatrixSoftMax <: MPSMatrixUnaryKernel
# @objcwrapper managed = true MPSMatrixLogSoftMax <: MPSMatrixSoftMax

for f in (:MPSMatrixSoftMax, :MPSMatrixLogSoftMax)
    fLike = Symbol(f, :Like)
    @eval begin
        function $(f)(dev)
            return @objc [[$(f) alloc]::id{$(f)} initWithDevice:dev::id{MTLDevice}]::$(f)
        end

        function encode!(cmdbuf::MTLCommandBufferLike, kernel::$(fLike), inputMatrix, resultMatrix)
            @objc [kernel::id{$(f)} encodeToCommandBuffer:cmdbuf::id{MTLCommandBuffer}
                                    inputMatrix:inputMatrix::id{MPSMatrix}
                                    resultMatrix:resultMatrix::id{MPSMatrix}]::Nothing
        end
    end
end
