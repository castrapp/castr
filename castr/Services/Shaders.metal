#include <metal_stdlib>
using namespace metal;

// Define a structure to hold the vertex output
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Vertex Shader
vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    float2 positions[4] = {
        float2(-1.0,  1.0),
        float2(-1.0, -1.0),
        float2( 1.0,  1.0),
        float2( 1.0, -1.0)
    };

    float2 texCoords[4] = {
        float2(0.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 0.0),
        float2(1.0, 1.0)
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.texCoord = texCoords[vertexID];
    return out;
}

// Fragment Shader
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> tex [[texture(0)]]) {
    constexpr sampler samp(mag_filter::linear, min_filter::linear);
    return tex.sample(samp, in.texCoord); // Using the correct texture coordinates
}
