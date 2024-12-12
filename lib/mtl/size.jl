## size

export MTLSize # (defined in libmtl.jl)

# convenience constructors from tuple inputs
MTLSize(dims::NTuple{1,Integer}) = MTLSize(dims[1], 1,       1)
MTLSize(dims::NTuple{2,Integer}) = MTLSize(dims[1], dims[2], 1)
MTLSize(dims::NTuple{3,Integer}) = MTLSize(dims[1], dims[2], dims[3])


## origin

export MTLOrigin # (defined in libmtl.jl)

## region

export MTLRegion # (defined in libmtl.jl)
