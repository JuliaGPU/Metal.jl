dev = device()
lib = MTL.MTLLibrary(dev, """
    #include <metal_stdlib>
    using namespace metal;

    kernel void scale(device float *x [[buffer(0)]], constant float &a [[buffer(1)]],
                      uint i [[thread_position_in_grid]]) {
        x[i] *= a;
    }

    struct vector_arg { device float *ptr; long len; };
    kernel void fill_vec(constant vector_arg &v [[buffer(0)]], constant float &value [[buffer(1)]],
                         uint i [[thread_position_in_grid]]) {
        if (i < uint(v.len))
            v.ptr[i] = value;
    }

    kernel void reverse(device float *x [[buffer(0)]], threadgroup float *tmp [[threadgroup(0)]],
                        uint i [[thread_position_in_threadgroup]],
                        uint n [[threads_per_threadgroup]]) {
        tmp[i] = x[i];
        threadgroup_barrier(mem_flags::mem_threadgroup);
        x[i] = tmp[n - 1 - i];
    }
    """)
pipeline(name) = MTL.MTLComputePipelineState(dev, MTL.MTLFunction(lib, name))
scale, fill_vec, reverse_kernel = pipeline("scale"), pipeline("fill_vec"), pipeline("reverse")

# a by-value argument with a GPU address, mirroring the MSL `vector_arg`
struct VecArg
    ptr::Core.LLVMPtr{Float32,1}
    len::Int
end

@testset "buffers and values" begin
    x = MtlArray(Float32.(1:16))
    metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 2; threads=16)
    @test Array(x) == 2 .* (1:16)

    # types as a tuple, values as a tuple, and other pointer representations
    metalcall(scale, (Core.LLVMPtr{Float32,1}, Float32), pointer(x), 0.5f0; threads=16)
    @test Array(x) == 1:16
    Metal.metalcall_tuple(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, (x, 3); threads=16)
    @test Array(x) == 3 .* (1:16)

    # parameters without data take no buffer index
    metalcall(scale, Tuple{Nothing, Metal.MtlPtr{Float32}, Type{Int}, Float32},
              nothing, x, Int, 2//1; threads=16)
    @test Array(x) == 6 .* (1:16)

    # arrays that share their buffer are bound with an offset
    y = MtlArray(ones(Float32, 16))
    v = view(y, 9:16)
    metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, v, 4; threads=8, groups=1)
    @test Array(y) == [ones(Float32, 8); fill(4f0, 8)]
end

@testset "by-value structs" begin
    # the struct's layout matches `MtlDeviceVector`, which `mtlconvert` turns arrays into,
    # making their buffers resident
    x = MtlArray(zeros(Float32, 8))
    metalcall(fill_vec, Tuple{MtlDeviceVector{Float32,1}, Float32}, x, 42; threads=16)
    @test Array(x) == fill(42f0, 8)

    # GPU addresses the kernel finds in its arguments need their buffers to be declared
    y = MtlArray(zeros(Float32, 8))
    arg = VecArg(reinterpret(Core.LLVMPtr{Float32,1}, MTL.gpu_address(pointer(y).buffer)) +
                 pointer(y).offset, length(y))
    metalcall(fill_vec, Tuple{VecArg, Float32}, arg, 1; threads=8, resources=(y,))
    @test Array(y) == ones(Float32, 8)
end

@testset "threadgroup memory" begin
    x = MtlArray(Float32.(1:32))
    metalcall(reverse_kernel, Tuple{Metal.MtlPtr{Float32}}, x; threads=32,
              threadgroup_memory=(32 * sizeof(Float32),))
    @test Array(x) == 32:-1:1

    @test_throws "multiples of 16 bytes" metalcall(reverse_kernel, Tuple{Metal.MtlPtr{Float32}}, x;
                                                   threads=32, threadgroup_memory=(100,))
    @test_throws "must be <= 32768 bytes" metalcall(reverse_kernel, Tuple{Metal.MtlPtr{Float32}}, x;
                                                    threads=32, threadgroup_memory=(65536,))
end

@testset "errors" begin
    x = MtlArray(ones(Float32, 4))
    @test_throws "expects 2 arguments, got 1" metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x)
    # a GPU address can't be bound as a buffer
    ptr = reinterpret(Core.LLVMPtr{Float32,1}, MTL.gpu_address(pointer(x).buffer))
    @test_throws "Argument 1 should be an MtlArray, MtlPtr or MTLBuffer" metalcall(scale, Tuple{Core.LLVMPtr{Float32,1}, Float32}, ptr, 1)
    @test_throws "should not exceed" metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 1;
                                               threads=scale.maxTotalThreadsPerThreadgroup + 1)
    @test_throws "Resources should be" metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 1;
                                                 resources=(ptr,))
    # nothing was launched
    @test Array(x) == ones(Float32, 4)
end

@testset "queues" begin
    # launches are batched like others, and take ownership of the memory they use, so
    # reading it waits for the launch to finish
    x = MtlArray(ones(Float32, 16))
    queue = global_queue(dev)
    metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 2; threads=16, queue)
    if Metal.command_batching() && !Metal.profiling_command_buffers() &&
       Metal.command_batching_ops() > 1
        @test Metal.has_open_batch(queue)
    end
    @test Array(x) == fill(2f0, 16)

    # also from another task, which uses a queue of its own
    fetch(Threads.@spawn metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, 2;
                                   threads=16))
    @test Array(x) == fill(4f0, 16)
end

@testset "launch code is shared between signatures" begin
    for T in (Float32, Float64, Int32)
        x = MtlArray(ones(Float32, 4))
        metalcall(scale, Tuple{Metal.MtlPtr{Float32}, Float32}, x, one(T); threads=4)
    end
    synchronize()

    for f in (Metal.try_metalcall, Metal.submit_launch!, Metal.encode_launch!)
        @test length(collect(Base.specializations(only(methods(f))))) <= 1
    end
end
