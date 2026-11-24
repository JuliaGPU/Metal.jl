struct EncodeFailure
    x::Int32
end

Adapt.adapt_structure(to::Metal.Adaptor, x::EncodeFailure) =
    to.cce === nothing ? x : error("intentional encode failure")

failed_encode_kernel(x) = return

function failed_batch_increment_kernel(A)
    A[1] += Int32(1)
    return
end

@testset "command queue batching" begin
    function increment_kernel(A)
        A[1] = A[1] + Int32(1)
        return
    end

    function write_kernel(A, value)
        A[1] = value
        return
    end

    queue = global_queue(device())
    A = MtlArray(Int32[0])
    synchronize(queue)

    for _ in 1:8
        @metal threads=1 queue=queue increment_kernel(A)
    end
    if !Metal.command_batching() || Metal.profiling_command_buffers()
        @test !Metal.has_open_batch(queue)
    elseif Metal.command_batching_ops() > 1
        @test queue.nops == 8
    end
    synchronize(queue)
    @test Array(A) == Int32[8]
    @test !Metal.has_open_batch(queue)

    @metal threads=1 queue=queue submit=true increment_kernel(A)
    @test !Metal.has_open_batch(queue)
    synchronize(queue)
    @test Array(A) == Int32[9]

    B = MtlArray(Int32[0])
    Metal.unsafe_copyto!(device(B), pointer(B), pointer(A), 1; queue, async=true)
    @metal threads=1 queue=queue increment_kernel(B)
    synchronize(queue)
    @test Array(B) == Int32[10]

    C = MtlArray{UInt8}(undef, 4)
    Metal.unsafe_fill!(device(C), pointer(C), UInt8(3), length(C); queue, async=true)
    synchronize(queue)
    @test Array(C) == fill(UInt8(3), 4)

    D = MtlArray(UInt8[0])
    synchronize(queue)
    @metal threads=1 queue=queue write_kernel(D, UInt8(1))
    cmdbuf = MTL.MTLCommandBuffer(queue)
    if !Metal.command_batching() || Metal.profiling_command_buffers()
        @test !Metal.has_open_batch(queue)
    elseif Metal.command_batching_ops() > 1
        @test queue.nops == 1
    end
    @metal threads=1 queue=queue write_kernel(D, UInt8(2))
    MTL.MTLBlitCommandEncoder(cmdbuf) do enc
        buf = Base.unsafe_convert(MTL.MTLBuffer, D)
        MTL.append_fillbuffer!(enc, buf, UInt8(3), sizeof(D), D.offset)
    end
    MTL.commit!(cmdbuf)
    synchronize(queue)
    @test Array(D) == UInt8[3]
end

@testset "batching policy of a queue" begin
    function policy_increment_kernel(A)
        A[1] = A[1] + Int32(1)
        return
    end
    A = MtlArray(Int32[0])
    batching = Metal.command_batching() && !Metal.profiling_command_buffers()
    n = Metal.command_batching_ops() + 1

    # without autoflush, the batch is committed by its owner only
    bq = BatchedCommandQueue(MTL.MTLCommandQueue(device()); autoflush=false)
    for _ in 1:n
        @metal threads=1 queue=bq policy_increment_kernel(A)
    end
    batching && @test bq.nops == n
    synchronize(bq)
    @test Array(A) == Int32[n]
    bq.autoflush = true
    for _ in 1:n
        @metal threads=1 queue=bq policy_increment_kernel(A)
    end
    @test bq.nops < n
    synchronize(bq)
    @test Array(A) == Int32[2n]

    # with one command buffer in flight, submitting waits for the previous one
    bq = BatchedCommandQueue(MTL.MTLCommandQueue(device()); inflight=1)
    for _ in 1:4
        @metal threads=1 queue=bq submit=true policy_increment_kernel(A)
        @test Metal.pending_cleanup_count(bq) == 0
    end
    synchronize(bq)
    @test Array(A) == Int32[2n + 4]
    @test_throws ArgumentError BatchedCommandQueue(MTL.MTLCommandQueue(device()); inflight=0)
    @test_throws ArgumentError bq.inflight = 0
end

@testset "committing an enqueued command buffer at the in-flight limit" begin
    function enqueued_increment_kernel(A)
        A[1] = A[1] + Int32(1)
        return
    end
    # without batching, the launch itself waits for the limit, and thus for `cmdbuf`
    if Metal.command_batching() && !Metal.profiling_command_buffers()
        A = MtlArray(Int32[0])
        # the batch that committing `cmdbuf` flushes is queued behind it, so it can only
        # complete once `cmdbuf` is committed
        bq = BatchedCommandQueue(MTL.MTLCommandQueue(device()); inflight=1, autoflush=false)
        global_queue!(bq) do
            cmdbuf = MTL.MTLCommandBuffer(bq.queue)
            MTL.enqueue!(cmdbuf)
            @metal threads=1 enqueued_increment_kernel(A)
            MTL.commit!(cmdbuf)
        end
        synchronize(bq)
        @test Array(A) == Int32[1]
    end
end

function inject_command_buffer_error!(queue, info)
    key = pointer(queue)
    Base.@lock MTL.last_committed_lock begin
        state = get!(MTL.submission_state_per_queue, key) do
            MTL.QueueSubmissionState()
        end
        if state.errors === nothing
            state.errors = [info]
        else
            push!(state.errors, info)
        end
    end
    return
end

