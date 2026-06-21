"""
# MTL

`MTL` is where the Metal API wrappers are defined.

Not all functionality is currently implemented or documented. For further details,
refer to the [official Apple documentation](https://developer.apple.com/documentation/metal).
"""
module MTL

using CEnum
using GPUToolbox: @memoize
using ObjectiveC, .Foundation, .Dispatch

using ..Metal

# Import the bindings that are not used in MTL for backward compatibility
import ..Metal: StorageMode, SharedStorage, ManagedStorage, PrivateStorage, Memoryless, CPUStorage

function throw_error(err::id{NSError})
    # NSError arrives through an `error:` out-parameter, not as an Objective-C
    # return value, so nullable ARC return handling cannot retain it for us.
    throw(retain(NSError, err))
end


## source code includes

include("libmtl.jl")
include("size.jl")
include("device.jl")
include("resource.jl")
include("storage_type.jl")
include("compile_opts.jl")
include("library.jl")
include("function.jl")
include("events.jl")
include("fences.jl")
include("heap.jl")
include("buffer.jl")
include("log_state.jl")
include("residency_set.jl")
include("command_queue.jl")
include("command_buf.jl")
include("compute_pipeline.jl")
include("command_enc.jl")
include("command_enc/blit.jl")
include("command_enc/compute.jl")
include("binary_archive.jl")
include("capture.jl")
include("texture.jl")

end # module
