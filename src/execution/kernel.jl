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

abstract type AbstractKernel{F,TT} end

@generated function call(kernel::AbstractKernel{F,TT}, args...; call_kwargs...) where {F,TT}
    sig = Base.signature_type(F, TT)
    args = (:F, (:( args[$i] ) for i in 1:length(args))...)

    # filter out ghost arguments that shouldn't be passed
    predicate = if VERSION >= v"1.5.0-DEV.581"
        dt -> isghosttype(dt) || Core.Compiler.isconstType(dt)
    else
        dt -> isghosttype(dt)
    end
    to_pass = map(!predicate, sig.parameters)
    call_t =                  Type[x[1] for x in zip(sig.parameters,  to_pass) if x[2]]
    call_args = Union{Expr,Symbol}[x[1] for x in zip(args, to_pass)            if x[2]]

    # replace non-isbits arguments (they should be unused, or compilation would have failed)
    for (i,dt) in enumerate(call_t)
        if !isbitstype(dt)
            call_t[i] = Ptr{Any}
            call_args[i] = :C_NULL
        end
    end

    # finalize types
    call_tt = Base.to_tuple_type(call_t)

    quote
        Base.@_inline_meta

        mtlcall(kernel.fun, $call_tt, $(call_args...); call_kwargs...)
    end
end

# Why is this all necessary? MtlFunction has the lib and function handle.
struct MtlKernel
    device::MtlDevice
    lib::MtlLibrary
    fun::MtlFunction

    function MtlKernel(dev::MtlDevice, lib::MtlLibrary, fun_name::String)
        fun = MtlFunction(lib, fun_name)
        return new(dev, lib, fun)
        # TODO: Finalizer
    end
end

function MtlKernel(dev::MtlDevice, image::Vector{UInt8}, fun_name::String)
    lib = MtlLibraryFromData(dev, image)
    return MtlKernel(dev, lib, fun_name)
end

# ## host-side kernels

struct HostKernel{F,TT} <: AbstractKernel{F,TT}
    fun::MtlKernel
end

## host-side API

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

function mtlfunction(f::Core.Function, tt::Type=Tuple{}; name=nothing, kwargs...)
    dev = MtlDevice(1)
    cache = get!(()->Dict{UInt,Any}(), mtlfunction_cache, dev)
    source = FunctionSpec(f, tt, true, name)
    target = MetalCompilerTarget(macos=get_macos_v(); kwargs...)
    params = MetalCompilerParams()
    job = CompilerJob(target, source, params)
    GPUCompiler.cached_compilation(cache, job,
                                   mtlfunction_compile, mtlfunction_link)::HostKernel{f,tt}
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
    image, asm_meta = GPUCompiler.emit_asm(job, ir; strip=false, format=LLVM.API.LLVMObjectFile) # TODO: Undo strip eventually
    return (image, entry=LLVM.name(ir_meta.entry))
end

function mtlfunction_link(@nospecialize(job::CompilerJob), compiled)
    dev = MtlDevice(1)
    kernel = MtlKernel(dev, compiled.image, compiled.entry)
    return HostKernel{job.source.f,job.source.tt}(kernel)
end

function (kernel::HostKernel)(args...; kwargs...)
    call(kernel, map(mtlconvert, args)...; kwargs...)
end



#launchKernel

##########################################
# Blocking call to a kernel
# Should implement somethjing better
mtlcall(f::MtlKernel, types::Tuple, args...; kwargs...) =
    mtlcall(f, Base.to_tuple_type(types), args...; kwargs...)

@inline function mtlcall(f::MtlKernel, types::Type, args...; kwargs...)
    # Handle kwargs here??
    cmdq = global_queue(f.lib.device)

    # Process kernel call arguments
    grid    = 1
    threads = 1
    for kwarg in kwargs
        key = kwarg.first
        if key == :grid
            grid = kwarg.second
        elseif key == :threads
            threads = kwarg.second
        else
            throw(ArgumentError("Unsupported keyword argument '$key'"))
        end
    end

    cmdbuf = MtlCommandBuffer(cmdq)
    MtlComputeCommandEncoder(cmdbuf) do cce
        enqueue_function(f, args...; grid, threads, cce)
    end
    commit!(cmdbuf)
end

##############################################
# Enqueue a function for execution
#
function enqueue_function(f::MtlKernel, args...;
                grid::MtlDim=1, threads::MtlDim=1,
                cce::MtlComputeCommandEncoder)
    grid = MtlDim3(grid)
    threads = MtlDim3(threads)
    (grid.width>0 && grid.height>0 && grid.depth>0)    || throw(ArgumentError("Grid dimensions should be non-null"))
    (threads.width>0 && threads.height>0 && threads.depth>0) || throw(ArgumentError("Threadgroup dimensions should be non-null"))

    pipeline_state = MtlComputePipelineState(f.device, f.fun)
    (threads.width * threads.height * threads.depth) > pipeline_state.maxTotalThreadsPerThreadgroup &&
            throw(ArgumentError("Max total threadgroup size should not exceed $(pipeline_state.maxTotalThreadsPerThreadgroup) threads"))
    # Set the function that we are currently encoding
    MTL.set_function!(cce, pipeline_state)
    # Encode all arguments
    encode_arguments!(cce, f.fun, args...)
    # Flush everything
    MTL.append_current_function!(cce, grid, threads)
    return nothing
end

#####
function encode_arguments!(cce::MtlComputeCommandEncoder, f::MtlFunction, args...)
    for (i, a) in enumerate(args)
        encode_argument!(cce, f, i, a)
    end
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, arg::Nothing)
    @assert idx > 0
    #@check api.clSetKernelArg(k.id, cl_uint(idx-1), sizeof(CL_mem), C_NULL)
    MTL.set_bytes!(cce, sizeof(C_NULL), C_NULL, idx)
    return cce
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, arg::MtlBuffer)
    @assert idx > 0
    set_buffer!(cce, arg, 0, idx)
    return cce
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, arg::Core.LLVMPtr{T}) where T
    @assert idx > 0
    set_buffer!(cce, MtlBuffer{T}(Base.bitcast(MTL.MTLBuffer, arg)), 0, idx)
    return cce
end

function encode_argument!(enc::MTL.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, val::T) where T
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
function encode_argument!(cce::MTL.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, val::MtlDeviceArray{T}) where T
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
