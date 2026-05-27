# support for device-side exceptions

## exception type

struct KernelException <: Exception
    dev::MTLDevice
    # the device name is captured as a plain `String` (eagerly, when the mailbox is allocated;
    # see `exception_flag_buffer`) rather than read from `dev` on demand: `showerror` may run
    # long after the throw — e.g. when `Test` formats the error — on a task without an autorelease
    # pool, and reading `dev.name` (an ObjC message) in that state faults. so the throw/display
    # path must never touch ObjC.
    dev_name::String
end

function Base.showerror(io::IO, err::KernelException)
    print(io, "KernelException: exception thrown during kernel execution on device $(err.dev_name)")
end


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: a single `UInt32` in a
# shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the `KernelState`
# (see `device/runtime.jl`). a throwing kernel atomically sets it instead of trapping (which
# would wedge the GPU, JuliaGPU/Metal.jl#433); the host reads it after synchronizing.
#
# one mailbox per device, allocated lazily and reused across launches.

# we keep the `MTLBuffer` alive (the GPU writes it via its address) and cache, once at
# allocation: its host-side `contents` pointer (so the hot `check_exceptions` path is a plain
# load rather than an ObjC message send on every synchronize) and the device `name` (so the
# throw/display path never has to message `dev`; see `KernelException`).
const device_exception_flags = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{UInt32}, String}}()
const device_exception_lock = ReentrantLock()

function exception_flag_buffer(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _, _ = get!(device_exception_flags, dev) do
            @autoreleasepool begin
                buf = MTLBuffer(dev, sizeof(UInt32); storage=SharedStorage)
                ptr = convert(Ptr{UInt32}, MTL.contents(buf))
                unsafe_store!(ptr, UInt32(0))
                (buf, ptr, String(dev.name))
            end
        end
        return buf
    end
end

# check the exception flags of all devices, rethrowing host-side if one was set. called after
# synchronizing, mirroring how CUDA.jl/AMDGPU.jl surface device exceptions.
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (buf, ptr, name)) in device_exception_flags
            if unsafe_load(ptr) != 0
                # reset so the next launch starts clean
                unsafe_store!(ptr, UInt32(0))
                throw(KernelException(dev, name))
            end
        end
    end
    return
end
