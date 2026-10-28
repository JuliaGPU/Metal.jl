export @metal, metalcall

@public mtlconvert, mtlfunction, HostKernel


## high-level @metal interface

const MACRO_KWARGS = [:launch]
const COMPILER_KWARGS = [:kernel, :name, :fastmath, :always_inline, :debug_level, :opt_level, :macos, :air, :metal, :gpufamily, :minthreads, :maxthreads]
const LAUNCH_KWARGS = [:groups, :threads, :queue, :submit]

"""
    @metal [kwargs...] f(args...)

Compile `f(args...)` as a GPU kernel and launch it on the current device. `f` must return
`nothing`. The kernel is compiled on first use for the types of `f` and `args`, and cached;
arguments are converted to their device counterparts with [`mtlconvert`](@ref) (e.g., an
`MtlArray` becomes an `MtlDeviceArray`).

The launch is asynchronous: it is recorded on the command queue of the current task, and
submitted together with other work. Use [`synchronize`](@ref) to wait for it, which is also
where errors thrown by the kernel are reported (see [`Metal.KernelException`](@ref)).

`@metal` dispatches `groups` threadgroups of `threads` threads each, so the grid holds
`groups .* threads` threads per dimension. If that is more than the number of elements to
process, the kernel has to check bounds itself, e.g., `i <= length(a) || return`.

# Launch keywords

- `threads` (default `1`): the number of threads per threadgroup, an integer or a tuple of
  up to three integers. The product cannot exceed the kernel's limit, which is at most 1024
  on Apple GPUs but can be lower for complex kernels: compile the kernel with `launch=false`
  and check its `maxthreads` (see [`HostKernel`](@ref)).
- `groups` (default `1`): the number of threadgroups in the grid, an integer or a tuple of
  up to three integers.
- `queue`: the command queue to submit to, instead of the task's [`global_queue`](@ref).
- `submit` (default `false`): submit the queue's pending work right after this launch,
  instead of when the batch is full or the queue is synchronized.
- `launch` (default `true`): when `false`, only compile the kernel and return it as a
  [`HostKernel`](@ref), to be launched later by calling it with arguments and launch
  keywords. This is not allowed together with other launch keywords.

# Compiler keywords

- `name`: the name of the kernel in the generated code, e.g., as shown in Xcode. Defaults to
  the name of `f`.
- `fastmath` (default `false`, or `true` when Julia runs with `--math-mode=fast`): apply
  `@fastmath` semantics to all floating-point code in the kernel, and compile it with
  Metal's fast-math mode.
- `debug_level` (default: Julia's `-g` level): how much information is kept to report
  device-side exceptions; `2` adds the position of the faulting thread and a backtrace.
- `opt_level` (default `2`): the optimization level, from `0` to `3`, independent of the
  host session's `-O` level.
- `always_inline` (default `false`): inline every function called by the kernel.
- `minthreads`: the exact threadgroup size the kernel will be launched with, an integer or a
  tuple of up to three integers, like MSL's `required_threads_per_threadgroup`. The compiler
  can specialize for it, and launches with any other size are rejected. Requires macOS 26.
- `maxthreads`: the maximum number of threads per threadgroup the kernel will be launched
  with, like MSL's `max_total_threads_per_threadgroup`. A lower maximum leaves the compiler
  more registers per thread, e.g., to avoid running out of them in complex kernels.
- `macos`, `metal`, `air`, `gpufamily`: the deployment target, Metal Shading Language
  version, AIR version and Apple GPU family to compile for, which default to what the host
  supports. See [`mtlfunction`](@ref).

# Examples

```julia
function vadd(c, a, b)
    i = thread_position_in_grid().x
    if i <= length(c)
        @inbounds c[i] = a[i] + b[i]
    end
    return
end

a = Metal.rand(Float32, 10_000); b = Metal.rand(Float32, 10_000)
c = similar(a)
threads = 256
@metal threads groups=cld(length(c), threads) vadd(c, a, b)
```
"""
macro metal(ex...)
    call = ex[end]
    kwargs = map(ex[1:end-1]) do kwarg
        if kwarg isa Symbol
            :($kwarg = $kwarg)
        elseif Meta.isexpr(kwarg, :(=))
            kwarg
        else
            throw(ArgumentError("Invalid keyword argument '$kwarg'"))
        end
    end

    # destructure the kernel call
    Meta.isexpr(call, :call) || throw(ArgumentError("second argument to @metal should be a function call"))
    f = call.args[1]
    args = call.args[2:end]

    code = quote end
    vars, var_exprs = assign_args!(code, args)

    # group keyword argument
    macro_kwargs, compiler_kwargs, call_kwargs, other_kwargs =
        split_kwargs(kwargs, MACRO_KWARGS, COMPILER_KWARGS, LAUNCH_KWARGS)
    if !isempty(other_kwargs)
        key,_ = first(other_kwargs).args
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
                $kernel = $mtlfunction($kernel_f, $kernel_tt;
                                       source=$f_var, $(compiler_kwargs...))
                if $launch
                    $launch_kernel($kernel, ($(var_exprs...),); $(call_kwargs...))
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

# thrown when encoding a kernel argument whose memory may still be in use by another
# queue. the launch is retried after waiting for that queue, without holding any locks.
struct OwnershipConflict <: Exception
    managed::Managed
end

function claim!(ptr::MtlPtr, bq::BatchedCommandQueue)
    conflict = try_take_ownership!(bq, ptr)
    conflict === nothing || throw(OwnershipConflict(conflict))
    return
end

struct Adaptor
    # the current encoding context (see `CommandBackend`), if any.
    cce::Union{Nothing,MTLComputeCommandEncoder,Metal4Backend}
    # the queue the encoder belongs to, if any.
    queue::Union{Nothing,ConcreteBatchedQueue}
end

