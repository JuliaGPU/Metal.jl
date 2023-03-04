## sizes

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

# backwards compatibility with cmt
Base.convert(::Type{MtSize}, sz::MTLSize) = MtSize(sz.width, sz.height, sz.depth)


## ranges

# convert from 1 based indexing to 0 based indexing
Base.convert(::Type{NsRange}, range::UnitRange{T}) where T <: Integer =
	NsRange(first(range), length(range))
# used for byte ranges.
Base.convert(::Type{NsRange}, range::StepRange{T}) where T <: Integer =
	NsRange(first(range)-step(range), length(range)*step(range))
