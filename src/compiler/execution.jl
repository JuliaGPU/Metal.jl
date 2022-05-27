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
    arg_info::Any
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
    fun, arguments = GPUCompiler.cached_compilation(cache, job,
                                                    mtlfunction_compile, mtlfunction_link)
    # compilation is cached on the function type, so we can only create a kernel object here
    # (as it captures the function _instance_). we may want to cache those objects.
    HostKernel{F,tt}(f, fun, arguments)
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
    return (image, entry=LLVM.name(ir_meta.entry), arguments=job.meta[:arguments])
end

function mtlfunction_link(@nospecialize(job::CompilerJob), compiled)
    dev = device()
    lib = MtlLibraryFromData(dev, compiled.image)
    MtlFunction(lib, compiled.entry), compiled.arguments
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

    cmdq = global_queue(kernel.fun.lib.device)
    cmdbuf = MtlCommandBuffer(cmdq)
    MtlComputeCommandEncoder(cmdbuf) do cce
        MTL.set_function!(cce, pipeline_state)

        # encode arguments
        idx = 1
        args = map(mtlconvert, (kernel.f, args...))
        @assert length(args) == length(kernel.arg_info)
        for (arg, arg_info) in zip(args, kernel.arg_info)
            arg_info.kind == GPUCompiler.GhostArgument && continue

            if arg_info.kind == GPUCompiler.BufferArgument
                if arg isa Core.LLVMPtr
                    buf = MtlBuffer{Nothing}(Base.bitcast(MTL.MTLBuffer, arg))
                    set_buffer!(cce, buf, 0, idx)
                else
                    @assert isbits(arg)
                    ref = Base.RefValue(arg)
                    GC.@preserve ref begin
                        ptr = Base.unsafe_convert(Ptr{Nothing}, ref)
                        set_bytes!(cce, ptr, sizeof(ref), idx)
                    end
                end
            elseif arg_info.kind == GPUCompiler.ArrayArgument
                @assert isbits(arg)
                ref = Base.RefValue(arg)
                GC.@preserve ref begin
                    ptr = Base.unsafe_convert(Ptr{Nothing}, ref)
                    set_bytes!(cce, ptr, sizeof(ref), idx)
                end
            elseif arg_info.kind == GPUCompiler.StructArgument
                @assert isbits(arg)
                ref = Base.RefValue(arg)
                GC.@preserve ref begin
                    ptr = Base.unsafe_convert(Ptr{Nothing}, ref)
                    set_bytes!(cce, ptr, sizeof(ref), idx)
                end
            elseif arg_info.kind == GPUCompiler.IndirectStructArgument
                # create an argument encoder
                arg_enc = MtlArgumentEncoder(kernel.fun, idx)
                arg_buf = alloc(Cchar, kernel.fun.lib.device, sizeof(arg_enc), storage=Shared)
                MTL.assign_argument_buffer!(arg_enc, arg_buf, 0)

                # encode fields
                function encode_field(arg, arg_info)
                    @assert fieldcount(typeof(arg)) == length(arg_info.fields)
                    for (field_name, field_info) in zip(fieldnames(typeof(arg)), arg_info.fields)
                        field_info.kind == GPUCompiler.GhostArgument && continue
                        field = getfield(arg, field_name)
                        if field_info.kind == GPUCompiler.BufferArgument
                            @assert field isa Core.LLVMPtr
                            buf = MtlBuffer{Nothing}(Base.bitcast(MTL.MTLBuffer, field))
                            set_buffer!(arg_enc, buf, 0, field_info.id)
                            MTL.use!(cce, buf, MTL.ReadWriteUsage)
                        elseif field_info.kind == GPUCompiler.ConstantArgument
                            set_constant!(arg_enc, field, field_info.id)
                        elseif field_info.kind == GPUCompiler.IndirectStructArgument
                            encode_field(field, field_info)
                        elseif field_info.kind == GPUCompiler.ArrayArgument
                            # XXX: this seems weird?
                            set_constant!(arg_enc, field, field_info.id)
                        else
                            error("Unknown struct field: $(field_info.kind) $(field)")
                        end
                    end
                end
                encode_field(arg, arg_info)

                # encode argument
                set_buffer!(cce, arg_buf, 0, idx)
            else
                error("Unknown argument kind: $(arg_info.kind)")
            end

            idx += 1
        end

        MTL.append_current_function!(cce, grid, threads)
    end
    commit!(cmdbuf)
end
