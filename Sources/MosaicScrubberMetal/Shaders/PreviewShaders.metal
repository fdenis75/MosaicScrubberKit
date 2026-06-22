#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position;
    float2 texcoord;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
};

vertex VertexOut scrubberVertex(uint vertexID [[vertex_id]],
                                constant VertexIn *vertices [[buffer(0)]]) {
    VertexIn input = vertices[vertexID];
    VertexOut output;
    output.position = float4(input.position, 0.0, 1.0);
    output.texcoord = input.texcoord;
    return output;
}

fragment float4 scrubberFragment(VertexOut input [[stage_in]],
                                 texture2d<float> currentTexture [[texture(0)]],
                                 texture2d<float> previousTexture [[texture(1)]],
                                 sampler textureSampler [[sampler(0)]],
                                 constant float &blend [[buffer(0)]]) {
    float4 current = currentTexture.sample(textureSampler, input.texcoord);
    if (blend >= 1.0) {
        return current;
    }
    float4 previous = previousTexture.sample(textureSampler, input.texcoord);
    return mix(previous, current, saturate(blend));
}
