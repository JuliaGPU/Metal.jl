
mutable struct MetalBufferRC{T}
    buf::MetalBuffer{T}

    freed::Bool
    refcount::Int
end

function alloc_refcount(args...; kwargs...)
    buf = alloc(args...; kwargs...)
    self = MetalBufferRC(buf, false, 0)
end

@inline function retain(a::MetalBufferRC)
  a.refcount += 1
  return
end

@inline function release(a::MetalBufferRC)
  a.refcount -= 1
  return a.refcount == 0
end

function unsafe_free!(xs::MetalBufferRC)
  # this call should only have an effect once, becuase both the user and the GC can call it
  xs.freed && return
  _unsafe_free!(xs)
  xs.freed = true
  return
end

function _unsafe_free!(xs::CuArray)
  @assert xs.refcount >= 0
  if release(xs)
    free(xs.buf)
  end
  return
end
