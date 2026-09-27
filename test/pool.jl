@testset "@allocated" begin
    @test (Metal.@allocated MtlArray{Int32}(undef,1)) == 4
end

@testset "@timed" begin
    out = Metal.@timed MtlArray{Int32}(undef, 1)
    @test isa(out.value, MtlArray{Int32})
    @test out.gpu_bytes > 0
end

@testset "@time" begin
    ret, out = @grab_output Metal.@time MtlArray{Int32}(undef, 1)
    @test isa(ret, MtlArray{Int32})
    @test occursin("1 GPU allocation: 4 bytes", out)
end

@testset "empty allocations" begin
    # Metal doesn't support empty buffers, so `alloc` pads them
    dev = device()
    buf = alloc(dev, 0; storage=Metal.SharedStorage)
    @test buf.length == 1
    free(buf)

    # zero-length host copies must not need a host-backed staging buffer
    a = MtlArray{Int}(undef, 1)
    @test unsafe_copyto!(dev, pointer(a), Ptr{Int}(C_NULL), 0) == pointer(a)
    @test unsafe_copyto!(dev, Ptr{Int}(C_NULL), pointer(a), 0) == C_NULL
end