# convert Metal buffers to their GPU address
function Adapt.adapt_storage(to::Adaptor, buf::MTLBuffer)
    if to.cce !== nothing
        make_resident!(to.cce, buf, MTL.ReadWriteUsage)
    end
    reinterpret(Core.LLVMPtr{Nothing,AS.Device}, MTL.gpu_address(buf))
end
function Adapt.adapt_storage(to::Adaptor, ptr::MtlPtr{T}) where {T}
    to.queue === nothing || claim!(ptr, to.queue)
    reinterpret(Core.LLVMPtr{T,AS.Device}, adapt(to, ptr.buffer)) + ptr.offset
end

# convert Metal host arrays to device arrays
function Adapt.adapt_storage(to::Adaptor, xs::MtlArray{T,N}) where {T,N}
    buf = pointer(xs)
    ptr = adapt(to, buf)
    check_alignment(xs, ptr)
    # the device array addresses its selector bytes relative to its first element
    MtlDeviceArray{T,N,AS.Device}(xs.dims, ptr, xs.maxsize - xs.offset)
end

# an `MtlArray` can point at memory that is not aligned for its element type, e.g., after
# `reinterpret` of a view. that is fine for copies, but element accesses in kernels assume
# the alignment of the element type.
function check_alignment(a::MtlArray{T}, ptr) where {T}
    align = element_alignment(T)
    if UInt(ptr) % align != 0 && !isempty(a)
        alignment_error(T, ptr, align)
    end
end
@noinline alignment_error(T, ptr, align) =
    throw(ArgumentError("cannot use a $T array at $ptr in a kernel, which requires $align-byte alignment. Such arrays result from `reinterpret`ing a view that doesn't start at a multiple of the alignment; use `copy` to get an aligned array."))

# CPU arrays would otherwise only be rejected by the compiler, with an error that dumps the
# full argument type. they are not wrapped automatically: Metal.jl cannot synchronize host
# accesses to an `Array` with the GPU, so that would silently race.
Adapt.adapt_storage(::Adaptor, xs::Array) =
    throw(ArgumentError("""cannot use a CPU array ($(typeof(xs))) in a Metal kernel.
                           Convert it to a GPU array first, e.g. using `MtlArray(x)`, or use `unsafe_wrap(MtlArray, x)` to use its memory without copying (see its docstring for the required synchronization)."""))

# Base.RefValue isn't GPU compatible, so provide a compatible alternative
# TODO: port improvements from CUDA.jl
struct MtlRefValue{T} <: Ref{T}
    x::T
end
Base.getindex(r::MtlRefValue) = r.x
Adapt.adapt_structure(to::Adaptor, r::Base.RefValue) = MtlRefValue(adapt(to, r[]))

# broadcast sometimes passes a ref(type), resulting in a GPU-incompatible DataType box.
# avoid that by using a special kind of ref that knows about the boxed type.
struct MtlRefType{T} <: Ref{DataType} end
Base.getindex(::MtlRefType{T}) where {T} = T
Adapt.adapt_structure(::Adaptor, r::Base.RefValue{<:Union{DataType, Type}}) =
    MtlRefType{r[]}()

# case where type is the function being broadcasted
# (on Julia 1.14, the function type parameter is `Core.TypeEgal{T} <: Type{T}`)
Adapt.adapt_structure(to::Adaptor,
                      bc::Broadcast.Broadcasted{Style, <:Any, <:Type{T}}) where {Style, T} =
    Broadcast.Broadcasted{Style}((x...) -> T(x...), adapt(to, bc.args), bc.axes)

# functions that capture a type, e.g., `Base.Fix1(convert, T)` as used by LinearAlgebra,
# which isn't a valid kernel argument either
Adapt.adapt_structure(to::Adaptor, f::Base.Fix1{<:Any, <:Type{T}}) where {T} =
    let g = adapt(to, f.f); (x...) -> g(T, x...) end
Adapt.adapt_structure(to::Adaptor, f::Base.Fix2{<:Any, <:Type{T}}) where {T} =
    let g = adapt(to, f.f); (x...) -> g(x..., T) end

"""
    mtlconvert(x)

Convert a kernel argument `x` to the object the kernel receives, e.g., an `MtlArray` to an
`MtlDeviceArray`. [`@metal`](@ref) calls it on every argument. Tuples, named tuples and
array wrappers are converted recursively; other objects are passed as-is.

To convert the fields of your own types, don't add methods to this function, but use
[Adapt.jl](https://github.com/JuliaGPU/Adapt.jl) (e.g., `Adapt.@adapt_structure MyType`),
which all JuliaGPU back-ends share.
"""
mtlconvert(arg, cce=nothing, queue=nothing) = adapt(Adaptor(cce, queue), arg)


## low-level kernel launch

