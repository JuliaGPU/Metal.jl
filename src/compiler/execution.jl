export @metal

"""
    @metal [kwargs...] func(args...)

High-level interface for executing code on a GPU. The `@metal` macro should prefix a call,
with `func` a callable function or object that should return nothing. It will be compiled to
a Metal function upon first use, and to a certain extent arguments will be converted and
managed automatically using `mtlconvert`. Finally, a call to `mtlcall` is
performed, creating a command buffer in the current global command queue then committing it.

There is one supported keyword argument that influences the behavior of `@metal`.
- `launch`: whether to launch this kernel, defaults to `true`. If `false` the returned
  kernel object should be launched by calling it and passing arguments again.
"""
macro metal(ex...)
    call = ex[end]
    kwargs = ex[1:end-1]

    # destructure the kernel call
    Meta.isexpr(call, :call) || throw(ArgumentError("second argument to @metal should be a function call"))
    f = call.args[1]
    args = call.args[2:end]

    code = quote end
    vars, var_exprs = assign_args!(code, args)

    # group keyword argument
    macro_kwargs, compiler_kwargs, call_kwargs, other_kwargs =
        split_kwargs(kwargs, [:launch], [:name], [:grid, :threads, :queue])
    if !isempty(other_kwargs)
        key,val = first(other_kwargs).args
        throw(ArgumentError("Unsupported keyword argument '$key'"))
    end

    # handle keyword arguments that influence the macro's behavior
    launch = true
    for kwarg in macro_kwargs
        key,val = kwarg.args
        if key === :launch
            isa(val, Bool) || throw(ArgumentError("`launch` keyword argument to @metal should be a Bool"))
            launch = val::Bool
        else
            throw(ArgumentError("Unsupported keyword argument '$key'"))
        end
    end
    if !launch && !isempty(call_kwargs)
        error("@metal with launch=false does not support launch-time keyword arguments; use them when calling the kernel")
    end

    # FIXME: macro hygiene wrt. escaping kwarg values (this broke with 1.5)
    #        we esc() the whole thing now, necessitating gensyms...
    @gensym f_var kernel_f kernel_args kernel_tt kernel

    # convert the arguments, call the compiler and launch the kernel
    # while keeping the original arguments alive
    push!(code.args,
        quote
            $f_var = $f
            GC.@preserve $(vars...) $f_var begin
                $kernel_f = $mtlconvert($f_var)
                $kernel_args = map($mtlconvert, ($(var_exprs...),))
                $kernel_tt = Tuple{map(Core.Typeof, $kernel_args)...}
                $kernel = $mtlfunction($kernel_f, $kernel_tt; $(compiler_kwargs...))
                if $launch
                    $kernel($(var_exprs...); $(call_kwargs...))
                end
                $kernel
            end
         end)

    return esc(quote
        let
            $code
        end
    end)
end


## argument conversion

struct Adaptor
    cce::Union{Nothing,MTLComputeCommandEncoder}
end

# convert Metal buffers to their GPU address
function Adapt.adapt_storage(to::Adaptor, buf::MTLBuffer)
    if to.cce !== nothing
        MTL.use!(to.cce, buf, MTL.ReadWriteUsage)
    end
    reinterpret(Core.LLVMPtr{Nothing,AS.Device}, buf.gpuAddress)
end
function Adapt.adapt_storage(to::Adaptor, ptr::MtlPointer{T}) where {T}
    reinterpret(Core.LLVMPtr{T,AS.Device}, adapt(to, ptr.buffer)) + ptr.offset
end

# Base.RefValue isn't GPU compatible, so provide a compatible alternative
struct MtlRefValue{T} <: Ref{T}
  x::T
end
Base.getindex(r::MtlRefValue) = r.x
Adapt.adapt_structure(to::Adaptor, r::Base.RefValue) = MtlRefValue(adapt(to, r[]))

function Adapt.adapt_storage(to::Adaptor, xs::MtlArray{T,N}) where {T,N}
    buf = pointer(xs)
    ptr = adapt(to, buf)
    MtlDeviceArray{T,N,AS.Device}(xs.dims, ptr)
end

"""
  mtlconvert(x, [cce])

This function is called for every argument to be passed to a kernel, allowing it to be
converted to a GPU-friendly format. By default, the function does nothing and returns the
input object `x` as-is.

Do not add methods to this function, but instead extend the underlying Adapt.jl package and
register methods for the the `Metal.Adaptor` type.
"""
mtlconvert(arg, cce=nothing) = adapt(Adaptor(cce), arg)


## host-side kernel API

struct HostKernel{F,TT}
    f::F
    fun::MTLFunction
    pipeline_state::MTLComputePipelineState
end

"""
    mtlfunction(f, tt=Tuple{}; kwargs...)

Low-level interface to compile a function invocation for the currently-active GPU, returning
a callable kernel object. For a higher-level interface, use [`@metal`](@ref).

The output of this function is automatically cached, i.e. you can simply call `mtlfunction`
in a hot path without degrading performance. New code will be generated automatically when
the function changes, or when different types or keyword arguments are provided.
"""
function mtlfunction(f::F, tt::TT=Tuple{}; name=nothing, kwargs...) where {F,TT}
    dev = MTLDevice(1)
    cache = get!(()->Dict{UInt,Any}(), mtlfunction_cache, dev)
    source = FunctionSpec(f, tt, true, name)
    target = MetalCompilerTarget(macos=macos_version(); kwargs...)
    params = MetalCompilerParams()
    job = CompilerJob(target, source, params)
    fun, pipeline_state =
        GPUCompiler.cached_compilation(cache, job,
                                       mtlfunction_compile, mtlfunction_link)
    # compilation is cached on the function type, so we can only create a kernel object here
    # (as it captures the function _instance_). we may want to cache those objects.
    HostKernel{F,tt}(f, fun, pipeline_state)
