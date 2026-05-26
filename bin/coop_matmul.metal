#include <metal_stdlib>
#include <metal_tensor>
#include <metal_cooperative_tensor>
#include <MetalPerformancePrimitives/MetalPerformancePrimitives.h>

using namespace metal;
using namespace mpp::tensor_ops;

kernel void coop_matmul(tensor<device half, dextents<int32_t, 2>> A,
                        tensor<device half, dextents<int32_t, 2>> B,
                        tensor<device float, dextents<int32_t, 2>> C,
                        uint2 tgid [[threadgroup_position_in_grid]])
{
    constexpr auto desc = matmul2d_descriptor(64, 32, static_cast<int>(dynamic_extent));
    matmul2d<desc, execution_simdgroups<4>> op;

    auto mA = A.slice(0, tgid.y * 64);
    auto mB = B.slice(tgid.x * 32, 0);
    auto mC = C.slice(tgid.x * 32, tgid.y * 64);

    auto cT = op.get_destination_cooperative_tensor<decltype(mA), decltype(mB), float>();
    for (uint16_t i = 0; i < cT.get_capacity(); ++i) {
        if (cT.is_valid_element(i)) cT[i] = 0;
    }
    op.run(mA, mB, cT);

    // postfix-fuse: just scale + cast as a stand-in for softmax epilogue
    for (uint16_t i = 0; i < cT.get_capacity(); ++i) {
        if (cT.is_valid_element(i)) cT[i] *= 2.0f;
    }
    cT.store(mC);
}
