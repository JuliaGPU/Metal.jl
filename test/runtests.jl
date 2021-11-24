using Test
using Metal

@testset "MTL" begin
@testset "devices" begin

devs = devices()
@test length(devs) > 0

dev = first(devs)
@test dev == devs[1]

if length(devs) > 1
    @test dev != devs[2]
end

end

@testset "buffers" begin

dev = first(devices())

buf = MtlBuffer{Int}(dev, 1)

@test sizeof(buf) == 8
@test length(buf) == 1
@test device(buf) == dev

free(buf)

end

end
