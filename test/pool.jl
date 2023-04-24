@testset "pool" begin

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

end