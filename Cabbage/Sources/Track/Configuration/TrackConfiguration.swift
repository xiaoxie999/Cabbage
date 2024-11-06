//
//  TrackConfiguration.swift
//  Cabbage
//
//  Created by Vito on 21/09/2017.
//  Copyright © 2017 Vito. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

public struct VideoConfigurationEffectInfo {
    
    public var time = CMTime.zero
    public var renderSize = CGSize.zero
    public var timeRange = CMTimeRange.zero
    public var type: ResourceType?
}

public protocol VideoConfigurationProtocol: NSCopying {
    func applyEffect(to sourceImage: CIImage, info: VideoConfigurationEffectInfo) -> CIImage
}

public class VideoConfigOtherEffect {
    
    weak var videoConfig: VideoConfiguration?
    
    public enum VideoSplitType: String {
        case horizontal, vertical
    }
    
    /// 分段
    public var split: VideoSplitType? = nil

    /// 滤镜
    // 调色
    public var color: Bool = false {
        didSet {
            if color {
                filters.append(CIImage.randomBuiltinFilter())
            }
        }
    }
    // 修改角度
    public var angle: Bool = false {
        didSet {
            if angle {
                filters.append(CIImage.angleFilter())
            }
        }
    }
    private(set) var filters: [CIFilter?] = []
    
    /// 画中画效果(高斯模糊)
    public var pipOffset: Double = 0.0
    
    /// 镜像
    public var mirror: Bool = false {
        didSet {
            if mirror {
                videoConfig?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        }
    }
    
    /// 裁切
    public var cropX: Double = 0.0
    
    func hasEffect() -> Bool {
        split != nil || color || angle || pipOffset > 0 || mirror || cropX > 0
    }
    
    init(_ videoConfig: VideoConfiguration?) {
        self.videoConfig = videoConfig
    }
}

public class VideoConfiguration: NSObject, VideoConfigurationProtocol {
    
    public static func createDefaultConfiguration() -> VideoConfiguration {
        return VideoConfiguration()
    }
    
    public enum BaseContentMode {
        case aspectFit
        case aspectFill
        case custom
    }
    public var contentMode: BaseContentMode = .aspectFit
    /// Default is renderSize
    public var frame: CGRect?
    public var transform: CGAffineTransform?
    public var opacity: Float = 1.0
    public var configurations: [VideoConfigurationProtocol] = []
    
    public lazy var otherEffect = VideoConfigOtherEffect(self)
    
    public required override init() {
        super.init()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let configuration = type(of: self).init()
        configuration.contentMode = contentMode
        configuration.transform = transform
        configuration.opacity = opacity;
        configuration.configurations = configurations.map({ $0.copy(with: zone) as! VideoConfigurationProtocol });
        configuration.frame = frame;
        return configuration
    }
    
    // MARK: - VideoConfigurationProtocol
    
