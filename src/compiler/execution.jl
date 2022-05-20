export @metal

# Match Darwin version to MacOS version only caring about M1 release and after
# Following: https://en.wikipedia.org/wiki/Darwin_(operating_system)#History
const darwin_to_macos = Dict(
                        # Catalina
                        v"19.2.0" => v"10.15.2",
                        v"19.3.0" => v"10.15.3",
                        v"19.4.0" => v"10.15.4",
                        v"19.5.0" => v"10.15.5",
                        v"19.6.0" => v"10.15.6",
                        # Big Sur
                        v"20.0.0" => v"11.0.0",
                        v"20.1.0" => v"11.0.0",
                        v"20.2.0" => v"11.1.0",
                        v"20.3.0" => v"11.2.0",
                        v"20.4.0" => v"11.3.0",
                        v"20.5.0" => v"11.4.0",
                        v"20.6.0" => v"11.5.0",
                        # Monterey
                        v"21.0.0" => v"12.0.0",
                        v"21.0.1" => v"12.0.0",
                        v"21.1.0" => v"12.0.1",
                        v"21.2.0" => v"12.1.0",
                        v"21.3.0" => v"12.2.0",
                        v"21.4.0" => v"12.3.0")

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
        split_kwargs(kwargs, [:launch], [:name], [:grid, :threads])
    if !isempty(other_kwargs)
        key,val = first(other_kwargs).args
        throw(ArgumentError("Unsupported keyword argument '$key'"))
    end

    # handle keyword arguments that influence the macro's behavior
    launch = true
    for kwarg in macro_kwargs
        key,val = kwarg.args
        if key == :launch
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
                local $kernel_f = $mtlconvert($f_var)
                local $kernel_args = map($mtlconvert, ($(var_exprs...),))
                local $kernel_tt = Tuple{map(Core.Typeof, $kernel_args)...}
                local $kernel = $mtlfunction($kernel_f, $kernel_tt; $(compiler_kwargs...))
                if $launch
                    $kernel($(var_exprs...); $(call_kwargs...))
                end
                $kernel
            end
         end)
    return esc(code)
end


## argument conversion

struct Adaptor end

# convert Metal Buffers Metal device pointers # should be generic
Adapt.adapt_storage(to::Adaptor, buf::MtlBuffer{T}) where {T} = reinterpret(Core.LLVMPtr{T,AS.Device}, buf.handle)

# Base.RefValue isn't GPU compatible, so provide a compatible alternative
struct MtlRefValue{T} <: Ref{T}
  x::T
end
Base.getindex(r::MtlRefValue) = r.x
Adapt.adapt_structure(to::Adaptor, r::Base.RefValue) = MtlRefValue(adapt(to, r[]))

"""
  mtlconvert(x)

This function is called for every argument to be passed to a kernel, allowing it to be
converted to a GPU-friendly format. By default, the function does nothing and returns the
input object `x` as-is.

Do not add methods to this function, but instead extend the underlying Adapt.jl package and
register methods for the the `Metal.Adaptor` type.
"""
mtlconvert(arg) = adapt(Adaptor(), arg)


## host-side kernel API

struct HostKernel{F,TT}
    f::F
    fun::MtlFunction
end

# Get MacOS version from Darwin version
function get_macos_v()
    machine = Sys.MACHINE
    darwin_v = VersionNumber(machine[findfirst("darwin", machine)[end]+1:end])
    # Check for unsupported/incomplete kernel version
    if !(darwin_v in keys(darwin_to_macos))
        error("Unsupported kernel version of $darwin_v")
    end
    return darwin_to_macos[darwin_v]
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
    dev = MtlDevice(1)
    cache = get!(()->Dict{UInt,Any}(), mtlfunction_cache, dev)
    source = FunctionSpec(f, tt, true, name)
    target = MetalCompilerTarget(macos=get_macos_v(); kwargs...)
    params = MetalCompilerParams()
    job = CompilerJob(target, source, params)
    fun = GPUCompiler.cached_compilation(cache, job,
                                         mtlfunction_compile, mtlfunction_link)
    # compilation is cached on the function type, so we can only create a kernel object here
    # (as it captures the function _instance_). we may want to cache those objects.
    HostKernel{F,tt}(f, fun)
end

const mtlfunction_cache = Dict{Any,Any}()

function mtlfunction_compile(@nospecialize(job::CompilerJob))
    # TODO: on 1.9, this actually creates a context. cache those.
    JuliaContext() do ctx
        mtlfunction_compile(job, ctx)
    end
end
function mtlfunction_compile(@nospecialize(job::CompilerJob), ctx::Context)
    mi, mi_meta = GPUCompiler.emit_julia(job)
    ir, ir_meta = GPUCompiler.emit_llvm(job, mi; ctx)
    image, asm_meta = GPUCompiler.emit_asm(job, ir; strip=false, format=LLVM.API.LLVMObjectFile)
    # TODO: don't strip IR
    return (image, entry=LLVM.name(ir_meta.entry))
