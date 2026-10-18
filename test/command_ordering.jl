# Program order between the work batched by Metal.jl and command buffers that are
# submitted to the Metal 3 queue it batches for (as MPS does). With the Metal 4 backend,
# those are different queues, ordered by events.

# takes a while, so that a missing dependency is likely to be noticed. the loop's result
# is stored in `scratch` so that it isn't optimized away.
function ordering_write_kernel(A, val, scratch, iterations)
    i = thread_position_in_grid().x
    if i <= length(A)
        x = i % UInt32
        for _ in 1:iterations
            x = x * UInt32(1664525) + UInt32(1013904223)
        end
        @inbounds scratch[i] = x
        @inbounds A[i] = val
    end
    return
end

function ordering_copy_kernel(B, A)
    i = thread_position_in_grid().x
    if i <= length(A)
        @inbounds B[i] = A[i] + Int32(1)
    end
    return
end

blit_fill!(cmdbuf, A::MtlArray, value::UInt8) =
    MTL.MTLBlitCommandEncoder(cmdbuf) do enc
        buf = Base.unsafe_convert(MTL.MTLBuffer, A)
        MTL.append_fillbuffer!(enc, buf, value, sizeof(A), A.offset)
    end

blit_copy!(cmdbuf, B::MtlArray, A::MtlArray) =
    MTL.MTLBlitCommandEncoder(cmdbuf) do enc
        MTL.append_copy!(enc, Base.unsafe_convert(MTL.MTLBuffer, B), B.offset,
                         Base.unsafe_convert(MTL.MTLBuffer, A), A.offset, sizeof(A))
    end

const ordering_n = 1 << 16
const ordering_iterations = 20_000
const ordering_scratch = MtlArray{UInt32,1,Metal.PrivateStorage}(undef, ordering_n)

@testset "command buffers after batched work" begin
    queue = global_queue(device())
    A = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    B = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    for iter in 1:3
        @metal threads=256 groups=cld(ordering_n, 256) ordering_write_kernel(A, Int32(iter), ordering_scratch, ordering_iterations)
        cmdbuf = MTL.MTLCommandBuffer(queue)
        blit_copy!(cmdbuf, B, A)
        MTL.commit!(cmdbuf)
        synchronize(queue)
        @test all(==(iter), Array(B))
    end
end

@testset "batched work after command buffers" begin
    queue = global_queue(device())
    A = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    B = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    # delays the fill of `A`, as the commands of a Metal 3 blit encoder execute in order
    delay = MtlArray{UInt8,1,Metal.PrivateStorage}(undef, 256 * 1024 * 1024)
    for value in (0x01, 0x02, 0x03)
        cmdbuf = MTL.MTLCommandBuffer(queue)
        MTL.MTLBlitCommandEncoder(cmdbuf) do enc
            buf = Base.unsafe_convert(MTL.MTLBuffer, delay)
            MTL.append_fillbuffer!(enc, buf, value, sizeof(delay), 0)
            buf = Base.unsafe_convert(MTL.MTLBuffer, A)
            MTL.append_fillbuffer!(enc, buf, value, sizeof(A), A.offset)
        end
        MTL.commit!(cmdbuf)
        @metal threads=256 groups=cld(ordering_n, 256) ordering_copy_kernel(B, A)
        synchronize(queue)
        expected = reinterpret(Int32, fill(value, 4))[1] + Int32(1)
        @test all(==(expected), Array(B))
    end
end

