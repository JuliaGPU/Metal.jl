struct MPSOffset
    x::NSInteger
    y::NSInteger
    z::NSInteger

    MPSOffset(x=0, y=0, z=0) = new(x, y, z)
end

@cenum MPSImageEdgeMode::NSUInteger begin
    MPSImageEdgeModeZero           = 0
    MPSImageEdgeModeClamp          = 1
    MPSImageEdgeModeMirror         = 2
    MPSImageEdgeModeMirrorWithEdge = 3
    MPSImageEdgeModeConstant       = 4
end

@objcwrapper immutable=false MPSUnaryImageKernel <: MPSKernel

@objcproperties MPSUnaryImageKernel begin
    @autoproperty offset::MPSOffset
    @autoproperty clipRect::MTLRegion
    @autoproperty edgeMode::MPSImageEdgeMode
end

@objcwrapper immutable=false MPSBinarImageyKernel <: MPSKernel

@objcproperties MPSBinaryImageKernel begin
    @autoproperty primaryOffset::MPSOffset
    @autoproperty secondaryOffset::MPSOffset
    @autoproperty primaryEdgeMode::MPSImageEdgeMode
    @autoproperty secondaryEdgeMode::MPSImageEdgeMode
    @autoproperty clipRect::MTLRegion
end
