using Metal
using Metal.MPS
using LinearAlgebra
using Test

N = 3

lu_kernel = MPSMatrixDecompositionLU(current_device(), UInt64(N), UInt64(N))

dev = current_device()

A = rand(Float32, N,N)
B = zeros(Float32, N,N)
P = zeros(UInt32, N,1)

mtl_a = MtlMatrix(A')
mtl_b = MtlMatrix(B')
mtl_p = MtlMatrix(P')

mps_a = MPSMatrix(mtl_a)
mps_b = MPSMatrix(mtl_b)
mps_p = MPSMatrix(mtl_p)

status_buf = MTLBuffer(dev, 4; storage=Shared)
status_ptr = Ptr{Cint}(status_buf.contents)

cmdbuf = MTLCommandBuffer(global_queue(current_device()))
Metal.MPS.encode!(cmdbuf, lu_kernel, mps_a, mps_b, mps_p, status_buf)
commit!(cmdbuf)
wait_completed(cmdbuf)

status = unsafe_load(status_ptr)


L,U,P = lu(A)

res1 = mtl_a'
res2 = L - I(3) + U