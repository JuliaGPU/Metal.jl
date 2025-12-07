@testset "warmup" begin
    @testset "warmup configuration" begin
        @test Metal._warmup_enabled == true
    end

    @testset "warmup API" begin
        # API should always work gracefully, regardless of thread count
        @test Metal.warmup(blocking = false) === nothing
        @test Metal.warmup() === nothing
        @test Metal.warmup(blocking = true) === nothing
    end

    if Threads.nthreads() > 1
        # Multi-threaded: warmup task should have been started
        @testset "warmup task started (multi-threaded)" begin
            @test Metal._warmup_task[] !== nothing
        end

        @testset "warmup task completion" begin
            Metal.warmup()
            task = Metal._warmup_task[]
            @test istaskdone(task)
            @test !istaskfailed(task)
        end

        @testset "warmup accelerates compilation" begin
            Metal.warmup()

            function test_kernel!(a)
                i = thread_position_in_grid().x
                if i <= length(a)
                    a[i] = 1.0f0
                end
                return nothing
            end

            a = MtlArray{Float32}(undef, 256)
            t = @elapsed @metal launch = false test_kernel!(a)

            # After warmup, compilation should be under 0.5s
            # (without warmup it would be ~1.7s)
            @test t < 0.5
        end

        @testset "concurrent kernel compilation" begin
            Metal.warmup()

            function k1!(a)
                a[1] = 1.0f0
                return nothing
            end
            function k2!(a)
                a[1] = 2.0f0
                return nothing
            end

            a = MtlArray{Float32}(undef, 1)

            t1 = @async @metal launch = false k1!(a)
            t2 = @async @metal launch = false k2!(a)

            # Should complete without deadlock (with timeout)
            @test timedwait(() -> istaskdone(t1) && istaskdone(t2), 10.0) == :ok
        end
    else
        # Single-threaded: warmup is intentionally skipped to avoid blocking
        @testset "warmup skipped (single-threaded)" begin
            @test Metal._warmup_task[] === nothing
        end
    end
end
