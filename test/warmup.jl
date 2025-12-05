@testset "warmup" begin
    @testset "warmup task started" begin
        # Warmup should have been started during __init__
        @test Metal._warmup_task[] !== nothing
        @test Metal._warmup_enabled == true
    end

    @testset "warmup API" begin
        # Non-blocking call should return immediately
        @test Metal.warmup(blocking=false) === nothing

        # Blocking call should wait and return nothing
        @test Metal.warmup() === nothing
        @test Metal.warmup(blocking=true) === nothing
    end

    @testset "warmup task completion" begin
        # After calling warmup(), task should be done
        Metal.warmup()
        task = Metal._warmup_task[]
        @test istaskdone(task)
        @test !istaskfailed(task)
    end

    @testset "warmup accelerates compilation" begin
        # After warmup, kernel compilation should be fast
        Metal.warmup()

        function test_kernel!(a)
            i = thread_position_in_grid().x
            if i <= length(a)
                a[i] = 1.0f0
            end
            return nothing
        end

        a = MtlArray{Float32}(undef, 256)
        t = @elapsed @metal launch=false test_kernel!(a)

        # After warmup, compilation should be under 0.5s
        # (without warmup it would be ~1.7s)
        @test t < 0.5
    end

    @testset "concurrent kernel compilation" begin
        # Verify that concurrent compilations don't deadlock
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

        t1 = @async @metal launch=false k1!(a)
        t2 = @async @metal launch=false k2!(a)

        # Should complete without deadlock (with timeout)
        @test timedwait(() -> istaskdone(t1) && istaskdone(t2), 10.0) == :ok
    end
end