"""
    metalcall(pipeline::MTLComputePipelineState, types, values...;
              groups=1, threads=1, queue=nothing, submit=false,
              threadgroup_memory=(), resources=())

`ccall`-like interface for launching a compute pipeline, e.g., one created from a function
in a precompiled Metal library, on the GPU. `types` is a tuple of types, or a tuple type,
with an entry per parameter of the kernel, which determines how each of the `values` is
passed:

- pointer types (`Metal.MtlPtr`, `Core.LLVMPtr` or `Ptr`) are bound as a buffer (with an
  offset), and should be passed an `MtlArray`, `MtlPtr` or `MTLBuffer`;
- other types are passed by value, after converting the argument with [`mtlconvert`](@ref)
  and `convert`; these must be bits types with the layout the kernel expects.

The parameters are bound to consecutive buffer indices, starting at 0, skipping those of a
type that holds no data: a singleton type like `Nothing`, or a type like `Type{Int}`.
Nothing is checked against the kernel's signature: using types that don't match it is
undefined behavior.

The kernel is launched on `groups` threadgroups of `threads` threads each, both of which
should be an integer or a tuple of up to three integers. The other keyword arguments are:

- `queue`: the command queue to launch on, defaulting to the current task's;
- `submit`: submit the work batched on the queue right away, instead of when Metal.jl
  decides to;
- `threadgroup_memory`: the length in bytes of the threadgroup memory for each of the
  kernel's `[[threadgroup(i)]]` parameters, in order (a multiple of 16 bytes);
- `resources`: buffers that the kernel accesses through GPU addresses it reads from its
  arguments, e.g., from a struct or an argument buffer. These are made resident and kept
  alive until the kernel has finished, which happens automatically for the buffers of
  arrays in arguments converted by `mtlconvert`.

For example, to launch a kernel written in the Metal Shading Language:

```julia
lib = MTL.MTLLibrary(device(), \"""
    kernel void scale(device float *x [[buffer(0)]], constant float &a [[buffer(1)]],
                      uint i [[thread_position_in_grid]]) {
        x[i] *= a;
    }
    \""")
pipeline = MTL.MTLComputePipelineState(device(), MTL.MTLFunction(lib, "scale"))

x = Metal.ones(Float32, 256)
metalcall(pipeline, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 2; threads=256)
```

See also [`Metal.metalcall_tuple`](@ref), which takes the values as a tuple.
"""
metalcall(pipeline::MTLComputePipelineState, types::Union{Tuple,Type},
          args::Vararg{Any,N}) where {N} =
    metalcall_tuple(pipeline, types, args)
# forward the values as a tuple, which a keyword-argument method would splat
Core.kwcall(kwargs::NamedTuple, ::typeof(metalcall), pipeline::MTLComputePipelineState,
            types::Union{Tuple,Type}, args::Vararg{Any,N}) where {N} =
    metalcall_tuple(pipeline, types, args; kwargs...)

"""
    metalcall_tuple(pipeline, types, values::Tuple; kwargs...)

The same as [`metalcall`](@ref), but taking the values as a tuple, which is faster for
kernels with many arguments.
"""
metalcall_tuple(pipeline::MTLComputePipelineState, types::Tuple, args::Tuple; kwargs...) =
    metalcall_tuple(pipeline, Tuple{types...}, args; kwargs...)
function metalcall_tuple(pipeline::MTLComputePipelineState, types::Type{<:Tuple},
                         args::Tuple; groups=1, threads=1, queue=nothing,
                         submit::Bool=false, threadgroup_memory::Tuple=(),
                         resources::Tuple=())
    gs, ts = MTLSize(groups), MTLSize(threads)
    while true
        conflict = try_metalcall(pipeline, queue, gs, ts, types, args, threadgroup_memory,
                                 resources, submit)
        conflict === nothing && return
        synchronize(conflict)
    end
end

Base.@nospecializeinfer function try_metalcall(pipeline::MTLComputePipelineState,
                                               @nospecialize(queue), gs::MTLSize,
                                               ts::MTLSize, @nospecialize(types::Type),
                                               @nospecialize(args::Tuple),
                                               @nospecialize(threadgroup_memory::Tuple),
                                               @nospecialize(resources::Tuple),
                                               submit::Bool)
    bq = queue === nothing ? global_queue(device()) :
                             batched_queue(queue)::ConcreteBatchedQueue
    pipeline.device == bq.queue.device ||
        throw(ArgumentError("The pipeline belongs to a different device than the queue"))

    reqthreads = macos_version() >= v"26" ? pipeline.requiredThreadsPerThreadgroup :
                                            MTLSize(0, 0, 0)
    tgmem = Int(pipeline.staticThreadgroupMemoryLength)
    for len in threadgroup_memory
        (len >= 0 && len % 16 == 0) ||
            throw(ArgumentError("Threadgroup memory lengths must be non-negative multiples of 16 bytes, got $len"))
        tgmem += len
    end
    check_launch(gs, ts, reqthreads, Int(pipeline.maxTotalThreadsPerThreadgroup), tgmem)

    # (passed on `@nospecialize`d: a `Union{Nothing,NamedTuple}` reaching `record_operation!`
    # crashes the optimizer of Julia 1.10, see JuliaLang/julia#53590)
    op = MTL.profile_metadata[] === nothing ? nothing : pipeline_operation(pipeline, gs, ts)
    submit_launch!(pipeline, gs, ts, bq, types, nothing, nothing, args, threadgroup_memory,
                   resources, op, submit)
end

Base.@nospecializeinfer function pipeline_operation(pipeline::MTLComputePipelineState,
                                                    gs::MTLSize, ts::MTLSize)
    label = pipeline.label
    (; kind = :kernel, name = label === nothing ? "metalcall" : String(label),
       threadgroups = gs, threads = ts,
       tgmem = Int(pipeline.staticThreadgroupMemoryLength),
       maxthreads = Int(pipeline.maxTotalThreadsPerThreadgroup))
end

# Encode a launch of `pipeline` into the open batch of `bq`, and submit it if needed. `args`
# are bound to the parameters of `target`, a signature or a `HostKernel` (which also takes
# its kernel `state`, see `bind_arguments!`), and are kept alive with `source`, the callable
# of a `HostKernel`. `op` describes the launch to the profiler.
# Returns the memory of an argument that is still in use by another queue, if any, without
# encoding anything.
Base.@nospecializeinfer function submit_launch!(
        pipeline::MTLComputePipelineState, gs::MTLSize, ts::MTLSize, bq::BatchedCommandQueue,
        @nospecialize(target), @nospecialize(state::Union{Nothing,KernelState}),
        @nospecialize(source), @nospecialize(args::Tuple),
        @nospecialize(threadgroup_memory::Tuple), @nospecialize(resources::Tuple),
        @nospecialize(op), submit::Bool)
    conflict = Base.@lock submission_lock begin
        encode_launch!(pipeline, gs, ts, bq, target, state, source, args,
                       threadgroup_memory, resources, op)
    end
    conflict === nothing || return conflict

    submit ? flush!(bq) : maybe_autoflush!(bq)
    return
