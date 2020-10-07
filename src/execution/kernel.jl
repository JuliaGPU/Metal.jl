abstract type AbstractKernel{F,TT} end

struct Kernel{F,TT}
    device::MtlDevice
    mod::MtlLibrary
    fun::MtlFunction
end

#launchKernel

##########################################
# Blocking call to a kernel
# Should implement somethjing better
mtlcall(f::MtlFunction, types::Tuple, args...; kwargs...) =
    mtlcall(f, Base.to_tuple_type(types), args...; kwargs...)

function mtlcall(f::MtlFunction, types::Type, args...; kwargs...)
    convert_arguments(types, args...) do pointers...
        launch(f, pointers...; kwargs...)
    end
end

##############################################
# Enqueue a function for execution
#
function enqueue_function(f::MtlFunction, args...;
                blocks::MtlDim=1, threads::MtlDim=1,
                cce::MtlComputeCommandEncoder)
    blocks = MtlDim3(blocks)
    threads = MtlDim3(threads)
    (blocks.x>0 && blocks.y>0 && blocks.z>0)    || throw(ArgumentError("Grid dimensions should be non-null"))
    (threads.x>0 && threads.y>0 && threads.z>0) || throw(ArgumentError("Thread dimensions should be non-null"))
    all(threads .< f.maxTotalThreadsPerThreadgroup) || throw(ArgumentError("Max Thread dimension is $(f.maxTotalThreadsPerThreadgroup)"))

    # Set the function that we are currently encoding
    MetalCore.set_function!(cce, f)
    # Encode all arguments
    MetalCore.encode_arguments!(cce, f, args...)
    # Flush everything
    MetalCore.append_current_function!(cce, blocks, threads)
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
    set_bytes!(cce, sizeof(C_NULL), C_NULL, idx-1)
    return cce
end

function encode_argument!(cce::MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, arg::MtlBuffer)
    @assert idx > 0
    set_buffer!(cce, buf, 0, idx-1)
    return cce
end

function encode_argument!(enc::Metal.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, val::T) where T
    @assert idx > 0 "Kernel idx must be bigger 0"
    #if does not contain a buffer we can use setbytes
    if !contains_mtlbuffer(T)
        ref, tsize = to_mtl_ref(val)
        set_bytes!(cce, ref, tsize, idx-1)
    else
        #otherwise, we need an argument buffer
        throw("Not implemented: If an argument contains a mtlbuffer automatic aragument encoding is not yet supported.")

        # create an encoder to write into the argument buffer
        argbuf_enc = MtlArgumentEncoder(f, idx)
        # allocate the argument buffer
        argbuf = alloc(Cchar, device(enc), sizeof(argbuf_enc), storage=Shared)
        # assign the argument buffer to the encoder
        Metal.assign_argument_buffer!(argbuf_enc, argbuf, 1)

        # TODO Implement automatic conversion of struct into a assign_argument_buffer

        #for field in val 
        #    Metal.set_field!(argbuf_enc, size(val), 1)
        #    set_buffer!(argbuf_enc, pointer(val), 0, 2)
        #end

        # set argubuf_enc into cce        
    end
    return cce
end

function encode_argument!(enc::Metal.MtlComputeCommandEncoder, f::MtlFunction, idx::Integer, val::MtlDeviceArray)
    @assert contains_mtlbuffer(typeof(val))

    # create an encoder to write into the argument buffer
    argbuf_enc = MtlArgumentEncoder(f, idx)
    # allocate the argument buffer
    argbuf = alloc(Cchar, device(enc), sizeof(argbuf_enc), storage=Shared)
    # assign the argument buffer to the encoder
    Metal.assign_argument_buffer!(argbuf_enc, argbuf, 1)

    #
    Metal.set_field!(argbuf_enc, size(val), 1)
    set_buffer!(argbuf_enc, pointer(val), 0, 2)

    Metal.use!(enc, pointer(val), Metal.ReadWriteUsage)

    set_buffer!(enc, argbuf, 0, idx)
    @info "Leaked temporary argument buffer $(argbuf.handle) for argument #$idx"
    #TODO memmgmt
    return argbuf
end