@testset "batched work after command buffers on a new queue" begin
    # the Metal 3 queue is used before Metal.jl batches any work for it. (repeated, as
    # compiling the first launch can hide a missing dependency)
    delay = MtlArray{UInt8,1,Metal.PrivateStorage}(undef, 256 * 1024 * 1024)
    for _ in 1:3
        queue = MTL.MTLCommandQueue(device())
        # (new memory is zeroed, so start from something else)
        A = Metal.fill(Int32(42), ordering_n; storage=Metal.PrivateStorage)
        B = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
        synchronize()
        cmdbuf = MTL.MTLCommandBuffer(queue)
        MTL.MTLBlitCommandEncoder(cmdbuf) do enc
            MTL.append_fillbuffer!(enc, Base.unsafe_convert(MTL.MTLBuffer, delay), 0x01,
                                   sizeof(delay), 0)
            MTL.append_fillbuffer!(enc, Base.unsafe_convert(MTL.MTLBuffer, A), 0x00,
                                   sizeof(A), A.offset)
        end
        MTL.commit!(cmdbuf)
        @metal threads=256 groups=cld(ordering_n, 256) queue=queue ordering_copy_kernel(B, A)
        synchronize(queue)
        @test all(==(1), Array(B))
    end
end

@testset "work batched while a command buffer is enqueued" begin
    # the command buffer has taken its place in the queue, so work batched afterwards
    # executes after it, also when it's committed later
    queue = global_queue(device())
    A = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    cmdbuf = MTL.MTLCommandBuffer(queue)
    MTL.enqueue!(cmdbuf)
    @metal threads=256 groups=cld(ordering_n, 256) ordering_write_kernel(A, Int32(7), ordering_scratch, ordering_iterations)
    blit_fill!(cmdbuf, A, 0x00)
    MTL.commit!(cmdbuf)
    synchronize(queue)
    @test all(==(7), Array(A))
end

@testset "interleaved submissions" begin
    queue = global_queue(device())
    A = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    B = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    for iter in 1:4
        @metal threads=256 groups=cld(ordering_n, 256) ordering_write_kernel(A, Int32(iter), ordering_scratch, ordering_iterations)
        cmdbuf = MTL.MTLCommandBuffer(queue)
        blit_copy!(cmdbuf, B, A)
        MTL.commit!(cmdbuf)
        @metal threads=256 groups=cld(ordering_n, 256) ordering_copy_kernel(A, B)
    end
    synchronize(queue)
    @test all(==(5), Array(A))
end

@testset "freeing memory in use" begin
    # buffers freed while the GPU uses them stay alive until it's done
    queue = global_queue(device())
    B = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
    for _ in 1:4
        A = MtlArray{Int32,1,Metal.PrivateStorage}(undef, ordering_n)
        @metal threads=256 groups=cld(ordering_n, 256) ordering_write_kernel(A, Int32(3), ordering_scratch, ordering_iterations)
        @metal threads=256 groups=cld(ordering_n, 256) ordering_copy_kernel(B, A)
        Metal.unsafe_free!(A)
        # allocations may reuse freed memory
        C = Metal.zeros(Int32, ordering_n; storage=Metal.PrivateStorage)
        synchronize(queue)
        @test all(==(4), Array(B))
        @test all(iszero, Array(C))
    end
    GC.gc(true)
    device_synchronize()

    if global_queue(device()) isa Metal.Metal4Queue
        # with Metal 4, freed buffers leave the device's residency set (which retains
        # them) once the work that may use them is done
        A = Metal.zeros(Int32, ordering_n; storage=Metal.PrivateStorage)
        buf = Base.unsafe_convert(MTL.MTLBuffer, A)
        res = Metal.device_residency(device())
        @test Metal.is_resident(res, buf)
        A .+= Int32(1)
        Metal.unsafe_free!(A)
        device_synchronize()
        @test !Metal.is_resident(res, buf)
        @test !(@lock res.lock res.dirty)    # the removal was committed
    end
end

@testset "buffers not allocated by Metal.jl" begin
    # (only those allocated by Metal.jl are in the device's residency set)
    buf = MTL.MTLBuffer(device(), ordering_n * sizeof(Int32); storage=Metal.PrivateStorage)
    A = MtlArray{Int32,1}(buf, (ordering_n,))
    @metal threads=256 groups=cld(ordering_n, 256) ordering_write_kernel(A, Int32(5), ordering_scratch, ordering_iterations)
    @test all(==(5), Array(A))
end