end

Base.@nospecializeinfer function encode_launch!(
        pipeline::MTLComputePipelineState, gs::MTLSize, ts::MTLSize, bq::BatchedCommandQueue,
        @nospecialize(target), @nospecialize(state::Union{Nothing,KernelState}),
        @nospecialize(source), @nospecialize(args::Tuple),
        @nospecialize(threadgroup_memory::Tuple), @nospecialize(resources::Tuple),
        @nospecialize(op))
    try
        cce = kernel_encoder!(bq, pipeline)
        isempty(resources) || declare_resources!(cce, bq, resources)
        bind_arguments!(cce, bq, target, state, args)
        isempty(threadgroup_memory) || bind_threadgroup_memory!(cce, threadgroup_memory)
        dispatch!(cce, pipeline, gs, ts)
    catch err
        # The failing launch has not been recorded yet. Keep any earlier
        # operations in this batch, but close encoder state dirtied by the
        # failed encode and drop an otherwise empty batch.
        end_encoder!(bq)
        bq.nops == 0 && discard_open_batch!(bq)
        err isa OwnershipConflict && return err.managed
        rethrow()
    end

    # The command buffer retains explicitly encoded buffers, but that doesn't keep other
    # resources alive for which we've encoded the GPU address ourselves.
    if isempty(resources)
        record_operation!(bq, source, args; op=op)
    else
        record_operation!(bq, source, args, resources; op=op)
    end
    return nothing
end

# (specialized on the tuples' types, so that each launch dispatches only once)
declare_resources!(cce, bq, ::Tuple{}) = nothing
function declare_resources!(cce, bq, resources::Tuple)
    declare_resource!(cce, bq, first(resources))
    declare_resources!(cce, bq, Base.tail(resources))
end
bind_threadgroup_memory!(cce, lengths::Tuple) =
    for (i, len) in enumerate(lengths)
        bind_threadgroup_memory!(cce, len, i)
    end

declare_resource!(cce, bq, buf::MTLBuffer) = make_resident!(cce, buf, MTL.ReadWriteUsage)
function declare_resource!(cce, bq, ptr::MtlPtr)
    claim!(ptr, bq)
    make_resident!(cce, ptr.buffer, MTL.ReadWriteUsage)
end
declare_resource!(cce, bq, xs::MtlArray) = declare_resource!(cce, bq, pointer(xs))
declare_resource!(cce, bq, x) =
    throw(ArgumentError("Resources should be MtlArray, MtlPtr or MTLBuffer objects, got a $(typeof(x))"))

@inline bind_arguments!(cce, bq, ::Type{TT}, ::Nothing, args::Tuple) where {TT} =
    bind_arguments!(cce, bq, TT, (), args)

# Keep the generator body unspecialized and use vectors so it compiles once for all
# signatures. Define it before the generator so it is visible in the generator's world.
function bind_arguments_body(@nospecialize(TT), @nospecialize(head), @nospecialize(args))
    types = collect(Any, TT.parameters)
    nhead = fieldcount(head)
    nargs = fieldcount(args)
    if length(types) != nhead + nargs
        msg = "Kernel expects $(length(types) - nhead) arguments, got $nargs"
        return :(throw(ArgumentError($msg)))
    end
    vals = Any[Any[:(head[$i]) for i in 1:nhead]; Any[:(args[$i]) for i in 1:nargs]]
    typs = append!(collect(Any, head.parameters), args.parameters)

    ex = quote end
    idx = 1
    for i in eachindex(types)
        dt, val, typ = types[i], vals[i], typs[i]
        (isghosttype(dt) || Core.Compiler.isconstType(dt)) && continue
        if dt <: Union{Ptr,Core.LLVMPtr,MtlPtr}
            # a GPU address can't be bound without the buffer it points into
            if !(typ <: Union{MTLBuffer,MtlPtr,MtlArray})
                msg = "Argument $(i - nhead) should be an MtlArray, MtlPtr or MTLBuffer to be bound to a pointer parameter, not a $typ"
                return :(throw(ArgumentError($msg)))
            end
            push!(ex.args, :(bind_pointer!(cce, bq, $val, $idx)))
        else
            push!(ex.args, :(convert_argument!(cce, bq, $dt, $val, $idx)))
        end
        idx += 1
    end
    push!(ex.args, :(return nothing))

    ex
end

# Bind the values `head` and `args` (which the user passed, counting from 1 in errors) to
# the parameters of a kernel with signature `TT`. Pointer-typed parameters are bound as
# buffers, others are passed by value (see `metalcall`).
@inline @generated function bind_arguments!(cce, bq, ::Type{TT}, head::Tuple,
                                            args::Tuple) where {TT}
    bind_arguments_body(TT, head, args)
end

@inline bind_pointer!(cce, bq, buf::MTLBuffer, idx::Integer) = bind_buffer!(cce, buf, 0, idx)
@inline function bind_pointer!(cce, bq, ptr::MtlPtr, idx::Integer)
    claim!(ptr, bq)
    bind_buffer!(cce, ptr.buffer, ptr.offset, idx)
end
@inline bind_pointer!(cce, bq, xs::MtlArray, idx::Integer) =
    bind_pointer!(cce, bq, pointer(xs), idx)

# Not inlined into `bind_arguments!`, which is compiled for every kernel signature, so that
# the conversion of each argument type is compiled once and shared between kernels.
@noinline convert_argument!(cce, bq, ::Type{T}, arg, idx::Integer) where {T} =
    set_argument!(cce, convert(T, mtlconvert(arg, cce, bq)), idx)


## host-side kernel API

