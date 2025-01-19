//
//  AnimationToolGenerate.swift
//  Cabbage
//
//  Created by Caillen on 2024/11/7.
//  Copyright © 2024 Vito. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AnimationToolGenerate {
    static let shared = AnimationToolGenerate()
    private init() {}
}

extension AnimationToolGenerate {
    
    func makeAnimationTool(_ videoSize: CGSize, animationLayer: CALayer) -> (AVVideoCompositionCoreAnimationTool, CALayer) {
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(origin: .zero, size: videoSize)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        backgroundLayer.backgroundColor = UIColor.blue.cgColor
        /*
        videoLayer.frame = CGRect(
            x: 20,
            y: 20,
            width: videoSize.width - 40,
            height: videoSize.height - 40)
         */
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        //backgroundLayer.contents = UIImage(named: "background")?.cgImage
        backgroundLayer.contentsGravity = .resizeAspectFill
        
        /*
        addConfetti(to: overlayLayer)
        addImage(to: overlayLayer, videoSize: videoSize)
        add(
            text: "Happy Birthday,\n\("123")",
            to: overlayLayer,
            videoSize: videoSize)
         */
        
        animationLayer.isGeometryFlipped = true
        overlayLayer.addSublayer(animationLayer)
        
        let outputLayer = CALayer()
        outputLayer.frame = CGRect(origin: .zero, size: videoSize)
        outputLayer.addSublayer(backgroundLayer)
        outputLayer.addSublayer(videoLayer)
        outputLayer.addSublayer(overlayLayer)
        
        let animationTool =  AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        return (animationTool, overlayLayer)
    }
}
