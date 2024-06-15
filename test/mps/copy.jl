using Metal, Test

# XXX: Why 64-bit Integers broken? Same behaviour with Swift
const IGNORE_UNION = Union{Complex, Int64, UInt64}

function copytest(src, srctrans, dsttrans)
    device = device()
    queue = global_queue(device)
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

    cmdbuf = MTLCommandBuffer(queue) do cbuf
        srcMPS = MPS.MPSMatrix(src)
        dstMPS = MPS.MPSMatrix(dst)

        copydesc = MPS.MPSMatrixCopyDescriptor(srcMPS, dstMPS)
        copykern = MPS.MPSMatrixCopy(device, cprows, cpcols, srctrans, dsttrans)
        MPS.encode!(cbuf, copykern, copydesc)
    end
    wait_completed(cmdbuf)
    return dst
end

@testset "MPSMatrixCopy" begin
    Ts = collect(values(MPS.jl_mps_to_typ))
    Ts = Ts[.!(Ts .<: IGNORE_UNION)]
    @testset "$T" for T in Ts
        for dim in ((16,16), (10,500), (500,10), (256,512))
            srcMat = Metal.rand(T, dim)

            dstMat = copytest(srcMat, false, false)
            @test dstMat == srcMat

            dstMat = copytest(srcMat, true, false)
            @test dstMat == srcMat'

            dstMat = copytest(srcMat, false, true)
            @test dstMat == srcMat'

            dstMat = copytest(srcMat, true, true)
            @test dstMat == srcMat
        end
    end
end
