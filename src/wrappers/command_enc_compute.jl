export
	MtlComputeCommandEncoder, set!, setbuffer!, dispatchThreads!, endEncoding!

const MTLComputeCommandEncoder = Ptr{MtComputeCommandEncoder}

mutable struct MtlComputeCommandEncoder <: MtlCommandEncoder
	handle::MTLComputeCommandEncoder
	cmdbuf::MtlCommandBuffer
end

Base.convert(::Type{MTLComputeCommandEncoder}, q::MtlComputeCommandEncoder) = q.handle
Base.unsafe_convert(::Type{MTLComputeCommandEncoder}, q::MtlComputeCommandEncoder) = convert(MTLComputeCommandEncoder, q.handle)

function MtlComputeCommandEncoder(cmdbuf::MtlCommandBuffer; dispatch_type::Union{Nothing,MtDispatchType}=nothing)
	if isnothing(dispatch_type)
		handle = mtNewComputeCommandEncoder(cmdbuf)
	else
		handle = mtNewComputeCommandEncoderWithDispatchtype(cmdbuf, dispatchtype)
	end
	obj = MtlComputeCommandEncoder(handle, cmdbuf)
	finalizer(unsafe_destroy!, obj)
	return obj
end

set!(cce::MtlComputeCommandEncoder, pip::MtlComputePipelineState) =
	mtComputeCommandEncoderSetComputePipelineState(cce, pip)

setbuffer!(cce::MtlComputeCommandEncoder, buf::MtlBuffer, offset::Integer, index::Integer) =
	mtComputeCommandEncoderSetBufferOffsetAtIndex(cce, buf, offset, index)

dispatchThreads!(cce::MtlComputeCommandEncoder, gridSize::MtSize, threadGroupSize::MtSize) =
	mtComputeCommandEncoderDispatchThreadgroups_threadsPerThreadgroup(cce, gridSize, threadGroupSize)

endEncoding!(cce::MtlComputeCommandEncoder) = mtComputeCommandEncoderEndEncoding(cce);
