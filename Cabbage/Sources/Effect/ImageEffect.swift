//
//  ImageEffect.swift
//  VFCabbage
//
//  Created by szcck006 on 2024/4/9.
//

import Foundation
import CoreImage

public extension CIImage {
    /// 裁切尺寸
    func cropSize(withHorizontalPadding value: Float) -> CIImage? {
        let width = extent.width - CGFloat(value) * 2
        //let height = width * extent.height / extent.width
        //let cropped = cropped(to: extent.insetBy(dx: CGFloat(value), dy: (extent.height - height) / 2.0))
        let cropped = cropped(to: extent.insetBy(dx: CGFloat(value), dy: CGFloat(value) / extent.width * extent.height))
        
        // resize
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")
        resizeFilter?.setValue(cropped, forKey: kCIInputImageKey)
        resizeFilter?.setValue(extent.width / width, forKey: kCIInputScaleKey)
        return resizeFilter?.outputImage
    }
    
    /// 缩放尺寸
    func scaleSize(withHorizontalPadding value: CGFloat, frame: CGRect) -> CIImage {
        var newFrame = frame
        if value > 0.0 {
            newFrame = frame.insetBy(dx: value, dy: value / frame.width * frame.height)
        }
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
    
    func scaleFitSize(to: CGRect) -> CIImage {
        let newFrame = extent.aspectFit(in: to)
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
    
    /*
    func scaleFillSize(to: CGRect) -> CIImage {
        let newFrame = extent.aspectFill(in: to)
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
     */
}

public extension CIImage {
    /// 高斯模糊
    func gaussianBlur(frame: CGRect, horizontalPadding: CGFloat = 0.0) -> CIImage? {
        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
        gaussianFilter?.setValue(self, forKey: kCIInputImageKey)
        gaussianFilter?.setValue(10.0, forKey: kCIInputRadiusKey)
        if var bgImage = gaussianFilter?.outputImage {
            /// 背景图，裁切由模糊引起的黑边
            /*
            let transform = CGAffineTransform.transform(by: bgImage.extent, aspectFillRect: frame)
            bgImage = bgImage.transformed(by: transform).cropped(to: frame)
             */
            if let outputImage = bgImage.cropSize(withHorizontalPadding: 5) {
                bgImage = outputImage
            }
                        
            /// 前景图，裁切黑边
            var frontImage = cropSize(withHorizontalPadding: 2)
            frontImage = frontImage?.scaleSize(withHorizontalPadding: horizontalPadding, frame: frame)
            
            // 图层叠加
            let compFilter = CIFilter(name: "CISourceOverCompositing")
            compFilter?.setValue(frontImage, forKey: kCIInputImageKey)
            compFilter?.setValue(bgImage, forKey: kCIInputBackgroundImageKey)
            return compFilter?.outputImage
        }
        return nil
    }
    
    /// splitImageEffect
    func splitImageEffect(frame: CGRect, direction: VideoConfigOtherEffect.VideoSplitType, filters: [CIFilter?] = []) -> CIImage? {
        let images = splitImage(with: direction, frame: frame)
        
        /// 添加滤镜
        var filterOutputs: [CIImage] = images
        if let first = filters.first, let filter = first {
            images.forEach { image in
                if let output = image.apply(filter) {
                    filterOutputs.append(output)
                }
            }
        }
        
        // 图层叠加
        if images.count > 2 {
            let compFilter = CIFilter(name: "CISourceOverCompositing")
            compFilter?.setValue(images[0], forKey: kCIInputImageKey)
            compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
            let outputImage = compFilter?.outputImage
            compFilter?.setValue(outputImage, forKey: kCIInputBackgroundImageKey)
            compFilter?.setValue(images[2], forKey: kCIInputImageKey)
            return compFilter?.outputImage
        }
        else if images.count > 1 {
            let compFilter = CIFilter(name: "CISourceOverCompositing")
            compFilter?.setValue(images[0], forKey: kCIInputImageKey)
            compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
            return compFilter?.outputImage
        }
        
        /*
        switch direction {
        case .horizontal(let videoSplitCount):
            switch videoSplitCount {
            case .two:
                // 图层叠加
                if images.count > 1 {
                    let compFilter = CIFilter(name: "CISourceOverCompositing")
                    compFilter?.setValue(images[0], forKey: kCIInputImageKey)
                    compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
                    return compFilter?.outputImage
                }
            case .three:
                // 图层叠加
                if images.count > 2 {
                    let compFilter = CIFilter(name: "CISourceOverCompositing")
                    compFilter?.setValue(images[0], forKey: kCIInputImageKey)
                    compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
                    let outputImage = compFilter?.outputImage
                    compFilter?.setValue(outputImage, forKey: kCIInputBackgroundImageKey)
                    compFilter?.setValue(images[2], forKey: kCIInputImageKey)
                    return compFilter?.outputImage
                }
            }
        case .vertical(let videoSplitCount):
            switch videoSplitCount {
            case .two:
                // 图层叠加
                if images.count > 1 {
                    let compFilter = CIFilter(name: "CISourceOverCompositing")
                    compFilter?.setValue(images[0], forKey: kCIInputImageKey)
                    compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
                    return compFilter?.outputImage
                }
            case .three:
                // 图层叠加
                if images.count > 2 {
                    let compFilter = CIFilter(name: "CISourceOverCompositing")
                    compFilter?.setValue(images[0], forKey: kCIInputImageKey)
                    compFilter?.setValue(images[1], forKey: kCIInputBackgroundImageKey)
                    let outputImage = compFilter?.outputImage
                    compFilter?.setValue(outputImage, forKey: kCIInputBackgroundImageKey)
                    compFilter?.setValue(images[2], forKey: kCIInputImageKey)
                    return compFilter?.outputImage
                }
            }
        }
         */
        return nil
    }
    
    private func splitImage(with direction: VideoConfigOtherEffect.VideoSplitType, frame: CGRect) -> [CIImage] {
        var result: [CIImage] = []
        switch direction {
        case .horizontal(let count):
            switch count {
            case .two:
                /// 左右二分，取中间的区域
                let centerFrame = CGRect(x: frame.width / 4, y: 0, width: frame.width / 2, height: frame.height)
                let image = cropped(to: centerFrame)
                let leftTransform = CGAffineTransform(translationX: -frame.width / 4, y: 0)
                let rightTransform = CGAffineTransform(translationX: frame.width / 4, y: 0)
                result = [image.transformed(by: leftTransform), image.transformed(by: rightTransform)]
            case .three:
                /// 左右三分，取中间的区域
                let centerFrame = CGRect(x: frame.width / 3, y: 0, width: frame.width / 3, height: frame.height)
                let image = cropped(to: centerFrame)
                let leftTransform = CGAffineTransform(translationX: -frame.width / 3, y: 0)
                let rightTransform = CGAffineTransform(translationX: frame.width / 3, y: 0)
                result = [image.transformed(by: leftTransform), image, image.transformed(by: rightTransform)]
            }
        case .vertical(let count):
            switch count {
            case .two:
                /// 上下二分，取中间的区域
                let centerFrame = CGRect(x: 0, y: frame.height / 4, width: frame.width, height: frame.height / 2)
                let image = cropped(to: centerFrame)
                let topTransform = CGAffineTransform(translationX: 0, y: -frame.height / 4)
                let downTransform = CGAffineTransform(translationX: 0, y: frame.height / 4)
                result = [image.transformed(by: topTransform), image.transformed(by: downTransform)]
            case .three:
                /// 上下三分，取中间的区域
                let centerFrame = CGRect(x: 0, y: frame.height / 3, width: frame.width, height: frame.height / 3)
                let image = cropped(to: centerFrame)
                let topTransform = CGAffineTransform(translationX: 0, y: -frame.height / 3)
                let bottomTransform = CGAffineTransform(translationX: 0, y: frame.height / 3)
                result = [image.transformed(by: topTransform), image, image.transformed(by: bottomTransform)]
            }
        }
        return result
    }
}

/// 滤镜
/// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
public extension CIImage {
    
    func apply(_ filter: CIFilter) -> CIImage? {
        filter.setValue(self , forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
