//
//  Shaders.metal
//  MetalPetalDemo
//
//  Created by YuAo on 2021/4/3.
//

typedef struct {
    float4 position [[ position ]];
    float2 textureCoordinate;
} VertexOut;

#include <metal_stdlib>

using namespace metal;

fragment float4 radialGradient(VertexOut vertexIn [[ stage_in ]]) {
    return float4(float3(1.0 - smoothstep(0.3, 0.8, distance(vertexIn.textureCoordinate, float2(0.5,0.5)))), 1);
}
