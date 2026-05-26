#include <metal_stdlib>
#include <metal_tensor>
#include <MetalPerformancePrimitives/MetalPerformancePrimitives.h>

using namespace metal;
using namespace mpp::tensor_ops;

kernel void inline_matmul(device half* Abuf,
                          device half* Bbuf,
                          device float* Cbuf,
                          constant uint& M,
                          constant uint& N,
                          constant uint& K,
                          uint2 tgid [[threadgroup_position_in_grid]])
{
    // Build tensor_inline views over raw buffers.
    auto A = tensor<device half, dextents<int32_t, 2>, tensor_inline>(
        Abuf, dextents<int32_t, 2>{int32_t(K), int32_t(M)});
    auto B = tensor<device half, dextents<int32_t, 2>, tensor_inline>(
        Bbuf, dextents<int32_t, 2>{int32_t(N), int32_t(K)});
    auto C = tensor<device float, dextents<int32_t, 2>, tensor_inline>(
        Cbuf, dextents<int32_t, 2>{int32_t(N), int32_t(M)});

    constexpr auto desc = matmul2d_descriptor(64, 32, static_cast<int>(dynamic_extent));
    matmul2d<desc, execution_simdgroups<4>> op;

    auto mA = A.slice(0, tgid.y * 64);
    auto mB = B.slice(tgid.x * 32, 0);
    auto mC = C.slice(tgid.x * 32, tgid.y * 64);

    op.run(mA, mB, mC);
}
