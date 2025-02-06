//
//  LUTFilter.swift
//  Cabbage
//
//  Created by Caillen on 22/1/2025.
//  Copyright © 2025 Vito. All rights reserved.
//

import MetalPetal

/// LUT滤镜
class LUTFilter {
    
    var ctx: MTIContext?
    
    init () {
        if let device = MTLCreateSystemDefaultDevice() {
            ctx = try? MTIContext(device: device)
        }
    }
    
    func process(image: CIImage, lutImage: UIImage) -> CIImage? {
        guard let ctx else { return nil }
        let mtiImage = MTIImage(ciImage: image, isOpaque: true)
        
        let lookupTable = MTIImage(image: lutImage, isOpaque: true)
        let lookupFilter = MTIColorLookupFilter()
        lookupFilter.inputImage = mtiImage
        lookupFilter.inputColorLookupTable = lookupTable
        
        guard let outputImage = lookupFilter.outputImage else { return nil }
        do {
            var resultImage = try ctx.makeCIImage(from: outputImage)
            if !resultImage.extent.equalTo(image.extent) {
                let transform = CGAffineTransform(translationX: image.extent.origin.x, y: image.extent.origin.y)
                resultImage = resultImage.transformed(by: transform)
            }
            return resultImage
        } catch {
            return nil
        }
    }
}