"""
    HostKernel

A compiled kernel, as returned by [`mtlfunction`](@ref) or `@metal launch=false`. Launch it
by calling it (see below). Its fields describe the compute pipeline Metal created for it:

- `maxthreads`: the maximum number of threads per threadgroup this kernel can be launched
  with ([`maxTotalThreadsPerThreadgroup`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/maxtotalthreadsperthreadgroup)),
  which can be lower than the device's limit of 1024 for kernels that use many registers.
- `exec_width`: the thread execution width, i.e., the number of threads in a SIMD-group
  ([`threadExecutionWidth`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/threadexecutionwidth)).
  Threadgroup sizes that are a multiple of it use the GPU best.
- `tgmem`: the amount of threadgroup memory, in bytes, that the kernel allocates
  statically (with [`MtlThreadGroupArray`](@ref)).
- `pipeline`: the [`MTLComputePipelineState`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate),
  for other properties.

```julia
kernel = @metal launch=false vadd(c, a, b)
threads = min(length(c), kernel.maxthreads)
kernel(c, a, b; threads, groups=cld(length(c), threads))
```
"""
struct HostKernel{F,S,TT}
    f::F
    # the callable before conversion, which is converted again at every launch: only then
    # can the buffers it captures be declared to the command encoder, and holding on to it
    # keeps those buffers alive for as long as the kernel object and its launches need them.
    source::S
    pipeline::MTLComputePipelineState
    loggingEnabled::Bool
    # whether the kernel uses the device RNG, and thus needs a seed from the host RNG
    device_rng::Bool
    device::MTLDevice
    maxthreads::Int
    # the threadgroup size launches have to use (`minthreads`), or all zeros
    reqthreads::MTLSize
    tgmem::Int
    exec_width::Int
    use_residency_sets::Bool
    # this session's relocation words, or `nothing` for a relocation-free kernel. The buffer
    # keeps the storage alive; `launch` passes its address in the `KernelState` and declares
    # it resident, since only the address (not the buffer) is encoded.
    reloc_table::Union{Nothing,MTLBuffer}
end

const mtlfunction_lock = ReentrantLock()

"""
    mtlfunction(f, tt=Tuple{}; kwargs...)::HostKernel

Compile `f` for argument types `tt` (the types after [`mtlconvert`](@ref)) for the current
device, and return the kernel as a [`HostKernel`](@ref). This is what [`@metal`](@ref) uses;
call it directly to compile without converting arguments.

The compiler keywords of [`@metal`](@ref) are supported, and:

- `macos` and `metal`: the deployment target (macOS 15 or later) and Metal Shading Language
  version to compile for, which default to the newest the host supports
  ([`Metal.metal_target`](@ref)). A language version that needs a newer macOS raises the
  deployment target. Code for versions the host doesn't support can be generated and
  inspected, but not loaded. Targeting Metal 3.1 or older rules out barrier and fence
  scopes, and ordered atomics.
- `air`: the AIR bitcode version, which otherwise follows the deployment target. Meant for
  testing.
- `gpufamily`: the Apple GPU family (`MTL.MTLGPUFamilyApple<n>`) that the generated code may
  rely on (see [`apple_family`](@ref)). Defaults to the highest family the device supports.
- `source`: the callable before [`mtlconvert`](@ref) turned it into `f`, which is converted
  again at every launch (so it should convert to an object of the same type as `f`).
  Defaults to `f`, but should be set when `f` captures GPU arrays, so that their buffers are
  made available to the GPU and kept alive as long as the kernel is in use.

The result is cached, so calling `mtlfunction` in a hot path is cheap. Code is regenerated
when `f` is redefined, or for different types or keyword arguments.
"""
function mtlfunction(f::F, tt::TT=Tuple{}; source::S=f, kwargs...) where {F,TT,S}
    # `MTLDevice` compares with `isEqual:`, so key on its (process-lifetime) handle instead.
    # the key holds copies of arrays, like a vector `minthreads`, which the caller may mutate.
    dev = pointer(device())
    kw = values(kwargs)
    options = map(v -> v isa AbstractArray ? copy(v) : v, kw)
    l = GPUCompiler.cached_lookup(KernelLinker(F, tt, kw), LinkedKernel, F, tt,
                                  (dev, options))
    HostKernel{F,S,tt}(f, source, l.pipeline, l.loggingEnabled, l.device_rng, l.device,
                       l.maxthreads, l.reqthreads, l.tgmem, l.exec_width,
                       l.use_residency_sets, l.reloc_table)
end

# What `mtlfunction` calls when the kernel isn't cached: a callable struct rather than a
# closure, whose type would depend on the kernel's, compiling it (and the inlined
# `methodinstance`) again for every kernel.
struct KernelLinker{K}
    ft::Type
    tt::Type
    kw::K
end
(l::KernelLinker)() = link_kernel(methodinstance(l.ft, l.tt); l.kw...)

# The fields of `HostKernel` following `f` and `source`, which only depend on the kernel's
# type, the device and the compiler keywords, which is what `mtlfunction` caches.
struct LinkedKernel
    pipeline::MTLComputePipelineState
    loggingEnabled::Bool
    device_rng::Bool
    device::MTLDevice
    maxthreads::Int
    reqthreads::MTLSize
    tgmem::Int
    exec_width::Int
    use_residency_sets::Bool
    reloc_table::Union{Nothing,MTLBuffer}
end

