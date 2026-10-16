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

# throw the error reported through an `error:` out-parameter of a failed call
throw_error(err::Out{NSError}) = throw(something(err[], ErrorException("Metal call failed")))

# The Metal 4 API exists on macOS 26 and later. Check before creating its objects: the
# wrappers' own availability is decided when Metal.jl is precompiled, which goes stale when
# the OS is upgraded, and older systems raise an Objective-C exception on the selectors.
const metal4_availability = PlatformAvailability(:macos, v"26")
function check_metal4(name::Symbol)
    ObjectiveC.is_available(metal4_availability) ||
        throw(UnavailableError(name, metal4_availability))
    return
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
include("command_queue4.jl")
include("command_buf.jl")
include("command_buf4.jl")
include("compute_pipeline.jl")
include("command_enc.jl")
include("command_alloc4.jl")
include("command_enc4.jl")
include("arg_table.jl")
include("command_enc/blit.jl")
include("command_enc/compute.jl")
include("command_enc/compute4.jl")
include("binary_archive.jl")
include("capture.jl")
include("texture.jl")

end # module