@testset "command buffer error accounting" begin
    @testset "deterministic pruning" begin
        pending = collect(1:5)
        errors = String[]
        MTL._prune_completed_submissions!(pending, errors,
                                          x -> x <= 4,
                                          x -> iseven(x) ? "failure $x" : nothing)
        @test pending == [5]
        @test errors == ["failure 2", "failure 4"]

        pending = collect(1:3)
        errors = MTL._prune_completed_submissions!(pending, nothing,
                                                   x -> x <= 2,
                                                   _ -> nothing)
        @test pending == [3]
        @test errors === nothing
    end

    @testset "successful direct submissions and bounded retention" begin
        queue = MTL.MTLCommandQueue(device())
        for _ in 1:64
            cmdbuf = MTL.MTLCommandBuffer(queue)
            MTL.commit!(cmdbuf)
            MTL.wait_completed(cmdbuf)
            @test MTL.pending_submission_count(queue) <= 1
        end
        @test synchronize(queue) === nothing
        @test MTL.pending_submission_count(queue) == 0
    end

    @testset "earlier failure and duplicate suppression" begin
        queue = MTL.MTLCommandQueue(device())
        queue.label = "error accounting queue"

        earlier = MTL.MTLCommandBuffer(queue)
        earlier.label = "failed earlier command buffer"
        MTL.commit!(earlier)
        MTL.wait_completed(earlier)

        info = MTL.CommandBufferErrorInfo("MTLCommandBufferErrorDomain", 2,
                                          "The GPU operation timed out",
                                          String(earlier.label), String(queue.label))
        inject_command_buffer_error!(queue, info)

        later = MTL.MTLCommandBuffer(queue)
        MTL.commit!(later)
        err = try
            synchronize(queue)
            nothing
        catch exc
            exc
        end
        @test err isa Metal.CommandBufferError
        @test only(err.errors) == info
        message = sprint(showerror, err)
        @test occursin("MTLCommandBufferErrorDomain", message)
        @test occursin("code 2", message)
        @test occursin("The GPU operation timed out", message)
        @test occursin("failed earlier command buffer", message)
        @test occursin("error accounting queue", message)

        # The synchronization boundary claims the failure before reporting it.
        @test synchronize(queue) === nothing
    end

    @testset "device synchronization" begin
        queue = MTL.MTLCommandQueue(device())
        cmdbuf = MTL.MTLCommandBuffer(queue)
        MTL.commit!(cmdbuf)
        info = MTL.CommandBufferErrorInfo("MTLCommandBufferErrorDomain", 8,
                                          "Out of memory", nothing, nothing)
        inject_command_buffer_error!(queue, info)
        @test_throws Metal.CommandBufferError device_synchronize()
        @test device_synchronize() === nothing
    end

    # MPS is optional
    if MPS.is_supported(device())
        @testset "MPS intermediate submissions" begin
            queue = MTL.MTLCommandQueue(device())
            mpsbuf = MPS.MPSCommandBuffer(queue)
            submitted = mpsbuf.commandBuffer
            MPS.commitAndContinue!(mpsbuf)
            @test MTL.last_committed(queue) == submitted

            MTL.commit!(mpsbuf)
            @test synchronize(queue) === nothing
        end

        @testset "MPS encoding failures" begin
            # an enqueued command buffer holds up its queue until it's committed
            queue = MTL.MTLCommandQueue(device())
            mpsbuf = MPS.MPSCommandBuffer(queue)
            submitted = mpsbuf.commandBuffer
            @test_throws ErrorException MPS.commitAndContinue!(mpsbuf) do cbuf
                error("failed to encode")
            end
            @test submitted.status >= MTL.MTLCommandBufferStatusCommitted

            mpsbuf = MPS.MPSCommandBuffer(queue)
            submitted = mpsbuf.commandBuffer
            @test_throws ErrorException MTL.commit!(mpsbuf) do cbuf
                error("failed to encode")
            end
            @test submitted.status >= MTL.MTLCommandBufferStatusCommitted
            @test synchronize(queue) === nothing
        end
    else
        @test_skip "MPS command buffers"
    end
end

@testset "command batching tunables" begin
    env = "JULIA_METAL_TEST_BATCHING_TUNABLE"
    withenv(env => nothing) do
        @test Metal.load_command_batching_tunable("test_tunable", env, 7) == 7
        @test_throws ArgumentError Metal.load_command_batching_tunable("test_tunable", env, 0)
        @test_throws ArgumentError Metal.load_command_batching_tunable("test_tunable", env, "7")
    end

    withenv(env => "9") do
        @test Metal.load_command_batching_tunable("test_tunable", env, 7) == 9
    end
    withenv(env => "0") do
        @test_throws ArgumentError Metal.load_command_batching_tunable("test_tunable", env, 7)
    end
    withenv(env => "-1") do
        @test_throws ArgumentError Metal.load_command_batching_tunable("test_tunable", env, 7)
    end
    withenv(env => "not-an-int") do
        @test_throws ArgumentError Metal.load_command_batching_tunable("test_tunable", env, 7)
    end
end

@testset "failed batch encoding" begin
    queue = global_queue(device())
    synchronize(queue)

    @test_throws ErrorException @metal threads=1 queue=queue failed_encode_kernel(EncodeFailure(1))
    @test !Metal.has_open_batch(queue)
    @test queue.backend.encoder === nothing
    @test queue.nops == 0

    A = MtlArray(Int32[0])
    synchronize(queue)
    @metal threads=1 queue=queue failed_batch_increment_kernel(A)
    @test_throws ErrorException @metal threads=1 queue=queue failed_encode_kernel(EncodeFailure(2))

    if Metal.command_batching() && !Metal.profiling_command_buffers() &&
       Metal.command_batching_ops() > 1
        @test Metal.has_open_batch(queue)
        @test queue.backend.encoder === nothing
        @test queue.nops == 1
    end

    @metal threads=1 queue=queue failed_batch_increment_kernel(A)
    synchronize(queue)
    @test Array(A) == Int32[2]
end
