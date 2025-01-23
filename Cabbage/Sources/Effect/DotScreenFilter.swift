//
//  DotScreenFilter.swift
//  Cabbage
//
//  Created by Caillen on 22/1/2025.
//  Copyright © 2025 Vito. All rights reserved.
//

import MetalPetal

/// 特效：聚焦效果(DotScreen.metal)
public class MetalPetalDotScreenFilter {
    
    var ctx: MTIContext?
    
    init () {
        if let device = MTLCreateSystemDefaultDevice() {
            ctx = try? MTIContext(device: device)
        }
    }
    
    func process(image: CIImage) -> CIImage? {
        guard let ctx else { return nil }
        var mtiImage = MTIImage(ciImage: image, isOpaque: true)
        let size = mtiImage.size
        
        let dotScreenFilter = MTIDotScreenFilter()
        let blendWithMaskFilter = MTIBlendWithMaskFilter()
        blendWithMaskFilter.inputMask = MTIMask(content: RadialGradientImage.makeImage(size: size))
        
        if let outputImage = FilterGraph.makeImage(builder: { output in
            mtiImage => blendWithMaskFilter.inputPorts.inputImage
            mtiImage => dotScreenFilter => blendWithMaskFilter.inputPorts.inputBackgroundImage
            blendWithMaskFilter => output
        }) {
            mtiImage = outputImage
        }
        else {
            return nil
        }
        
        do {
            return try ctx.makeCIImage(from: mtiImage)
        } catch {
            return nil
        }
    }
    
    struct RadialGradientImage {
        private static let kernel = MTIRenderPipelineKernel(vertexFunctionDescriptor: .passthroughVertex, fragmentFunctionDescriptor: MTIFunctionDescriptor(name: "radialGradient", in: Bundle(for: MetalPetalDotScreenFilter.self)))
        static func makeImage(size: CGSize) -> MTIImage {
            kernel.makeImage(dimensions: MTITextureDimensions(cgSize: size))
        }
    }
}
