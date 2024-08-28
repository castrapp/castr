//
//  Shaders2.metal
//  castr
//
//  Created by Harrison Hall on 8/27/24.
//

#include <metal_stdlib>
using namespace metal;


#include <metal_stdlib>
using namespace metal;

// Define a structure to hold the vertex output
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Vertex Shader
// Vertex Shader
//vertex VertexOut vertexShader2(uint vertexID [[vertex_id]],
//                               constant float2 &drawableSize [[buffer(0)]],
//                               constant float2 &textureSize [[buffer(1)]]) {
//    float textureAspectRatio = textureSize.x / textureSize.y;
//    float drawableAspectRatio = drawableSize.x / drawableSize.y;
//
//    float scaleX = 1.0;
//    float scaleY = 1.0;
//
//    if (textureAspectRatio > drawableAspectRatio) {
//        // Texture is wider than the drawable
//        scaleY = drawableAspectRatio / textureAspectRatio;
//    } else {
//        // Texture is taller than the drawable
//        scaleX = textureAspectRatio / drawableAspectRatio;
//    }
//
//    float2 positions[4] = {
//        float2(-scaleX,  scaleY),
//        float2(-scaleX, -scaleY),
//        float2( scaleX,  scaleY),
//        float2( scaleX, -scaleY)
//    };
//
//    float2 texCoords[4] = {
//        float2(0.0, 0.0),
//        float2(0.0, 1.0),
//        float2(1.0, 0.0),
//        float2(1.0, 1.0)
//    };
//
//    VertexOut out;
//    out.position = float4(positions[vertexID], 0.0, 1.0);
//    out.texCoord = texCoords[vertexID];
//    return out;
//}


// Structure to hold layer and superlayer information
struct LayerInfo {
    float2 layerOrigin;
    float2 layerSize;
    float2 superlayerSize;
};


// Vertex Shader
vertex VertexOut vertexShader2(
                               uint vertexID [[vertex_id]],
                               constant LayerInfo &layerInfo [[buffer(0)]],
                               constant float2 &textureSize [[buffer(1)]]
                               ) {

    // Calculate the four corners of the layer relative to the superlayer
    float2 topLeft = layerInfo.layerOrigin;
    float2 bottomLeft = float2(layerInfo.layerOrigin.x, layerInfo.layerOrigin.y + layerInfo.layerSize.y);
    float2 topRight = float2(layerInfo.layerOrigin.x + layerInfo.layerSize.x, layerInfo.layerOrigin.y);
    float2 bottomRight = float2(layerInfo.layerOrigin.x + layerInfo.layerSize.x, layerInfo.layerOrigin.y + layerInfo.layerSize.y);

    // Convert to normalized device coordinates (NDC) using the original variable names
    float2 BottomLeftNDC = float2(
                                  (topLeft.x / layerInfo.superlayerSize.x) * 2.0 - 1.0,
                                  (topLeft.y / layerInfo.superlayerSize.y) * 2.0 - 1.0
                                  );

    float2 TopLeftNDC = float2(
                               (bottomLeft.x / layerInfo.superlayerSize.x) * 2.0 - 1.0,
                               (bottomLeft.y / layerInfo.superlayerSize.y) * 2.0 - 1.0
                               );

    float2 BottomRightNDC = float2(
                                   (topRight.x / layerInfo.superlayerSize.x) * 2.0 - 1.0,
                                   (topRight.y / layerInfo.superlayerSize.y) * 2.0 - 1.0
                                   );

    float2 TopRightNDC = float2(
                                (bottomRight.x / layerInfo.superlayerSize.x) * 2.0 - 1.0,
                                (bottomRight.y / layerInfo.superlayerSize.y) * 2.0 - 1.0
                                );

    // Prepare the positions array in NDC with the original variable names
    float4 positions[4] = {
        float4(TopLeftNDC.x, TopLeftNDC.y, 0.0, 1.0),   // TOP-LEFT Corner
        float4(BottomLeftNDC.x, BottomLeftNDC.y, 0.0, 1.0), // BOTTOM-LEFT Corner
        float4(TopRightNDC.x, TopRightNDC.y, 0.0, 1.0),  // TOP-RIGHT Corner
        float4(BottomRightNDC.x, BottomRightNDC.y, 0.0, 1.0) // BOTTOM-RIGHT Corner
    };

    // Fetch the pre-calculated position for this vertex
    float4 pos = positions[vertexID];

    // Texture coordinates remain the same
    float2 texCoords[4] = {
    float2(0.0, 0.0),
    float2(0.0, 1.0),
    float2(1.0, 0.0),
    float2(1.0, 1.0)
    };

    VertexOut out;
    out.position = pos;  // Use the calculated position
    out.texCoord = texCoords[vertexID];
    return out;
}



// Fragment Shader
fragment float4 fragmentShader2(VertexOut in [[stage_in]],
                               texture2d<float> tex [[texture(0)]]) {
    constexpr sampler samp(mag_filter::linear, min_filter::linear);
    return tex.sample(samp, in.texCoord); // Using the correct texture coordinates
}
