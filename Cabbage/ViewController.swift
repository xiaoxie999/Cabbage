//
//  ViewController.swift
//  Cabbage
//
//  Created by Vito on 2018/7/28.
//  Copyright © 2018 Vito. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

public let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height

class DemoItem {
    var title: String
    var action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

class ViewController: UITableViewController {
    
    var demoItems: [DemoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoCell")
        demoItems.append(DemoItem.init(title: "Simple Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let controller = AVPlayerViewController()
            let playerItem = strongSelf.simplePlayerItem(targetVC: controller)
            controller.player = AVPlayer.init(playerItem: playerItem)
            strongSelf.navigationController?.pushViewController(controller, animated: true)
            //strongSelf.pushToPreviewWithPlayerItem(playerItem)
            
            /*
            let bambooTrackItem: TrackItem = {
                let url = Bundle.main.url(forResource: "hdr", withExtension: "mov")!
                let resource = AVAssetTrackResource(asset: AVAsset(url: url))
                let trackItem = TrackItem(resource: resource)
                trackItem.videoConfiguration.contentMode = .aspectFit
                return trackItem
            }()
            
            let timeline = Timeline()
            timeline.videoChannel = [bambooTrackItem]
            timeline.audioChannel = [bambooTrackItem]
            timeline.renderSize = CGSize(width: 1080, height: 1920)
            let compositionGenerator = CompositionGenerator(timeline: timeline)
            let exportSession = compositionGenerator.buildExportSession(presetName: AVAssetExportPresetHighestQuality)
            exportSession?.shouldOptimizeForNetworkUse = true
            DispatchQueue.global().async {
                exportSession?.exportAsynchronously(completionHandler: {
                    DispatchQueue.main.async {
                        if let status = exportSession?.status {
                            print(status.rawValue)
                        }
                    }
                })
            }
             */
        }))
        
        
        demoItems.append(DemoItem.init(title: "HDR Support Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.hdrVideoPlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Overlay Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.overlayPlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Transition Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.transitionPlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Keyframe Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.keyframePlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Four square Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.fourSquareVideo()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "AssetReader Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.testReaderOutput()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Reverse video Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.reversePlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Two video Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let playerItem = strongSelf.twoVideoPlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem)
        }))
        
        demoItems.append(DemoItem.init(title: "Images Demo", action: { [weak self] in
            guard let strongSelf = self else { return }
            let (playerItem, genenator) = strongSelf.imagesPlayerItem()
            strongSelf.pushToPreviewWithPlayerItem(playerItem, compositionGenerator: genenator)
        }))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        let demoItem = self.demoItems[indexPath.row]
        cell.textLabel?.text = demoItem.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let demoItem = demoItems[indexPath.row]
        demoItem.action()
    }
    
    // MARK: - Demo
    func pushToPreviewWithPlayerItem(_ playerItem: AVPlayerItem) {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer.init(playerItem: playerItem)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    static var compositionGenerator: CompositionGenerator? = nil
    func pushToPreviewWithPlayerItem(_ playerItem: AVPlayerItem, compositionGenerator: CompositionGenerator) {
        let controller = AVPlayerViewController()
        ViewController.compositionGenerator = compositionGenerator
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportVideo))
        controller.player = AVPlayer.init(playerItem: playerItem)
        navigationController?.pushViewController(controller, animated: true)
        
        let syncLayer = AVSynchronizedLayer(playerItem: playerItem)
        
        /* 动画
        let layer = editor.makeAnimationLayer(CGSize(width: 1080, height: 1920))
        // 计算缩放比例
        let scaleWidth = width / 1080
        let scaleHeight = height / 1920
        // 使用最小缩放比例以保持比例
        let scaleFactor = min(scaleWidth, scaleHeight)
        // 设置层的缩放变换
        layer.position = CGPoint(
                x: width / 2,
                y: height / 2
            )
        layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)
        syncLayer.addSublayer(layer)
         */
        
        /// 歌词
        let videoSize = CGSizeMake(1080, 1920)
        let width = kScreenWidth
        let height = width * videoSize.height / videoSize.width
        
        let lyricLayer = makeAnimationTool(videoSize).1
        lyricLayer.isGeometryFlipped = true
        let scaleFactor = width / 1080
        lyricLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)
        lyricLayer.anchorPoint = CGPoint(x: 0, y: 0)
        lyricLayer.position = syncLayer.position
        syncLayer.addSublayer(lyricLayer)
        
        syncLayer.frame = CGRect(x: 0, y: (kScreenHeight - height) / 2.0, width: width, height: height)
        syncLayer.masksToBounds = true
        controller.view.layer.addSublayer(syncLayer)
    }
    
    func simplePlayerItem(targetVC: AVPlayerViewController) -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "hdr", withExtension: "mov")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [bambooTrackItem]
        timeline.audioChannel = [bambooTrackItem]
        timeline.renderSize = CGSize(width: 1080, height: 1920)
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func hdrVideoPlayerItem() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "hdr", withExtension: "mov")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [bambooTrackItem]
        timeline.audioChannel = [bambooTrackItem]
        timeline.renderSize = CGSize(width: 1080, height: 1920)
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        // Support hdr video you can set pixelFormatType to 10bit type, but it will cost more memory and more rendering time.
        if let videoComposition = playerItem.videoComposition?.mutableCopy() as? AVMutableVideoComposition {
            videoComposition.customVideoCompositorClass = HDRVideoCompositor.self
            playerItem.videoComposition = videoComposition
        }
        return playerItem
    }
    
    func overlayPlayerItem() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [bambooTrackItem]
        timeline.audioChannel = [bambooTrackItem]
        
        timeline.passingThroughVideoCompositionProvider = {
            let imageCompositionGroupProvider = ImageCompositionGroupProvider()
            let url = Bundle.main.url(forResource: "overlay", withExtension: "jpg")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 3, preferredTimescale: 600))
            let imageCompositionProvider = ImageOverlayItem(resource: resource)
            imageCompositionProvider.startTime = CMTime(seconds: 1, preferredTimescale: 600)
            let frame = CGRect.init(x: 100, y: 500, width: 400, height: 400)
            imageCompositionProvider.videoConfiguration.contentMode = .custom
            imageCompositionProvider.videoConfiguration.frame = frame;
            imageCompositionProvider.videoConfiguration.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4)
            
            let keyframeConfiguration: KeyframeVideoConfiguration<OpacityKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<OpacityKeyframeValue>()
                
                let timeValues: [(Double, CGFloat)] = [(0.0, 0), (0.5, 1.0), (2.5, 1.0), (3.0, 0.0)]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = OpacityKeyframeValue()
                    opacityKeyframeValue.opacity = value
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                
                return configuration
            }()
            imageCompositionProvider.videoConfiguration.configurations.append(keyframeConfiguration)

            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()

                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (1.0, (1.0, CGFloat.pi, CGPoint(x: 100, y: 80))),
                     (2.0, (1.0, CGFloat.pi * 2, CGPoint(x: 300, y: 240))),
                     (3.0, (1.0, 0, CGPoint.zero))]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })

                return configuration
            }()
            imageCompositionProvider.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            
            imageCompositionGroupProvider.imageCompositionProviders = [imageCompositionProvider]
            return imageCompositionGroupProvider
        }()
        
        timeline.renderSize = CGSize(width: 1920, height: 1080)
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func transitionPlayerItem() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "part1", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let overlayTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "overlay", withExtension: "jpg")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 5, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let seaTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "part2", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let transitionDuration = CMTime(seconds: 1, preferredTimescale: 600)
        bambooTrackItem.videoTransition = BoundingUpTransition(duration: transitionDuration)