end

const mtlfunction_cache = Dict{Any,Any}()

function mtlfunction_compile(@nospecialize(job::CompilerJob))
    # TODO: on 1.9, this actually creates a context. cache those.
    JuliaContext() do ctx
        mtlfunction_compile(job, ctx)
    end
end
function mtlfunction_compile(@nospecialize(job::CompilerJob), ctx)
    mi, mi_meta = GPUCompiler.emit_julia(job)
    ir, ir_meta = GPUCompiler.emit_llvm(job, mi; ctx)
    entry = LLVM.name(ir_meta.entry)
    image, asm_meta = GPUCompiler.emit_asm(job, ir; format=LLVM.API.LLVMObjectFile)
    return (; image, entry)
end

function mtlfunction_link(@nospecialize(job::CompilerJob), compiled)
    dev = current_device()
    lib = MTLLibraryFromData(dev, compiled.image)
    fun = MTLFunction(lib, compiled.entry)
    pipeline_state = try
        MTLComputePipelineState(dev, fun)
    catch
        # the back-end compiler likely failed
        # XXX: check more accurately? the error domain doesn't help much here
        metallib = tempname(cleanup=false) * ".metallib"
        write(metallib, compiled.image)
        @warn """Compilation of MetalLib to native code failed.
                 If you think this is a bug, please file an issue and attach $(metallib)."""
        rethrow()
    end
    fun, pipeline_state
end


## kernel launching and argument encoding

function (kernel::HostKernel)(args...; grid=1, threads=1, queue=global_queue(current_device()))
    grid = MTLSize(grid)
    threads = MTLSize(threads)
    (grid.width>0 && grid.height>0 && grid.depth>0) ||
        throw(ArgumentError("Grid dimensions should be non-null"))
    (threads.width>0 && threads.height>0 && threads.depth>0) ||
        throw(ArgumentError("Threadgroup dimensions should be non-null"))

    (threads.width * threads.height * threads.depth) > kernel.pipeline_state.maxTotalThreadsPerThreadgroup &&
        throw(ArgumentError("Max total threadgroup size should not exceed $(kernel.pipeline_state.maxTotalThreadsPerThreadgroup)"))

    cmdbuf = MTLCommandBuffer(queue)
    cmdbuf.label = "MTLCommandBuffer($(nameof(kernel.f)))"
    argument_buffers = MTLBuffer[]
    MTLComputeCommandEncoder(cmdbuf) do cce
        MTL.set_function!(cce, kernel.pipeline_state)

        # encode arguments
        idx = 1
        for arg in (kernel.f, args...)
            if arg isa MTLBuffer
                # top-level buffers are passed as a pointer-valued argument
                set_buffer!(cce, arg, 0, idx)
            elseif arg isa MtlPointer
                # the same as a buffer, but with an offset
                set_buffer!(cce, arg.buffer, arg.offset, idx)
            else
                # everything else is passed by reference, and requires an argument buffer
                arg = mtlconvert(arg, cce)
                argtyp = Core.typeof(arg)
                if isghosttype(argtyp) || Core.Compiler.isconstType(argtyp)
                    continue
                end
                @assert isbits(arg)
                argument_buffer = alloc(kernel.fun.device, sizeof(argtyp),
                                        storage=Shared)
                argument_buffer.label = "MTLBuffer for kernel argument"
                unsafe_store!(convert(Ptr{argtyp}, contents(argument_buffer)), arg)
                set_buffer!(cce, argument_buffer, 0, idx)
                push!(argument_buffers, argument_buffer)
            end
            idx += 1
        end

        MTL.append_current_function!(cce, grid, threads)
    end

    # the command buffer retains resources that are explicitly encoded (i.e. direct buffer
    # arguments, or the buffers allocated for each other argument), but that doesn't keep
    # other resources alive for which we've encoded the GPU address ourselves. since it's
    # possible for buffers to go out of scope while the kernel is still running, which
    # triggers validation failures, keep track of things we need to keep alive until the
    # kernel has actually completed.
    #
    # TODO: is there a way to bind additional resources to the command buffer?
    roots = [kernel.f, args]
    MTL.on_completed(cmdbuf) do buf
        empty!(roots)
        foreach(free, argument_buffers)

        # TODO: access logs here to check for errors
        #       https://developer.apple.com/videos/play/wwdc2020/10616/
    end

    commit!(cmdbuf)
end

## Intra-warp Helpers

"""
    nextwarp(dev, threads)
    prevwarp(dev, threads)

Returns the next or previous nearest number of threads that is a multiple of the warp size
of a device `dev`. This is a common requirement when using intra-warp communication.
"""
function nextwarp(pipe::MTLComputePipelineState, threads::Integer)
    ws = pipe.threadExecutionWidth
    return threads + (ws - threads % ws) % ws
end

@doc (@doc nextwarp) function prevwarp(pipe::MTLComputePipelineState, threads::Integer)
    ws = pipe.threadExecutionWidth
    return threads - Base.rem(threads, ws)
end
