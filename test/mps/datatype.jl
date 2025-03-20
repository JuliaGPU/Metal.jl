
@testset "MPSDataType" begin

@test convert(MPS.MPSDataType, 0x0000000010000020) == MPS.MPSDataTypeFloat32
@test sizeof(MPS.MPSDataTypeFloat16) == 2
@test convert(DataType, MPS.MPSDataTypeInt64) == Int64

end