//        bambooTrackItem.audioTransition = FadeInOutAudioTransition(duration: transitionDuration)
        
        //overlayTrackItem.videoTransition = FadeTransition(duration: transitionDuration)
        
        let splitVideos = splitVideo()
        splitVideos[0].videoTransition = PushTransition(duration: transitionDuration)
        
        let timeline = Timeline()
        timeline.videoChannel = splitVideos
        timeline.audioChannel = splitVideos
        
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        } catch {
            assert(false, error.localizedDescription)
        }
        timeline.renderSize = CGSize(width: 1080, height: 1920)
        
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func keyframePlayerItem() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (1.0, (1.2, CGFloat.pi / 20, CGPoint(x: 100, y: 80))),
//                     (2.0, (1.5, CGFloat.pi / 15, CGPoint(x: 300, y: 240))),
//                     (3.0, (1.0, 0, CGPoint.zero))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [bambooTrackItem]
        timeline.audioChannel = [bambooTrackItem]
        timeline.renderSize = CGSize(width: 1920, height: 1080)
        
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func testReaderOutput() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let flyTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "cute", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [bambooTrackItem, flyTrackItem]
        
        try! Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        
//        timeline.passingThroughVideoCompositionProvider = {
//            let imageCompositionGroupProvider = ImageCompositionGroupProvider()
//            let url = Bundle.main.url(forResource: "sea", withExtension: "mp4")!
//            let resource = AVAssetReaderImageResource(asset: AVAsset(url: url))
//            resource.selectedTimeRange = CMTimeRange.init(start: CMTime(seconds: 0, preferredTimescale: 600), end: CMTime(seconds: 3, preferredTimescale: 600))
//            let imageCompositionProvider = ImageOverlayItem(resource: resource)
//            imageCompositionProvider.startTime = CMTime(seconds: 1, preferredTimescale: 600)
//            let frame = CGRect.init(x: 100, y: 500, width: 600, height: 400)
//            imageCompositionProvider.videoConfiguration.contentMode = .custom(frame)
//            
//            imageCompositionGroupProvider.imageCompositionProviders = [imageCompositionProvider]
//            return imageCompositionGroupProvider
//        }()
        
        timeline.renderSize = CGSize(width: 1920, height: 1080)
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    
    func twoVideoPlayerItem() -> AVPlayerItem {
        let renderSize = CGSize(width: 1080, height: 1920)
        let bambooTrackItem: TrackItem = {
//            let width = renderSize.width / 2
//            let height = width * (9/16)
            let url = Bundle.main.url(forResource: "person", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            resource.selectedTimeRange = CMTimeRange.init(start: CMTime.zero, end: CMTime.init(value: 16 * 600, 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .custom
//            trackItem.videoConfiguration.frame = CGRect(x: 0, y: (renderSize.height - height) / 2, width: width, height: height)
            trackItem.videoConfiguration.frame = CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
            return trackItem
        }()
        
//        let seaTrackItem: TrackItem = {
//            let height = renderSize.height
//            let width = height * (9/16)
//            let url = Bundle.main.url(forResource: "sea", withExtension: "mp4")!
//            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
////            resource.selectedTimeRange = CMTimeRange.init(start: CMTime.zero, end: CMTime.init(value: 2400, 600))
//            resource.selectedTimeRange = CMTimeRange(start: CMTime(value: 0, timescale: 600), duration: CMTime(value: 600, timescale: 600))
//            let trackItem = TrackItem(resource: resource)
//            trackItem.audioConfiguration.volume = 0.3
//            trackItem.videoConfiguration.contentMode = .custom
////            trackItem.videoConfiguration.frame = CGRect(x: renderSize.width / 2 + (renderSize.width / 2 - width) / 2, y: (renderSize.height - height) / 2, width: width, height: height)
//            trackItem.videoConfiguration.frame = CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
//            return trackItem
//        }()
        
        let seaTrackItem2: TrackItem = {
//            let height = renderSize.height
//            let width = height * (9/16)
            let url = Bundle.main.url(forResource: "bg", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
//            resource.selectedTimeRange = CMTimeRange.init(start: CMTime.zero, end: CMTime.init(value: 2400, 600))
            resource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(value: 16 * 600, timescale: 600))
            let trackItem = TrackItem(resource: resource, type: .overlayVideo)
            trackItem.audioConfiguration.volume = 0.3
            trackItem.videoConfiguration.contentMode = .custom
//            trackItem.videoConfiguration.frame = CGRect(x: renderSize.width / 2 + (renderSize.width / 2 - width) / 2, y: (renderSize.height - height) / 2, width: width, height: height)
            trackItem.videoConfiguration.frame = CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
            return trackItem
        }()
        
        let trackItems = [bambooTrackItem]
        
        let timeline = Timeline()
        timeline.videoChannel = trackItems
        timeline.audioChannel = trackItems
        
        timeline.overlays = [seaTrackItem2]
        timeline.audios = [seaTrackItem2]
        timeline.renderSize = renderSize
        
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func fourSquareVideo() -> AVPlayerItem {
        let bambooTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let seaTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "sea", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        
        let flyTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "cute", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let bamboo2TrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "bamboo", withExtension: "mp4")!
            let resource = AVAssetTrackResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            
            return trackItem
        }()
        
        let trackItems = [flyTrackItem, bambooTrackItem, seaTrackItem, bamboo2TrackItem]
        
        let timeline = Timeline()
        timeline.videoChannel = trackItems
        timeline.audioChannel = trackItems
        
        try! Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        
        let renderSize = CGSize(width: 1920, height: 1080)
        
        timeline.overlays = {
            let foursquareRenderSize = CGSize(width: renderSize.width / 2, height: renderSize.height / 2)
            var overlays: [VideoProvider] = []
            let fullTimeRange: CMTimeRange = {
                var duration = CMTime.zero
                trackItems.forEach({ duration = $0.duration + duration })
                return CMTimeRange.init(start: CMTime.zero, duration: duration)
            }()
            
            // Update main item's frame
            func frameWithIndex(_ index: Int) -> CGRect {
                switch index {
                case 0:
                    return CGRect(origin: CGPoint.zero, size: foursquareRenderSize)
                case 1:
                    return CGRect(origin: CGPoint(x: foursquareRenderSize.width, y: 0), size: foursquareRenderSize)
                case 2:
                    return CGRect(origin: CGPoint(x: 0, y:  foursquareRenderSize.height), size: foursquareRenderSize)
                case 3:
                    return CGRect(origin: CGPoint(x: foursquareRenderSize.width, y: foursquareRenderSize.height), size: foursquareRenderSize)
                default:
                    break
                }
                return CGRect(origin: CGPoint.zero, size: foursquareRenderSize)
            }
            
            trackItems.enumerated().forEach({ (offset, mainTrackItem) in
                let frame: CGRect = {
                    let index = offset % 4
                    return frameWithIndex(index)
                }()
                mainTrackItem.videoConfiguration.contentMode = .aspectFit
                mainTrackItem.videoConfiguration.frame = frame
                
                let timeRanges = fullTimeRange.substruct(mainTrackItem.timeRange)
                for timeRange in timeRanges {
                    Log.debug("timeRange: {\(String(format: "%.2f", timeRange.start.seconds)) - \(String(format: "%.2f", timeRange.end.seconds))}")
                    if timeRange.duration.seconds > 0 {
                        let staticTrackItem = mainTrackItem.copy() as! TrackItem
                        staticTrackItem.startTime = timeRange.start
                        staticTrackItem.duration = timeRange.duration
                        if timeRange.start <= mainTrackItem.timeRange.start {
                            let start = staticTrackItem.resource.selectedTimeRange.start
                            staticTrackItem.resource.selectedTimeRange = CMTimeRange(start: start, duration: CMTime(value: 1, 30))
                        } else {
                            let start = staticTrackItem.resource.selectedTimeRange.end - CMTime(value: 1, 30)
                            staticTrackItem.resource.selectedTimeRange = CMTimeRange(start: start, duration: CMTime(value: 1, 30))
                        }
                        overlays.append(staticTrackItem)
                    }
                }
            })
            
            return overlays
        }()
        timeline.renderSize = renderSize;
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func reversePlayerItem() -> AVPlayerItem {
        let seaTrackItem: TrackItem = {
            let url = Bundle.main.url(forResource: "sea", withExtension: "mp4")!
            let resource = AVAssetReverseImageResource(asset: AVAsset(url: url))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            return trackItem
        }()
        
        let timeline = Timeline()
        timeline.videoChannel = [seaTrackItem]
        timeline.renderSize = CGSize(width: 1920, height: 1080)
        
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        let playerItem = compositionGenerator.buildPlayerItem()
        return playerItem
    }
    
    func imagesPlayerItem() -> (AVPlayerItem, CompositionGenerator) {
        let imageItem1: TrackItem = {
            let url = Bundle.main.url(forResource: "1", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 10, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit

            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (4.0, (1.2, 0, CGPoint(x: 0, y: 0))),
                     (6.0, (1.1, 0, CGPoint(x: -20, y: 20))),
                     (9.0, (1.0, 0, CGPoint.zero))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let imageItem2: TrackItem = {
            let url = Bundle.main.url(forResource: "2", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 9, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (3.0, (1.2, 0, CGPoint(x: 20, y: 30))),
                     (6.0, (1.1, 0, CGPoint(x: 0, y: 10))),
                     (8.0, (1.0, 0, CGPoint.zero))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let imageItem3: TrackItem = {
            let url = Bundle.main.url(forResource: "3", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 15, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (8.0, (1.2, 0, CGPoint(x: 10, y: 0))),
                     (12.0, (1.0, 0, CGPoint(x: 0, y: 0)))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let imageItem4: TrackItem = {
            let url = Bundle.main.url(forResource: "4", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 16, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (6.0, (1.1, 0, CGPoint(x: 10, y: 0))),
                     (15.0, (1.0, 0, CGPoint(x: 0, y: 0)))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let imageItem5: TrackItem = {
            let url = Bundle.main.url(forResource: "5", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 10, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (8.0, (1.1, 0, CGPoint(x: 10, y: 0))),
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let imageItem6: TrackItem = {
            let url = Bundle.main.url(forResource: "6", withExtension: "png")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 32, preferredTimescale: 600))
            let trackItem = TrackItem(resource: resource)
            trackItem.videoConfiguration.contentMode = .aspectFit
            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()
                
                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (8.0, (1.2, 0, CGPoint(x: 20, y: 0))),
                     (14.0, (1.0, 0, CGPoint(x: 0, y: 0)))
                    ]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                return configuration
            }()
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            trackItem.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            return trackItem
        }()
        
        let transitionDuration = CMTime(seconds: 1, preferredTimescale: 600)
        imageItem1.videoTransition = PushTransition(duration: transitionDuration)
        imageItem2.videoTransition = BoundingUpTransition(duration: transitionDuration)
        
        let timeline = Timeline()
        timeline.videoChannel = [imageItem1, imageItem2, imageItem3, imageItem4, imageItem5, imageItem6]
        
        let asset = AVAsset(url: Bundle.main.url(forResource: "wumingderen", withExtension: "mp3")!)
        let trackItem = TrackItem(resource: AVAssetTrackResource(asset: asset))
        trackItem.resource.selectedTimeRange = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 600), duration: CMTime(seconds: 90, preferredTimescale: 600))
        timeline.audioChannel = [trackItem]
        
        /*
        timeline.passingThroughVideoCompositionProvider = {
            let imageCompositionGroupProvider = ImageCompositionGroupProvider()
            let url = Bundle.main.url(forResource: "overlay", withExtension: "jpg")!
            let image = CIImage(contentsOf: url)!
            let resource = LocalImageResource(image: image, duration: CMTime.init(seconds: 3, preferredTimescale: 600))
            let imageCompositionProvider = ImageOverlayItem(resource: resource)
            imageCompositionProvider.startTime = CMTime(seconds: 1, preferredTimescale: 600)
            let frame = CGRect.init(x: 100, y: 1600, width: 200, height: 200)
            imageCompositionProvider.videoConfiguration.contentMode = .custom
            imageCompositionProvider.videoConfiguration.frame = frame;
            imageCompositionProvider.videoConfiguration.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4)
            
            let keyframeConfiguration: KeyframeVideoConfiguration<OpacityKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<OpacityKeyframeValue>()
                
                let timeValues: [(Double, CGFloat)] = [(0.0, 0), (0.5, 1.0), (2.5, 1.0), (3.0, 0.0)]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = OpacityKeyframeValue()
                    opacityKeyframeValue.opacity = value
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })
                
                return configuration
            }()
            imageCompositionProvider.videoConfiguration.configurations.append(keyframeConfiguration)

            let transformKeyframeConfiguration: KeyframeVideoConfiguration<TransformKeyframeValue> = {
                let configuration = KeyframeVideoConfiguration<TransformKeyframeValue>()

                let timeValues: [(Double, (CGFloat, CGFloat, CGPoint))] =
                    [(0.0, (1.0, 0, CGPoint.zero)),
                     (1.0, (1.0, CGFloat.pi, CGPoint(x: 100, y: 80))),
                     (2.0, (1.0, CGFloat.pi * 2, CGPoint(x: 300, y: 240))),
                     (3.0, (1.0, 0, CGPoint.zero))]
                timeValues.forEach({ (time, value) in
                    let opacityKeyframeValue = TransformKeyframeValue()
                    opacityKeyframeValue.scale = value.0
                    opacityKeyframeValue.rotation = value.1
                    opacityKeyframeValue.translation = value.2
                    let keyframe = KeyframeVideoConfiguration.Keyframe(time: CMTime(seconds: time, preferredTimescale: 600), value: opacityKeyframeValue)
                    configuration.insert(keyframe)
                })

                return configuration
            }()
            imageCompositionProvider.videoConfiguration.configurations.append(transformKeyframeConfiguration)
            
            imageCompositionGroupProvider.imageCompositionProviders = [imageCompositionProvider]
            return imageCompositionGroupProvider
        }()
         */
        
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        } catch {
            assert(false, error.localizedDescription)
        }
        timeline.renderSize = CGSize(width: 1080, height: 1920)
        
        let compositionGenerator = CompositionGenerator(timeline: timeline)
        
        let playerItem = compositionGenerator.buildPlayerItem()
        return (playerItem, compositionGenerator)
    }
}

extension ViewController {
    
    func splitVideo() -> [TrackItem] {
        
        let asset = AVAsset(url: Bundle.main.url(forResource: "test", withExtension: "mp4")!)
        let resource = AVAssetTrackResource(asset: asset)
        // 获取视频轨道
        var videoDuration:CMTimeRange
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            videoDuration = videoTrack.timeRange
        } else {
            videoDuration = resource.selectedTimeRange
        }
        
        let split: Float64 = 3
        
        let resource1 = AVAssetTrackResource(asset: asset)
        resource1.selectedTimeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: split))
        
        let resource2 = AVAssetTrackResource(asset: asset)
        resource2.selectedTimeRange = CMTimeRange(start: CMTime(seconds: split - 1.0), duration: CMTime(seconds: videoDuration.duration.seconds - split + 1.0))
        
        return [resource1, resource2].map { TrackItem(resource: $0) }
    }
}

extension ViewController {
    
    func lyricLayer(_ videoSize: CGSize) -> LyricTextAnimation {
        let lyricLayer = LyricTextAnimation(frame: CGRect(origin: .zero, size: videoSize), type: .slowShow)
        return lyricLayer
    }
    
    func makeAnimationTool(_ videoSize: CGSize) -> (AVVideoCompositionCoreAnimationTool, CALayer) {
        let lyricLayer = lyricLayer(videoSize)
        return lyricLayer.makeAnimationTool(videoSize)
    }
    
    @objc func exportVideo() {
        print("export started")
        let videoSize = CGSizeMake(1080, 1920)
        let exportSession = ViewController.compositionGenerator?.buildExportSession(presetName: AVAssetExportPresetHighestQuality, animationTool: makeAnimationTool(videoSize).0)
        exportSession?.shouldOptimizeForNetworkUse = true
        
        DispatchQueue.global().async {
            exportSession?.exportAsynchronously(completionHandler: { [weak self] in
                guard let self else { return }
                switch exportSession?.status {
                case .completed:
                    if let outputURL = exportSession?.outputURL {
                        
                        self.saveFileToAlbum(outputURL) { result, error in
                            print("save to album")
                            
                            /// 删除缓存的文件
                            if FileManager.default.fileExists(atPath: outputURL.path) {
                                try? FileManager.default.removeItem(at: outputURL)
                            }
                        }
                        
                        /* 动画
                        editor.makeBirthdayCard(fromVideoAt: outputURL, forName: "") { exportedURL in
                            guard let exportedURL = exportedURL else {
                                return
                            }
                            self.saveFileToAlbum(exportedURL) { result, error in
                                print("save to album")
                            }
                        }
                         */
                        
                        /*
                        /// 歌词
                        let lyricLayer = LyricTextAnimation(frame: CGRect(x: 0, y: 0, width: 1080, height: 1920), type: .slowShow, export: true)
                        lyricLayer.exportVideo(fromVideoAt: outputURL) { exportedURL in
                            guard let exportedURL = exportedURL else {
                                return
                            }
                            self.saveFileToAlbum(exportedURL) { result, error in
                                print("save to album")
                                
                                /// 删除缓存的文件
                                if FileManager.default.fileExists(atPath: exportedURL.path) {
                                    try? FileManager.default.removeItem(at: exportedURL)
                                }
                            }
                        }
                         */
                    }
                    print("export completed")
                case .failed:
                    print("export failed")
                case .cancelled:
                    print("export cancelled")
                case .waiting:
                    print("waiting")
                case .exporting:
                    print("exporting")
                default:
                    print("unknown")
                }
            })
        }
    }
    
    func saveFileToAlbum(_ fileURL: URL, handler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { (saved, error) in
            if let handler = handler {
                handler(saved, error)
            }
        }
    }
}
