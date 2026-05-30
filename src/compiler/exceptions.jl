# support for device-side exceptions

## exception type

struct KernelException <: Exception
    dev::MTLDevice
    name::String
    reason::String
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}
end

function Base.showerror(io::IO, err::KernelException)
    name = isempty(err.name) ? "exception" : err.name
    article = first(uppercase(name)) in ('A', 'E', 'I', 'O', 'U') ? "An" : "A"
    thread = join(Int.(err.thread), '×')
    threadgroup = join(Int.(err.threadgroup), '×')
    print(io, "KernelException: $article $name was thrown by thread $thread ",
              "in threadgroup $threadgroup on device $(String(err.dev.name))")
    isempty(err.reason) || print(io, ": ", err.reason)
end

# decode a null-terminated mailbox text buffer into a `String`
function exception_string(bytes::NTuple{N, UInt8}) where {N}
    len = something(findfirst(iszero, bytes), N + 1) - 1
    return String(UInt8[bytes[i] for i in 1:len])
end


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: an `ExceptionInfo_st`
# in a shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the
# `KernelState`. see `device/runtime.jl` for the layout and how the GPU fills it.
const device_exception_info = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{ExceptionInfo_st}}}()
const device_exception_lock = ReentrantLock()

function exception_info_buffer(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _ = get!(device_exception_info, dev) do
            # `newBufferWithLength:` (a `new*` method) returns retain-count-1, non-autoreleased
            # per Apple's ARC naming convention, so the buffer survives the pool drain. the
            # pool is here to catch any intermediates the alloc call autoreleases internally.
            @autoreleasepool begin
                buf = MTLBuffer(dev, sizeof(ExceptionInfo_st); storage=SharedStorage)
                ptr = convert(Ptr{ExceptionInfo_st}, MTL.contents(buf))
                unsafe_store!(ptr, ExceptionInfo_st())
                (buf, ptr)
            end
        end
        return buf
    end
end

# check the exception mailbox of all devices, rethrowing host-side if one was set.
# the caller is responsible for running inside an autorelease pool (`synchronize` is).
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (_, ptr)) in device_exception_info
            status_ptr = convert(Ptr{Int32}, ptr)
            # atomic read-and-clear of `status` so concurrent `synchronize`s on the same
            # device can't both observe the set flag and throw duplicate exceptions, nor
            # race the load against the clear and swallow it.
            if unsafe_swap!(status_ptr, Int32(0), :sequentially_consistent) != 0
                info = unsafe_load(ptr)
                exc = KernelException(dev, exception_string(info.name),
                                      exception_string(info.reason),
                                      info.thread, info.threadgroup)
                # clear the lock and payload so the mailbox is reusable
                unsafe_store!(ptr, ExceptionInfo_st())
                throw(exc)
            end
        end
    end
    return
end
