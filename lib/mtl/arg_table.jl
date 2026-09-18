#
# argument table descriptor
#

export MTL4ArgumentTable, MTL4ArgumentTableDescriptor

# @objcwrapper managed = true MTL4ArgumentTableDescriptor <: NSObject

function MTL4ArgumentTableDescriptor()
    return @objc [MTL4ArgumentTableDescriptor new]::MTL4ArgumentTableDescriptor
end


#
# argument table
#

# @objcwrapper managed = true MTL4ArgumentTable <: NSObject

"""
    MTL4ArgumentTable(device, desc::MTL4ArgumentTableDescriptor)

Create an argument table: the Metal 4 replacement for the per-encoder `setBuffer:`/
`setBytes:` binding state. Bindings are captured when a command is encoded, so a single
table can be rebound between dispatches on the same encoder.
"""
function MTL4ArgumentTable(device::MTLDevice, desc::MTL4ArgumentTableDescriptor)
    err = Ref{id{NSError}}(nil)
    argtab = @objc [device::id{MTLDevice} newArgumentTableWithDescriptor:desc::id{MTL4ArgumentTableDescriptor}
                                                                   error:err::Ptr{id{NSError}}]::Union{Nothing,MTL4ArgumentTable}
    argtab === nothing && throw_error(err[])
    return argtab
end

function MTL4ArgumentTable(device::MTLDevice; buffers::Integer=0, textures::Integer=0,
                           samplers::Integer=0, label=nothing)
    desc = MTL4ArgumentTableDescriptor()
    desc.maxBufferBindCount = buffers
    desc.maxTextureBindCount = textures
    desc.maxSamplerStateBindCount = samplers
    label === nothing || (desc.label = label)
    return MTL4ArgumentTable(device, desc)
end

# NOTE: binding indices are 1-based here, like `set_buffer!`/`set_bytes!` on a Metal 3
#       compute command encoder; they are lowered to Metal's 0-based `[[buffer(n)]]` slots.

"""
    set_address!(argtab::MTL4ArgumentTable, address, index)

Bind a raw GPU virtual address to the 1-based buffer binding `index`.
"""
function set_address!(argtab::MTL4ArgumentTable, address::Integer, index::Integer)
    @objc [argtab::id{MTL4ArgumentTable} setAddress:UInt64(address)::MTLGPUAddress
                                           atIndex:(index-1)::NSUInteger]::Nothing
end

"""
    set_address!(argtab::MTL4ArgumentTable, address, stride, index)

Bind a raw GPU virtual address with an explicit attribute stride. The table must have been
created with `supportAttributeStrides` enabled.
"""
function set_address!(argtab::MTL4ArgumentTable, address::Integer, stride::Integer,
                      index::Integer)
    @objc [argtab::id{MTL4ArgumentTable} setAddress:UInt64(address)::MTLGPUAddress
                                   attributeStride:stride::NSUInteger
                                           atIndex:(index-1)::NSUInteger]::Nothing
end

"""
    set_buffer!(argtab::MTL4ArgumentTable, buf::MTLBuffer, offset, index)

Bind `buf` (at a byte `offset`) to the 1-based buffer binding `index`.

Unlike Metal 3's `setBuffer:offset:atIndex:`, this binds the buffer's GPU address and does
*not* make it resident: the buffer must be covered by a residency set that is used by the
command buffer, or attached to the queue.
"""
function set_buffer!(argtab::MTL4ArgumentTable, buf::MTLBuffer, offset::Integer,
                     index::Integer)
    @inline set_address!(argtab, UInt64(buf.gpuAddress) + offset, index)
end

function set_resource!(argtab::MTL4ArgumentTable, resource::MTLResourceID, index::Integer)
    @objc [argtab::id{MTL4ArgumentTable} setResource:resource::MTLResourceID
                                        atBufferIndex:(index-1)::NSUInteger]::Nothing
end

function set_texture!(argtab::MTL4ArgumentTable, texture::MTLResourceID, index::Integer)
    @objc [argtab::id{MTL4ArgumentTable} setTexture:texture::MTLResourceID
                                           atIndex:(index-1)::NSUInteger]::Nothing
end
set_texture!(argtab::MTL4ArgumentTable, texture::MTLTexture, index::Integer) =
    set_texture!(argtab, texture.gpuResourceID, index)

function set_sampler_state!(argtab::MTL4ArgumentTable, sampler::MTLResourceID, index::Integer)
    @objc [argtab::id{MTL4ArgumentTable} setSamplerState:sampler::MTLResourceID
                                                atIndex:(index-1)::NSUInteger]::Nothing
end
set_sampler_state!(argtab::MTL4ArgumentTable, sampler::MTLSamplerState, index::Integer) =
    set_sampler_state!(argtab, sampler.gpuResourceID, index)