# Everything about creating a kernel object that doesn't depend on the kernel's type, kept
# out of `mtlfunction`, which is compiled for every kernel.
@noinline function link_kernel(mi::Core.MethodInstance; name=nothing, kwargs...)
    Base.@lock mtlfunction_lock begin
        dev = device()
        config = compiler_config(dev; name, kwargs...)::MetalCompilerConfig
        job = CompilerJob(mi, config)

        res = compile_or_lookup(job)::MetalResults

        # Resolve the MTLComputePipelineState for the active device. Linear scan
        # over the session-local cache; almost always n=1, one `===` compare.
        pipeline = Ref{MTLComputePipelineState}()
        @inbounds for (cached_dev, cached_pipeline) in res.pipelines
            if cached_dev === dev
                pipeline[] = cached_pipeline
                break
            end
        end
        # name the pipeline after the kernel's signature only when labelling resources:
        # computing it compiles a lot of printing code on first use
        label = label_resources() ? kernel_label(mi) : res.entry::String
        if !isassigned(pipeline)
            check_loadable(config.target)
            pipeline[] = link_pipeline(dev, res.air::Vector{UInt8},
                                     res.metallib::Vector{UInt8},
                                     res.entry::String, job.config.target.minthreads,
                                     label)
            # Don't cache session-local pipeline handles while precompiling: the
            # results struct is serialized into the package image along with its
            # CodeInstance, and ObjectiveC handles would come back dangling.
            if ccall(:jl_generating_output, Cint, ()) != 1
                push!(res.pipelines, (dev, pipeline[]))
            end
        end

        # Same for the relocation words, which only a kernel referencing a host object needs.
        relocations = res.relocations
        reloc_table = nothing
        if relocations !== nothing
            @inbounds for (cached_dev, cached_buf) in res.reloc_tables
                if cached_dev === dev
                    reloc_table = cached_buf
                    break
                end
            end
            if reloc_table === nothing
                reloc_table = reloc_table_buffer(dev, relocations, label)
                if ccall(:jl_generating_output, Cint, ()) != 1
                    push!(res.reloc_tables, (dev, reloc_table))
                end
            end
        end

        # normalized by `compiler_config`; asserted to keep `link_kernel` inferable
        minthreads = job.config.target.minthreads::Union{Nothing,NTuple{3,Int}}
        reqthreads = minthreads === nothing ? MTLSize(0, 0, 0) : MTLSize(minthreads)

        LinkedKernel(pipeline[], res.loggingEnabled::Bool, res.device_rng::Bool, dev,
         Int(pipeline[].maxTotalThreadsPerThreadgroup),
         reqthreads,
         Int(pipeline[].staticThreadgroupMemoryLength),
         Int(pipeline[].threadExecutionWidth),
         can_use_residency_sets(dev),
         reloc_table)
    end
end

# Look up cached compile artifacts for `job`, compiling on miss. Storage is managed
# by `GPUCompiler.cached_results` (Julia's integrated code cache on 1.11+, which also
# persists artifacts through precompilation; a session-local store on 1.10).
#
# `metallib === nothing` identifies a `MetalResults` that hasn't been compiled yet —
# either freshly created, or (on 1.11+) loaded from a package image whose precompile
# workload only inferred the kernel without compiling it. Every lookup is reported to
# the `@device_code_*` hook, so reflection observes cached kernels without recompiling
# them.
# Specialize on the target/parameter types so callers can avoid boxing CompilerJob.
# Keep the body out of callers that specialize per kernel.
@noinline function compile_or_lookup(job::CompilerJob)::MetalResults
    GPUCompiler.run_compile_hook(job)
    res = GPUCompiler.cached_results(MetalResults, job)
    if res === nothing || res.metallib === nothing
        artifacts = @signpost_interval log=log_compiler() start=kernel_label(job.source) stop="" "Compile" begin
            compile_to_metallib(job)
        end
        res = @something res GPUCompiler.cached_results(MetalResults, job)
        res.air = artifacts.air
        res.metallib = artifacts.metallib
        res.entry = artifacts.entry
        res.loggingEnabled = artifacts.loggingEnabled
        res.device_rng = artifacts.device_rng
        res.relocations = artifacts.relocations
    end
    return res
end

## kernel launching and argument encoding

# A kernel's parameters are the kernel state, the callable and the arguments, in that order.
# Which of those values occupy a parameter slot is decided by the kernel's compiled
# signature, which holds their converted types: the unconverted ones don't tell, e.g., a
# `Base.Fix1` capturing a type converts to a ghost closure. The callable and arguments are
# converted when binding them, with the encoder, so that the buffers they contain are
# declared to it.
@inline bind_arguments!(cce, bq, kernel::HostKernel, state::KernelState, args::Tuple) =
    bind_arguments!(cce, bq, kernel_signature(kernel), (state, kernel.source), args)
@generated kernel_signature(::HostKernel{F,S,TT}) where {F,S,TT} =
    Tuple{KernelState, F, TT.parameters...}

@inline function set_argument!(cce, arg, idx::Integer)
    argtyp = typeof(arg)

    # A non-isbits argument has no fields the kernel could read — compilation would have
    # failed otherwise — so it is only usable by identity, e.g. `sym === :foo`. Pass the
    # object's address, which is the identity word GPUCompiler lowers such a parameter to,
    # and which the kernel compares against its own resolved relocation for that value.
    if !isbitstype(argtyp)
        arg = ccall(:jl_value_ptr, Ptr{Cvoid}, (Any,), arg)
        argtyp = Ptr{Cvoid}
    end

    ref = Base.RefValue(arg)
    GC.@preserve ref begin
        ptr = Base.unsafe_convert(Ptr{argtyp}, ref)
        bind_bytes!(cce, reinterpret(Ptr{Cvoid}, ptr), sizeof(argtyp), idx)
    end
    return
end

"""
    (kernel::HostKernel)(args...; threads=1, groups=1, queue=global_queue(device()),
                         submit=false)

Launch `kernel` with arguments `args`, which have to have the same types as the ones it was
compiled for. The keyword arguments are the launch keywords of [`@metal`](@ref).
"""
(kernel::HostKernel)(args...; kwargs...) = launch_kernel(kernel, args; kwargs...)

# what calling a `HostKernel` does, compiled once for all kernels and arguments rather
# than for the type of every kernel the user defines
Base.@nospecializeinfer function launch_kernel(@nospecialize(kernel::HostKernel),
                                               @nospecialize(args::Tuple); groups=1,
                                               threads=1, queue=nothing, submit::Bool=false)
    gs, ts = MTLSize(groups), MTLSize(threads)
    while true
        conflict = try_launch(kernel, queue, gs, ts, args, submit)
        conflict === nothing && return
        synchronize(conflict)
    end
