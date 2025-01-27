## Constructors for structs defined in automatically-generated wrappers in libmtl.jl

export MTLSize

MTLSize() = MTLSize(1, 1, 1)
MTLSize(w) = MTLSize(w, 1, 1)
MTLSize(w, h) = MTLSize(w, h, 1)

# convenience constructors from tuple inputs
MTLSize(dims::NTuple{1,Integer}) = MTLSize(dims[1], 1,       1)
MTLSize(dims::NTuple{2,Integer}) = MTLSize(dims[1], dims[2], 1)
MTLSize(dims::NTuple{3,Integer}) = MTLSize(dims[1], dims[2], dims[3])


## origin

export MTLOrigin

MTLOrigin() = MTLOrigin(0, 0, 0)
MTLOrigin(x) = MTLOrigin(x, 0, 0)
MTLOrigin(x, y) = MTLOrigin(x, y, 0)


## region

export MTLRegion

MTLRegion() = MTLRegion(MTLOrigin(), MTLSize())
MTLRegion(origin) = MTLRegion(origin, MTLSize())
