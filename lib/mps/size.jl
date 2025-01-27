## Constructors for structs defined in automatically-generated wrappers in libmps.jl

export MPSOffset

MPSOffset() = MPSOffset(0, 0, 0)
MPSOffset(x) = MPSOffset(x, 0, 0)
MPSOffset(x, y) = MPSOffset(x, y, 0)


export MPSSize

MPSSize() = MPSSize(1.0, 1.0, 1.0)
MPSSize(w) = MPSSize(w, 1.0, 1.0)
MPSSize(w, h) = MPSSize(w, h, 1.0)

# convenience constructors from tuple inputs
MPSSize(dims::NTuple{1,<:Real}) = MPSSize(dims[1], 1.0,     1.0)
MPSSize(dims::NTuple{2,<:Real}) = MPSSize(dims[1], dims[2], 1.0)
MPSSize(dims::NTuple{3,<:Real}) = MPSSize(dims[1], dims[2], dims[3])


export MPSOrigin

MPSOrigin() = MPSOrigin(0.0, 0.0, 0.0)
MPSOrigin(x) = MPSOrigin(x, 0.0, 0.0)
MPSOrigin(x, y) = MPSOrigin(x, y, 0.0)


export MPSRegion

MPSRegion() = MPSRegion(MPSOrigin(), MPSSize())
MPSRegion(origin) = MPSRegion(origin, MPSSize())
