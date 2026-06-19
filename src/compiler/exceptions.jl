# support for device-side exceptions

## exception type

struct KernelException <: Exception
    dev::MTLDevice
    name::String
    reason::String
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}
    backtrace::Vector{Tuple{String, String, Int}}   # (function, file, line) per frame
end

# the device writes only as much as the debug level asks for, leaving everything else at its
# zero/empty sentinel; render each field iff it isn't a sentinel, so the host never needs to
# know the debug level. positions are 1-based, so `(0, 0, 0)` means "not recorded".
function Base.showerror(io::IO, err::KernelException)
    name = isempty(err.name) ? "exception" : err.name
    article = first(uppercase(name)) in ('A', 'E', 'I', 'O', 'U') ? "An" : "A"
    print(io, "KernelException: $article $name was thrown")
    if err.thread != (0, 0, 0)
        thread = join(Int.(err.thread), '×')
        threadgroup = join(Int.(err.threadgroup), '×')
        print(io, " by thread $thread in threadgroup $threadgroup")
    end
    print(io, " on device $(String(err.dev.name))")
    isempty(err.reason) || print(io, ": ", err.reason)
    if err.thread == (0, 0, 0)
        print(io, "\nFor more details, run Julia with `-g2`, or launch the kernel with `@metal debug_level=2`")
    else
        print(io, "\nStacktrace:")
        for (i, (func, file, line)) in enumerate(err.backtrace)
            print(io, "\n [", i, "] ", func)
            isempty(file) || print(io, " at ", file, ":", line)
        end
    end
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
const device_exception_info = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{ExceptionInfo_st}, UInt64}}()
const device_exception_lock = ReentrantLock()

function exception_info_buffer_info(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _, gpuaddr = get!(device_exception_info, dev) do
            # `newBufferWithLength:` (a `new*` method) returns retain-count-1, non-autoreleased
            # per Apple's ARC naming convention, so the buffer survives the pool drain. the
            # pool is here to catch any intermediates the alloc call autoreleases internally.
            @autoreleasepool begin
                buf = MTLBuffer(dev, sizeof(ExceptionInfo_st); storage=SharedStorage)
                ptr = convert(Ptr{ExceptionInfo_st}, MTL.contents(buf))
                unsafe_store!(ptr, ExceptionInfo_st())
                (buf, ptr, UInt64(buf.gpuAddress))
            end
        end
        return buf, gpuaddr
    end
end

exception_info_buffer(dev::MTLDevice) = first(exception_info_buffer_info(dev))

# check the exception mailbox of all devices, rethrowing host-side if one was set.
# the caller is responsible for running inside an autorelease pool (`synchronize` is).
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (_, ptr, _)) in device_exception_info
            status_ptr = convert(Ptr{Int32}, ptr)
            # atomic read-and-clear of `status` so concurrent `synchronize`s on the same
            # device can't both observe the set flag and throw duplicate exceptions, nor
            # race the load against the clear and swallow it.
            if unsafe_swap!(status_ptr, Int32(0), :sequentially_consistent) != 0
                info = unsafe_load(ptr)
                nframes = min(Int(info.num_frames), EXCEPTION_MAX_FRAMES)
                backtrace = Tuple{String, String, Int}[
                    (exception_string(info.frames[i].func),
                     exception_string(info.frames[i].file),
                     Int(info.frames[i].line)) for i in 1:nframes]
                exc = KernelException(dev, exception_string(info.name),
                                      exception_string(info.reason),
                                      info.thread, info.threadgroup, backtrace)
                # clear the lock and payload so the mailbox is reusable
                unsafe_store!(ptr, ExceptionInfo_st())
                throw(exc)
            end
        end
    end
    return
end
