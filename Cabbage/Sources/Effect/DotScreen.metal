//
//  DotScreen.metal
//  Cabbage
//
//  Created by Caillen on 22/1/2025.
//  Copyright © 2025 Vito. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[ position ]];
    float2 textureCoordinate;
} VertexOut;

fragment float4 radialGradient(VertexOut vertexIn [[ stage_in ]]) {
    return float4(float3(1.0 - smoothstep(0.3, 0.8, distance(vertexIn.textureCoordinate, float2(0.5,0.5)))), 1);
}
