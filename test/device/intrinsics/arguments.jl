@testset "arguments" begin
    @on_device dispatch_quadgroups_per_threadgroup()
    @on_device dispatch_simdgroups_per_threadgroup()
    @on_device quadgroup_index_in_threadgroup()
    @on_device quadgroups_per_threadgroup()
    @on_device simdgroup_index_in_threadgroup()
    @on_device simdgroups_per_threadgroup()
    @on_device thread_index_in_quadgroup()
    @on_device thread_index_in_simdgroup()
    @on_device thread_index_in_threadgroup()
    @on_device thread_execution_width()
    @on_device threads_per_simdgroup()

    @on_device dispatch_threads_per_threadgroup_1d()
    @on_device dispatch_threads_per_threadgroup_2d()
    @on_device dispatch_threads_per_threadgroup_3d()

    @on_device grid_origin_1d()
    @on_device grid_origin_2d()
    @on_device grid_origin_3d()

    @on_device grid_size_1d()
    @on_device grid_size_2d()
    @on_device grid_size_3d()

    @on_device thread_position_in_grid_1d()
    @on_device thread_position_in_grid_2d()
    @on_device thread_position_in_grid_3d()

    @on_device thread_position_in_threadgroup_1d()
    @on_device thread_position_in_threadgroup_2d()
    @on_device thread_position_in_threadgroup_3d()

    @on_device threadgroup_position_in_grid_1d()
    @on_device threadgroup_position_in_grid_2d()
    @on_device threadgroup_position_in_grid_3d()

    @on_device threadgroups_per_grid_1d()
    @on_device threadgroups_per_grid_2d()
    @on_device threadgroups_per_grid_3d()

    @on_device threads_per_grid_1d()
    @on_device threads_per_grid_2d()
    @on_device threads_per_grid_3d()

    @on_device threads_per_threadgroup_1d()
    @on_device threads_per_threadgroup_2d()
    @on_device threads_per_threadgroup_3d()

    global const CPU_ONLY_ERR = "This function is not intended for use on the CPU"

    @test_throws CPU_ONLY_ERR dispatch_quadgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR dispatch_simdgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR quadgroup_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR quadgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR simdgroup_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR simdgroups_per_threadgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_quadgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_simdgroup()
    @test_throws CPU_ONLY_ERR thread_index_in_threadgroup()
    @test_throws CPU_ONLY_ERR thread_execution_width()
    @test_throws CPU_ONLY_ERR threads_per_simdgroup()

    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_1d()
    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_2d()
    @test_throws CPU_ONLY_ERR dispatch_threads_per_threadgroup_3d()

    @test_throws CPU_ONLY_ERR grid_origin_1d()
    @test_throws CPU_ONLY_ERR grid_origin_2d()
    @test_throws CPU_ONLY_ERR grid_origin_3d()

    @test_throws CPU_ONLY_ERR grid_size_1d()
    @test_throws CPU_ONLY_ERR grid_size_2d()
    @test_throws CPU_ONLY_ERR grid_size_3d()

    @test_throws CPU_ONLY_ERR thread_position_in_grid_1d()
    @test_throws CPU_ONLY_ERR thread_position_in_grid_2d()
    @test_throws CPU_ONLY_ERR thread_position_in_grid_3d()

    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_1d()
    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_2d()
    @test_throws CPU_ONLY_ERR thread_position_in_threadgroup_3d()

    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_1d()
    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_2d()
    @test_throws CPU_ONLY_ERR threadgroup_position_in_grid_3d()

    @test_throws CPU_ONLY_ERR threadgroups_per_grid_1d()
    @test_throws CPU_ONLY_ERR threadgroups_per_grid_2d()
    @test_throws CPU_ONLY_ERR threadgroups_per_grid_3d()

    @test_throws CPU_ONLY_ERR threads_per_grid_1d()
    @test_throws CPU_ONLY_ERR threads_per_grid_2d()
    @test_throws CPU_ONLY_ERR threads_per_grid_3d()

    @test_throws CPU_ONLY_ERR threads_per_threadgroup_1d()
    @test_throws CPU_ONLY_ERR threads_per_threadgroup_2d()
    @test_throws CPU_ONLY_ERR threads_per_threadgroup_3d()
end
