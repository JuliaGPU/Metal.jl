
## size

export MPSSize # (defined in libmps.jl)

# convenience constructors from tuple inputs
MPSSize(dims::NTuple{1,<:Real}) = MPSSize(dims[1], 1.0,     1.0)
MPSSize(dims::NTuple{2,<:Real}) = MPSSize(dims[1], dims[2], 1.0)
MPSSize(dims::NTuple{3,<:Real}) = MPSSize(dims[1], dims[2], dims[3])


## origin

export MPSOrigin # (defined in libmps.jl)