    public func applyEffect(to sourceImage: CIImage, info: VideoConfigurationEffectInfo) -> CIImage {
        var finalImage = sourceImage

        if let userTransform = self.transform {
            var transform = CGAffineTransform.identity
            transform = transform.concatenating(CGAffineTransform(translationX: -(finalImage.extent.origin.x + finalImage.extent.width/2), y: -(finalImage.extent.origin.y + finalImage.extent.height/2)))
            transform = transform.concatenating(userTransform)
            transform = transform.concatenating(CGAffineTransform(translationX: (finalImage.extent.origin.x + finalImage.extent.width/2), y: (finalImage.extent.origin.y + finalImage.extent.height/2)))
            finalImage = finalImage.transformed(by: transform)
        }

        let frame = self.frame ?? CGRect(origin: CGPoint.zero, size: info.renderSize)
        ///debugPrint("extent: \(finalImage.extent), randerSize: \(info.renderSize), fit: \(finalImage.extent.aspectFit(in: frame)), contentMode: \(contentMode)")
        switch contentMode {
        case .aspectFit:
            let transform = CGAffineTransform.transform(by: finalImage.extent, aspectFitInRect: frame)
            finalImage = finalImage.transformed(by: transform).cropped(to: frame)
            
            if info.type == .trackItem {
                if otherEffect.hasEffect() {
                    if otherEffect.cropX > 0 {
                        if let cropImage = finalImage.cropSize(withHorizontalPadding: Float(otherEffect.cropX)) {
                            let transform = CGAffineTransform.transform(by: cropImage.extent, aspectFitInRect: frame)
                            finalImage = cropImage.transformed(by: transform).cropped(to: frame)
                        }
                    }
                    
                    /// 添加滤镜
                    if !otherEffect.filters.isEmpty {
                        otherEffect.filters.forEach { filter in
                            if let filter, let output = finalImage.apply(filter) {
                                finalImage = output
                            }
                        }
                    }
                    
                    /// 分段
                    if let split = otherEffect.split {
                        if let image = finalImage.splitTwoImage(frame: frame, direction: split) {
                            finalImage = image
                        }
                    }
                    
                    /// 画中画
                    if otherEffect.pipOffset > 0.0 {
                        if let blurImage = finalImage.gaussianBlur(frame: frame, horizontalPadding: otherEffect.pipOffset) {
                            finalImage = blurImage
                        }
                    }
                    
                    /*
                    /// 视频非全屏
                    if frame.height - finalImage.extent.aspectFit(in: frame).height > 20 {
                        /// 添加背景模糊效果
                        if enableBlur {
                            if let blurImage = finalImage.gaussianBlur(frame: frame) {
                                finalImage = blurImage
                            }
                        }
                    }
                    /// 视频全屏
                    else {}
                     */
                }
            }
            break
        case .aspectFill:
            let transform = CGAffineTransform.transform(by: finalImage.extent, aspectFillRect: frame)
            finalImage = finalImage.transformed(by: transform).cropped(to: frame)
            break
        case .custom:
            var transform = CGAffineTransform(scaleX: frame.size.width / sourceImage.extent.size.width, y: frame.size.height / sourceImage.extent.size.height)
            let translateTransform = CGAffineTransform.init(translationX: frame.origin.x, y: frame.origin.y)
            transform = transform.concatenating(translateTransform)
            finalImage = finalImage.transformed(by: transform)
            break
        }
        
        finalImage = finalImage.apply(alpha: CGFloat(opacity))
        
        configurations.forEach { (videoConfiguration) in
            finalImage = videoConfiguration.applyEffect(to: finalImage, info: info)
        }
        
        return finalImage
    }
}

public protocol AudioConfigurationProtocol: AudioProcessingNode, NSCopying { }

public class AudioConfiguration: NSObject, NSCopying {
    
    public static func createDefaultConfiguration() -> AudioConfiguration {
        return AudioConfiguration()
    }

    public var volume: Float = 1.0;
    public var nodes: [AudioConfigurationProtocol] = []
    
    public required override init() {
        super.init()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let configuration = type(of: self).init()
        configuration.volume = volume
        configuration.nodes = nodes.map { $0.copy() as! AudioConfigurationProtocol }
        return configuration
    }
    
}

public class VolumeAudioConfiguration: NSObject, AudioConfigurationProtocol {
    
    public var timeRange: CMTimeRange
    public var startVolume: Float
    public var endVolume: Float
    public var timingFunction: ((Double) -> Double)?
    public required init(timeRange: CMTimeRange, startVolume: Float, endVolume: Float) {
        self.timeRange = timeRange
        self.startVolume = startVolume
        self.endVolume = endVolume
        super.init()
    }
    
    public func process(timeRange: CMTimeRange, bufferListInOut: UnsafeMutablePointer<AudioBufferList>) {
        if timeRange.duration.isValid {
            if self.timeRange.intersection(timeRange).duration.seconds > 0 {
                var percent = (timeRange.end.seconds - self.timeRange.start.seconds) / self.timeRange.duration.seconds
                if let timingFunction = timingFunction {
                    percent = timingFunction(percent)
                }
                let volume = startVolume + (endVolume - startVolume) * Float(percent)
                AudioMixer.changeVolume(for: bufferListInOut, volume: volume)
            }
        }
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let configuration = type(of: self).init(timeRange: timeRange, startVolume: startVolume, endVolume: endVolume)
        configuration.timingFunction = timingFunction
        return configuration
    }
    
}