end

function mtlfunction_link(@nospecialize(job::CompilerJob), compiled)
    dev = device()
    lib = MtlLibraryFromData(dev, compiled.image)
    MtlFunction(lib, compiled.entry)
end


## kernel launching and argument encoding

function (kernel::HostKernel)(args...; grid::MtlDim=1, threads::MtlDim=1)
    grid = MtlDim3(grid)
    threads = MtlDim3(threads)
    (grid.width>0 && grid.height>0 && grid.depth>0) ||
        throw(ArgumentError("Grid dimensions should be non-null"))
    (threads.width>0 && threads.height>0 && threads.depth>0) ||
        throw(ArgumentError("Threadgroup dimensions should be non-null"))

    pipeline_state = MtlComputePipelineState(kernel.fun.lib.device, kernel.fun)
    (threads.width * threads.height * threads.depth) > pipeline_state.maxTotalThreadsPerThreadgroup &&
        throw(ArgumentError("Max total threadgroup size should not exceed $(pipeline_state.maxTotalThreadsPerThreadgroup)"))

    args = map(mtlconvert, args)

    cmdq = global_queue(kernel.fun.lib.device)
    cmdbuf = MtlCommandBuffer(cmdq)
    MtlComputeCommandEncoder(cmdbuf) do cce
        MTL.set_function!(cce, pipeline_state)
        encode_arguments!(cce, kernel.fun, args...)
        MTL.append_current_function!(cce, grid, threads)
    end
    commit!(cmdbuf)
end

function encode_arguments!(cce::MtlComputeCommandEncoder, f::MtlFunction, args...)
    for (i, a) in enumerate(args)
        encode_argument!(cce, f, i, a)
    end
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer,
                          rg::Nothing)
    @assert idx > 0
    #@check api.clSetKernelArg(k.id, cl_uint(idx-1), sizeof(CL_mem), C_NULL)
    MTL.set_bytes!(cce, sizeof(C_NULL), C_NULL, idx)
    return cce
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer,
                          arg::MtlBuffer)
    @assert idx > 0
    set_buffer!(cce, arg, 0, idx)
    return cce
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer,
                          arg::Core.LLVMPtr)
    @assert idx > 0

    set_buffer!(cce, MtlBuffer{Float32}(Base.bitcast(MTL.MTLBuffer, arg)), 0, idx)
    return cce
end

function encode_argument!(enc::MTL.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer,
                          val::T) where T
    @assert idx > 0 "Kernel idx must be bigger 0"
    #if does not contain a buffer we can use setbytes
    if !contains_mtlbuffer(T)
        ref, tsize = to_mtl_ref(val)
        MTL.set_bytes!(enc, ref, tsize, idx)
    else
        #otherwise, we need an argument buffer
        throw("Not implemented: If an argument contains a mtlbuffer automatic argument encoding is not yet supported.")

        # create an encoder to write into the argument buffer
        argbuf_enc = MtlArgumentEncoder(f, idx)
        # allocate the argument buffer
        argbuf = alloc(Cchar, device(enc), sizeof(argbuf_enc), storage=Shared)
        # assign the argument buffer to the encoder
        MTL.assign_argument_buffer!(argbuf_enc, argbuf, 1)

        # TODO Implement automatic conversion of struct into a assign_argument_buffer

        #for field in val
        #    MTL.set_field!(argbuf_enc, size(val), 1)
        #    set_buffer!(argbuf_enc, pointer(val), 0, 2)
        #end

        # set argubuf_enc into cce
    end
    return enc
end

# Encode MtlDeviceArray using an argument buffer
function encode_argument!(cce::MTL.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer,
                          val::MtlDeviceArray{T}) where T
    #@assert contains_mtlbuffer(typeof(val))
    # create an encoder to write into the argument buffer
    argbuf_enc = MtlArgumentEncoder(f, idx)
    # allocate the argument buffer
    argbuf = alloc(Cchar, device(cce), sizeof(argbuf_enc), storage=Shared)
    # assign the argument buffer to the arg buff encoder
    MTL.assign_argument_buffer!(argbuf_enc, argbuf, 1)

    # Convert LLVMPtr to MtlBuffer
    mtl_buf = MtlBuffer{T}(Base.bitcast(MTL.MTLBuffer, val.ptr))
    # encode the buffer into the argument buffer
    set_buffer!(argbuf_enc, mtl_buf, 0, 1)
    # Encode the size of the MtlDeviceArray into the argument buffer
    MTL.set_field!(argbuf_enc, size(val), 2)
    # Set the device array usage for read/write TODO: Handle constant arrays
    MTL.use!(cce, mtl_buf, MTL.ReadWriteUsage)

    # Set the argument buffer at given argument index
    set_buffer!(cce, argbuf, 0, idx)
    #TODO memmgmt: Leaked temporary argument buffer (argbuf)
    return cce
end
