# support for device-side exceptions

## exception type

struct KernelException <: Exception
    dev_name::String    # captured to avoid crashes when accessing ObjC state
end

function Base.showerror(io::IO, err::KernelException)
    print(io, "KernelException: exception thrown during kernel execution on device $(err.dev_name)")
end


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: a single `UInt32` in a
# shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the `KernelState`
# (see `device/runtime.jl`).
const device_exception_flags = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{UInt32}}}()
const device_exception_lock = ReentrantLock()

function exception_flag_buffer(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _ = get!(device_exception_flags, dev) do
            @autoreleasepool begin
                buf = MTLBuffer(dev, sizeof(UInt32); storage=SharedStorage)
                ptr = convert(Ptr{UInt32}, MTL.contents(buf))
                unsafe_store!(ptr, UInt32(0))
                (buf, ptr)
            end
        end
        return buf
    end
end

# check the exception flags of all devices, rethrowing host-side if one was set.
# the caller is responsible for running inside an autorelease pool.
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (_, ptr)) in device_exception_flags
            if unsafe_load(ptr) != 0
                # reset so the next launch starts clean
                unsafe_store!(ptr, UInt32(0))
                throw(KernelException(String(dev.name)))
            end
        end
    end
    return
end