end

Base.@nospecializeinfer function try_launch(@nospecialize(kernel::HostKernel), @nospecialize(queue),
                                            gs::MTLSize, ts::MTLSize,
                                            @nospecialize(args::Tuple), submit::Bool)
    @signpost_interval log=log_tracing() start=launch_message(kernel, gs, ts) stop="" "Launch" begin
        launch_with_queue(kernel, queue, gs, ts, args, submit)
    end
end

# the pipeline is labelled with the kernel's Julia signature by `link_pipeline`
Base.@nospecializeinfer function launch_message(@nospecialize(kernel::HostKernel),
                                                gs::MTLSize, ts::MTLSize)
    label = kernel.pipeline.label
    name = if label === nothing
        f = kernel.f
        string(f isa Function ? nameof(f) : typeof(f))
    else
        String(label)
    end::String
    name * " groups=(" * size_string(gs) * ") threads=(" * size_string(ts) * ")"
end
# concatenation is several times faster than `string` with many arguments
size_string(sz::MTLSize) =
    string(sz.width) * "," * string(sz.height) * "," * string(sz.depth)

Base.@nospecializeinfer @inline function launch_with_queue(
        @nospecialize(kernel::HostKernel), ::Nothing, gs::MTLSize, ts::MTLSize,
        @nospecialize(args::Tuple), submit::Bool)
    launch(kernel, gs, ts, global_queue(device()), args, submit)
end

Base.@nospecializeinfer @inline function launch_with_queue(
        @nospecialize(kernel::HostKernel), queue, gs::MTLSize, ts::MTLSize,
        @nospecialize(args::Tuple), submit::Bool)
    # (asserting the queue type keeps inference from specializing the launch path on an
    #  abstract queue type)
    launch(kernel, gs, ts, batched_queue(queue)::ConcreteBatchedQueue, args, submit)
end

Base.@nospecializeinfer function kernel_operation(@nospecialize(kernel::HostKernel),
                                                  gs::MTLSize, ts::MTLSize)
    (; kind = :kernel, name = string(nameof(kernel.f)),
       threadgroups = gs, threads = ts,
       tgmem = kernel.tgmem, maxthreads = kernel.maxthreads)
end

# logging needs a command buffer of its own, with a log state, so it bypasses the batch.
# that's a Metal 3 command buffer, also with the Metal 4 backend: logging isn't performance
# critical, so it doesn't need a Metal 4 implementation of its own.
Base.@nospecializeinfer function launch_logging!(
        @nospecialize(kernel::HostKernel), gs::MTLSize, ts::MTLSize,
        bq::BatchedCommandQueue, @nospecialize(args::Tuple), kernel_state, buf, exc)
    flush!(bq)
    queue = bq.queue

    if is_virtual(queue.device)
        # `MTLLogState` needs a residency set, which the paravirtualized GPU driver
        # cannot create (failing with `MTLLogStateErrorDomain` code 2). Bail out here
        # with a clear host error instead of surfacing that opaque `NSError`.
        error("Capturing GPU log output is not supported on virtualized GPUs.")
    end

    MTLCaptureManager().isCapturing &&
        error("Logging is not supported while GPU frame capturing")

    log_state_descriptor = MTLLogStateDescriptor()
    log_state_descriptor.level = MTL.MTLLogLevelDebug
    log_state = MTLLogState(queue.device, log_state_descriptor)

    function log_handler(subSystem, category, logLevel, message)
        Core.print(String(NSString(message)))
        return nothing
    end

    block = @objcblock(log_handler, Nothing, (id{NSString}, id{NSString}, NSInteger, id{NSString}))
    @objc [log_state::id{MTLLogState} addLogHandler:block::id{NSBlock}]::Nothing

    cmdbuf_descriptor = MTLCommandBufferDescriptor()
    cmdbuf_descriptor.logState = log_state
    cmdbuf = MTLCommandBuffer(queue, cmdbuf_descriptor)
    @label! cmdbuf "MTLCommandBuffer($(nameof(kernel.f)))"
    let md = MTL.profile_metadata[]
        md === nothing || MTL.note_operation!(md, cmdbuf, kernel_operation(kernel, gs, ts))
    end

    Base.@lock submission_lock begin
        cce = MTLComputeCommandEncoder(cmdbuf)
        try
            MTL.set_function!(cce, kernel.pipeline)
            # (only Metal 3 queues have a residency set with the scratch buffers)
            if !kernel.use_residency_sets || bq isa Metal4Queue
                MTL.use!(cce, buf, MTL.ReadWriteUsage)
                MTL.use!(cce, exc, MTL.ReadWriteUsage)
            end
            let reloc = kernel.reloc_table
                reloc === nothing || MTL.use!(cce, reloc, MTL.ReadUsage)
            end
            bind_arguments!(cce, bq, kernel, kernel_state, args)
            dispatch!(cce, kernel.pipeline, gs, ts)
        catch err
            err isa OwnershipConflict && return err.managed
            rethrow()
        finally
            close(cce)
        end

        # the batch was flushed above, so commit directly instead of via the submission
        # hook, which may wait for the GPU and must not be called with the lock held
        order_external!(bq)
        MTL.commit_with_queue_key!(cmdbuf, pointer(queue))
        defer_cleanup!(bq, cmdbuf, Any[kernel.source, args])
    end
    track_logging_cmdbuf!(queue, cmdbuf)
    return
end

