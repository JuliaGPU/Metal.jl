# support for device-side exceptions

## exception type

@public KernelException

"""
    KernelException

An exception thrown by a kernel, e.g., a `BoundsError` from an out-of-bounds access. Kernels
cannot throw to the host while executing, so the first exception is recorded, and thrown by
the next [`synchronize`](@ref) or [`device_synchronize`](@ref) after the kernel finished.

It has the position of the thread that threw. How much is known about the exception depends
on the kernel's `debug_level` (see [`@metal`](@ref)): at level 1, the default, the type of
exception and its reason; at level 2, also a device-side backtrace.
"""
struct KernelException <: Exception
    dev::MTLDevice
    name::String
    reason::String
    thread::NTuple{3, UInt32}
    threadgroup::NTuple{3, UInt32}
    backtrace::Vector{Tuple{String, String, Int}}   # (function, file, line) per frame
end

function KernelException(dev::MTLDevice, site::Union{Nothing, GPUCompiler.ExceptionSite},
                         thread::NTuple{3, UInt32}, threadgroup::NTuple{3, UInt32})
    site === nothing && return KernelException(dev, "", "", thread, threadgroup, [])
    backtrace = Tuple{String, String, Int}[(frame.func, frame.file, frame.line)
                                           for frame in site.frames]
    return KernelException(dev, site.name, site.reason, thread, threadgroup, backtrace)
end

# what isn't known is empty: the name and reason at debug level 0, the backtrace below 2
function Base.showerror(io::IO, err::KernelException)
    name = isempty(err.name) ? "exception" : err.name
    article = first(uppercase(name)) in ('A', 'E', 'I', 'O', 'U') ? "An" : "A"
    print(io, "KernelException: $article $name was thrown")
    thread = join(Int.(err.thread), '×')
    threadgroup = join(Int.(err.threadgroup), '×')
    print(io, " by thread $thread in threadgroup $threadgroup")
    print(io, " on device $(String(err.dev.name))")
    isempty(err.reason) || print(io, ": ", err.reason)
    if isempty(err.backtrace)
        print(io, "\nFor more details, run Julia with `-g2`, or launch the kernel with `@metal debug_level=2`")
    else
        print(io, "\nStacktrace:")
        for (i, (func, file, line)) in enumerate(err.backtrace)
            print(io, "\n [", i, "] ", func)
            isempty(file) || print(io, " at ", file, ":", line)
        end
    end
end


## throw sites

# the mailbox is shared by all kernels on a device, so a kernel passes an id of its table of
# throw sites, which the thread that throws records. ids are session-local, given to tables
# when a kernel is linked, as the tables themselves are cached with the compiled code.
const exception_tables = Vector{GPUCompiler.ExceptionSite}[]
const exception_table_ids = IdDict{Vector{GPUCompiler.ExceptionSite}, UInt32}()
const exception_tables_lock = ReentrantLock()

function exception_table_id(sites::Vector{GPUCompiler.ExceptionSite})
    isempty(sites) && return UInt32(0)
    Base.@lock exception_tables_lock begin
        get!(exception_table_ids, sites) do
            push!(exception_tables, sites)
            length(exception_tables) % UInt32
        end
    end
end

function lookup_exception_site(table::UInt32, site::Int32)
    Base.@lock exception_tables_lock begin
        1 <= table <= length(exception_tables) || return nothing
        sites = exception_tables[table]
        return 1 <= site <= length(sites) ? sites[site] : nothing
    end
end


## exception mailbox

# device-side exceptions are reported through a host-visible mailbox: an `ExceptionInfo_st`
# in a shared (CPU+GPU) buffer whose GPU address is handed to each kernel via the
# `KernelState`. see `device/runtime.jl` for the layout and how the GPU fills it.
const device_exception_info = Dict{MTLDevice, Tuple{MTLBuffer, Ptr{ExceptionInfo_st}, UInt64}}()
const device_exception_lock = ReentrantLock()

function exception_info_buffer_and_gpu_address(dev::MTLDevice)
    Base.@lock device_exception_lock begin
        buf, _, gpuaddr = get!(device_exception_info, dev) do
            local buf = MTLBuffer(dev, sizeof(ExceptionInfo_st); storage=SharedStorage)
            buf.label = "Metal.jl exception info"
            ptr = convert(Ptr{ExceptionInfo_st}, MTL.contents(buf))
            unsafe_store!(ptr, ExceptionInfo_st())
            (buf, ptr, UInt64(MTL.gpu_address(buf)))
        end
        return buf, gpuaddr
    end
end

exception_info_buffer(dev::MTLDevice) = first(exception_info_buffer_and_gpu_address(dev))

# check the exception mailbox of all devices, rethrowing host-side if one was set.
function check_exceptions()
    Base.@lock device_exception_lock begin
        for (dev, (_, ptr, _)) in device_exception_info
            status_ptr = convert(Ptr{Int32}, ptr)
            # atomic read-and-clear of `status` so concurrent `synchronize`s on the same
            # device can't both observe the set flag and throw duplicate exceptions, nor
            # race the load against the clear and swallow it.
            if unsafe_swap!(status_ptr, Int32(0), :sequentially_consistent) != 0
                info = unsafe_load(ptr)
                exc = KernelException(dev, lookup_exception_site(info.table, info.site),
                                      info.thread, info.threadgroup)
                # clear the lock and payload so the mailbox is reusable
                unsafe_store!(ptr, ExceptionInfo_st())
                throw(exc)
            end
        end
    end
    return
end
