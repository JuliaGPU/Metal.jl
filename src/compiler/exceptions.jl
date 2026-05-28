# support for device-side exceptions

## exception type

struct KernelException <: Exception
    dev::MTLDevice
end

Base.showerror(io::IO, err::KernelException) =
    print(io, "KernelException: exception thrown during kernel execution on device $(String(err.dev.name))")


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: a single `UInt32` in a
# shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the `KernelState`
# (see `device/runtime.jl`).
const device_exception_flags = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{UInt32}}}()
const device_exception_lock = ReentrantLock()

function exception_flag_buffer(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _ = get!(device_exception_flags, dev) do
            # `newBufferWithLength:` (a `new*` method) returns retain-count-1, non-autoreleased
            # per Apple's ARC naming convention, so the buffer survives the pool drain. the
            # pool is here to catch any intermediates the alloc call autoreleases internally.
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
# the caller is responsible for running inside an autorelease pool (`synchronize` is).
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (_, ptr)) in device_exception_flags
            # atomic read-and-clear so concurrent `synchronize`s on the same device
            # can't both observe the set flag and throw duplicate exceptions, nor
            # race the load against the clear and swallow it.
            if unsafe_swap!(ptr, UInt32(0), :sequentially_consistent) != 0
                throw(KernelException(dev))
            end
        end
    end
    return
end