Base.@nospecializeinfer function launch(
        @nospecialize(kernel::HostKernel), gs::MTLSize, ts::MTLSize,
        bq::BatchedCommandQueue, @nospecialize(args::Tuple), submit::Bool)
    check_launch(gs, ts, kernel.reqthreads, kernel.maxthreads, kernel.tgmem)
    dev = kernel.device

    buf, buf_addr = malloc_buffer_and_gpu_address(dev)
    buf_ptr = reinterpret(Core.LLVMPtr{UInt8, AS.Device}, buf_addr)
    exc, exc_addr = exception_info_buffer_and_gpu_address(dev)
    exc_ptr = reinterpret(Core.LLVMPtr{UInt8, AS.Device}, exc_addr)
    reloc = kernel.reloc_table
    reloc_ptr = reinterpret(Core.LLVMPtr{UInt64, AS.Device},
                            reloc === nothing ? UInt64(0) : UInt64(MTL.gpu_address(reloc)))
    # (drawing a seed for every launch would make the host RNG stream depend on how many
    # kernels ran, breaking reproducibility of seeded host code)
    seed = kernel.device_rng ? Random.rand(UInt32) : UInt32(0)
    kernel_state = KernelState(seed, buf_ptr, exc_ptr, reloc_ptr)

    if kernel.loggingEnabled
        return launch_logging!(kernel, gs, ts, bq, args, kernel_state, buf, exc)
    end

    # The kernel state holds GPU addresses to per-device scratch buffers (malloc bump
    # allocator, exception mailbox) that aren't otherwise bound to the encoder. Declare
    # them so Metal Shader Validation tracks the accesses instead of dropping them. The
    # relocation table is per-kernel, so it cannot join the queue's residency set (which
    # only holds the scratch buffers): declare it every launch.
    resources = if kernel.use_residency_sets
        reloc === nothing ? () : (reloc,)
    else
        reloc === nothing ? (buf, exc) : (buf, exc, reloc)
    end

    op = MTL.profile_metadata[] === nothing ? nothing : kernel_operation(kernel, gs, ts)
    submit_launch!(kernel.pipeline, gs, ts, bq, kernel, kernel_state, kernel.source, args, (),
                   resources, op, submit)
end

# check a launch configuration against the pipeline's limits (`reqthreads` all zeros when
# it doesn't require a threadgroup size), with `tgmem` the threadgroup memory it uses
function check_launch(gs::MTLSize, ts::MTLSize, reqthreads::MTLSize, maxthreads::Int,
                      tgmem::Int)
    (gs.width>0 && gs.height>0 && gs.depth>0) ||
        throw(ArgumentError("All group dimensions should be non-zero"))
    (ts.width>0 && ts.height>0 && ts.depth>0) ||
        throw(ArgumentError("All thread dimensions should be non-zero"))

    # Metal only checks this in its debug layer; other sizes otherwise silently misbehave
    if reqthreads.width > 0 && ts != reqthreads
        throw(ArgumentError("Threads in group ($(Int(ts.width)), $(Int(ts.height)), $(Int(ts.depth))) should equal the kernel's minthreads ($(Int(reqthreads.width)), $(Int(reqthreads.height)), $(Int(reqthreads.depth)))"))
    end

    nthreads = ts.width * ts.height * ts.depth
    nthreads > maxthreads &&
        throw(ArgumentError("Number of threads in group ($nthreads) should not exceed $maxthreads"))

    (gs.width * ts.width) > typemax(UInt32) &&
        throw(ArgumentError("Total threads per grid in a dimension (groups.width($(gs.width)) * threads.width($(ts.width)) = $(gs.width * ts.width)) must not exceed $(typemax(UInt32))"))
    (gs.height * ts.height) > typemax(UInt32) &&
        throw(ArgumentError("Total threads per grid in a dimension (groups.height($(gs.height)) * threads.height($(ts.height)) = $(gs.height * ts.height)) must not exceed $(typemax(UInt32))"))
    (gs.depth * ts.depth) > typemax(UInt32) &&
        throw(ArgumentError("Total threads per grid in a dimension (groups.depth($(gs.depth)) * threads.depth($(ts.depth)) = $(gs.depth * ts.depth)) must not exceed $(typemax(UInt32))"))

    tgmem > 32768 &&
        throw(ArgumentError("Total used threadgroupMemoryLength($tgmem) must be <= 32768 bytes."))
    return
end

# Dispatch the kernel through the backend's encoding context `ctx`, wrapped (when labelling
# resources) in a debug group named after the pipeline, which `link_pipeline` labelled with
# the kernel's Julia signature: a batched command buffer interleaves many kernels in one
# encoder, and the debug groups tell them apart in a GPU frame capture.
@inline function dispatch!(ctx, pipeline::MTLComputePipelineState, gs::MTLSize, ts::MTLSize)
    if label_resources()
        label = pipeline.label
        if label === nothing
            dispatch!(ctx, gs, ts)
        else
            # the encoder gets closed after a failed launch, so keep the groups balanced
            MTL.push_debug_group!(ctx, label)
            try
                dispatch!(ctx, gs, ts)
            finally
                MTL.pop_debug_group!(ctx)
            end
        end
    else
        dispatch!(ctx, gs, ts)
    end
    return
end

## SIMD-group helpers

"""
    nextwarp(kernel, threads)
    prevwarp(kernel, threads)

Round `threads` up or down to a multiple of the thread execution width (the SIMD-group size)
of `kernel`, a [`HostKernel`](@ref) or `MTLComputePipelineState`.
"""
function nextwarp(pipe::MTLComputePipelineState, threads::Integer)
    ws = pipe.threadExecutionWidth
    return threads + (ws - threads % ws) % ws
end

function nextwarp(kernel::HostKernel, threads::Integer)
    ws = kernel.exec_width
    return threads + (ws - threads % ws) % ws
end

@doc (@doc nextwarp) function prevwarp(pipe::MTLComputePipelineState, threads::Integer)
    ws = pipe.threadExecutionWidth
    return threads - Base.rem(threads, ws)
end

@doc (@doc nextwarp) function prevwarp(kernel::HostKernel, threads::Integer)
    ws = kernel.exec_width
    return threads - Base.rem(threads, ws)
end
