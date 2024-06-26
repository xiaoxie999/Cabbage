//
//  ImageOverlayItem.swift
//  Cabbage
//
//  Created by Vito on 2018/10/2.
//  Copyright © 2018 Vito. All rights reserved.
//

import CoreMedia
import CoreImage

open class ImageOverlayItem: NSObject, ImageCompositionProvider, NSCopying {
    
    public var identifier: String
    public var resource: LocalImageResource
    required public init(resource: LocalImageResource, type: ResourceType? = nil) {
        identifier = ProcessInfo.processInfo.globallyUniqueString
        self.resource = resource
        let frame = CGRect(origin: CGPoint.zero, size: resource.size)
        self.videoConfiguration.contentMode = .custom
        self.videoConfiguration.frame = frame
        self.type = type
    }
    
    public var videoConfiguration: VideoConfiguration = .createDefaultConfiguration()
    
    public var type: ResourceType?
    
    // MARK: - NSCopying
    
    open func copy(with zone: NSZone? = nil) -> Any {
        let item = Swift.type(of: self).init(resource: resource.copy() as! LocalImageResource, type: type)
        item.identifier = identifier
        item.videoConfiguration = videoConfiguration.copy() as! VideoConfiguration
        item.startTime = startTime
        return item
    }
    
    // MARK: - ImageCompositionProvider
    
    public var startTime: CMTime = CMTime.zero
    public var duration: CMTime {
        get {
            return resource.scaledDuration
        }
    }
    
    open func applyEffect(to sourceImage: CIImage, at time: CMTime, renderSize: CGSize) -> CIImage {
        let relativeTime = time - timeRange.start
        guard let image = resource.image(at: relativeTime, renderSize: renderSize) else {
            return sourceImage
        }
        
        var finalImage = image
        
        let info = VideoConfigurationEffectInfo.init(time: time, renderSize: renderSize, timeRange: timeRange, type: type)
        finalImage = videoConfiguration.applyEffect(to: finalImage, info: info)

        finalImage = finalImage.composited(over: sourceImage)
        return finalImage
    }
    
}
