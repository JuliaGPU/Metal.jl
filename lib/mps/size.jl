## size

export MPSSize

struct MPSSize
    width::Float64
    height::Float64
    depth::Float64

    MPSSize(w=1.0, h=1.0, d=1.0) = new(w, h, d)
end

# convenience constructors from tuple inputs
MPSSize(dims::NTuple{1,<:Real}) = MPSSize(dims[1], 1.0,     1.0)
MPSSize(dims::NTuple{2,<:Real}) = MPSSize(dims[1], dims[2], 1.0)
MPSSize(dims::NTuple{3,<:Real}) = MPSSize(dims[1], dims[2], dims[3])


## origin

export MPSOrigin

struct MPSOrigin
    x::Float64
    y::Float64
    z::Float64

    MPSOrigin(x=0, y=0, z=0) = new(x, y, z)
end
