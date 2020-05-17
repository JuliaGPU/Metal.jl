export MtlDim

const MTLDim = MtSize
"""
    CuDim3(x)

    CuDim3((x,))
    CuDim3((x, y))
    CuDim3((x, y, x))

A type used to specify dimensions, consisting of 3 integers for respectively the `x`, `y`
and `z` dimension. Unspecified dimensions default to `1`.

Often accepted as argument through the `CuDim` type alias, eg. in the case of
[`cudacall`](@ref) or [`launch`](@ref), allowing to pass dimensions as a plain integer or a
tuple without having to construct an explicit `CuDim3` object.
"""
#=struct MtlDim3
    x::NsUInteger
    y::NsUInteger
    z::NsUInteger
end
=#
const MtlDim3 = MTLDim

MtlDim3(dims::Integer)             = MtlDim3(dims,    NsUInteger(1), NsUInteger(1))
MtlDim3(dims::NTuple{1,<:Integer}) = MtlDim3(dims[1], NsUInteger(1), NsUInteger(1))
MtlDim3(dims::NTuple{2,<:Integer}) = MtlDim3(dims[1], dims[2],       NsUInteger(1))
MtlDim3(dims::NTuple{3,<:Integer}) = MtlDim3(dims[1], dims[2],       dims[3])

# Type alias for conveniently specifying the dimensions
# (e.g. `(len, 2)` instead of `CuDim3((len, 2))`)
const MtlDim = Union{Integer,
                     Tuple{Integer},
                     Tuple{Integer, Integer},
                     Tuple{Integer, Integer, Integer}}
