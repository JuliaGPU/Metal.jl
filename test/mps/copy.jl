# XXX: Why 64-bit Integers broken? Same behaviour with Swift
const IGNORE_UNION = Union{ComplexF32, Int64, UInt64}

function copytest(src, srctrans, dsttrans)
    dev = device()
    queue = global_queue(dev)
    dst = if srctrans == dsttrans
        similar(src)
    else
        similar(src')
    end

    if dsttrans
        cprows,cpcols = size(dst)
    else
        cpcols,cprows = size(dst)
    end

    cmdbuf = MTL.MTLCommandBuffer(queue) do cbuf
        srcMPS = MPS.MPSMatrix(src)
        dstMPS = MPS.MPSMatrix(dst)

        copydesc = MPS.MPSMatrixCopyDescriptor(srcMPS, dstMPS)
        copykern = MPS.MPSMatrixCopy(dev, cprows, cpcols, srctrans, dsttrans)
        MPS.encode!(cbuf, copykern, copydesc)
    end
    MTL.wait_completed(cmdbuf)
    return dst
end

@testset "MPSMatrixCopy" begin
    Ts = collect(values(MPS.jl_mps_to_typ))
    @testset "$T: $dim" for T in Ts, dim in ((16,16), (10,500), (500,10), (256,512))
        srcMat = MtlArray(rand(T, dim))

        dstMat = copytest(srcMat, false, false)
        @test dstMat == srcMat broken=(T <: IGNORE_UNION)

        dstMat = copytest(srcMat, true, false)
        @test dstMat == transpose(srcMat) broken=(T <: IGNORE_UNION)

        dstMat = copytest(srcMat, false, true)
        @test dstMat == transpose(srcMat) broken=(T <: IGNORE_UNION)

        dstMat = copytest(srcMat, true, true)
        @test dstMat == srcMat broken=(T <: IGNORE_UNION)
    end
end
