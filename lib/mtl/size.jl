## size

export MTLSize

struct MTLSize
    width::NSUInteger
    height::NSUInteger
    depth::NSUInteger

    MTLSize(w=1, h=1, d=1) = new(w, h, d)
end

# convenience constructors from tuple inputs
MTLSize(dims::NTuple{1,<:Integer}) = MTLSize(dims[1], 1,       1)
MTLSize(dims::NTuple{2,<:Integer}) = MTLSize(dims[1], dims[2], 1)
MTLSize(dims::NTuple{3,<:Integer}) = MTLSize(dims[1], dims[2], dims[3])


## origin

export MTLOrigin

struct MTLOrigin
    x::NSUInteger
    y::NSUInteger
    z::NSUInteger

    MTLOrigin(x=0, y=0, z=0) = new(x, y, z)
end

## region

export MTLRegion

struct MTLRegion
    origin::MTLOrigin # The top-left corner of the region
    size::MTLSize # The size of the region

    MTLRegion(x=0, y=0, z=0) = new(x, y, z)
end
