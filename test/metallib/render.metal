//
// generates graphics function metadata we don't decode: vertex attributes (VATT/VATY in the
// public metadata), tessellation patches (TESS) and layered rendering (LAYR)

#include <metal_stdlib>
using namespace metal;

struct VertexIn { float4 position [[attribute(0)]]; float2 uv [[attribute(1)]]; };
struct VertexOut { float4 position [[position]]; float2 uv; uint layer [[render_target_array_index]]; };

vertex VertexOut vert(VertexIn in [[stage_in]], uint iid [[instance_id]])
{
    return { in.position, in.uv, iid };
}

struct PatchIn { patch_control_point<VertexIn> points; };

[[patch(quad, 4)]] vertex VertexOut tess(PatchIn patch [[stage_in]], float2 uv [[position_in_patch]])
{
    return { patch.points[0].position * uv.x, uv, 0 };
}

fragment float4 frag(VertexOut in [[stage_in]])
{
    return float4(in.uv, 0, 1);
}
