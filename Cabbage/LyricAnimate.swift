//
//  LyricAnimate.swift
//  DeepLibDemo
//
//  Created by Caillen on 2024/8/8.
//

import Foundation
import UIKit
import CoreMedia
import AVFoundation

enum LyricAnimateType {
    case normal       // 常规效果
    case colorChange  // 颜色渐变
    case slowShow     // 逐字显示
}

/*
class LyricAnimate: UIViewController {
    
    var lyricLabel: LyricLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        lyricLabel = LyricLabel(frame: CGRect(x: 50, y: 100, width: kScreenWidth - 50 * 2, height: 60))
        view.addSubview(lyricLabel)
        lyricLabel.text = "我寻你千百度 有一岁荣枯"
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            self?.lyricLabel.progress += 0.01
        }
    }
}

class LyricLabel: UILabel {
    
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.green.set()
        let rect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * progress, height: rect.size.height)
        UIRectFillUsingBlendMode(rect, .sourceIn)
    }
}

class LyricTextLayer: CATextLayer {
    
    @NSManaged public var progress: CGFloat

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        // 设置绿色填充颜色
        ctx.setFillColor(UIColor.green.cgColor)
        
        // 创建绘制区域的矩形
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width * progress, height: bounds.size.height)
        
        // 设置混合模式
        ctx.setBlendMode(.sourceIn)
        ctx.fill(rect)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
}
 */

class LyricTextAnimation: CALayer {
    
    init(frame: CGRect, type: LyricAnimateType) {
        super.init()
        self.frame = frame
        //isGeometryFlipped = true
        makeAnimationGroups(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeAnimationGroups(type: LyricAnimateType) {
        let lyricInfo = calcLyricList()
        lyricInfo.forEach { info in
            
            switch type {
            case .normal:
                normalAnimation(info: info)
            case .colorChange:
                colorChangeAnimation(info: info)
            case .slowShow:
                slowShowAnimation(info: info)
            }
        }
        
        if let gifURL = Bundle.main.url(forResource: "cat", withExtension: "gif") {
            let gifLayer = GifImageLayer(frame: CGRect(x: frame.size.width - 200, y: 0, width: 256, height: 144), gifURL: gifURL)
            addSublayer(gifLayer)
        }
    }
    
    func makeAnimationTool(_ videoSize: CGSize) -> (AVVideoCompositionCoreAnimationTool, CALayer) {
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(origin: .zero, size: videoSize)
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        backgroundLayer.backgroundColor = UIColor(named: "rw-green")?.cgColor
        /*
        videoLayer.frame = CGRect(
            x: 20,
            y: 20,
            width: videoSize.width - 40,
            height: videoSize.height - 40)
         */
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        backgroundLayer.contents = UIImage(named: "background")?.cgImage
        backgroundLayer.contentsGravity = .resizeAspectFill
        
        /*
        addConfetti(to: overlayLayer)
        addImage(to: overlayLayer, videoSize: videoSize)
        add(
            text: "Happy Birthday,\n\("123")",
            to: overlayLayer,
            videoSize: videoSize)
         */
        
        isGeometryFlipped = true
        overlayLayer.addSublayer(self)
        
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
    
    func creatTextLayer(text: String) -> CATextLayer {
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(attrs(color: UIColor.green), range: NSRange(location: 0, length: (text as NSString).length))
        
        let textLayer = CATextLayer()
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.isWrapped = true
        textLayer.opacity = 0.0
//        textLayer.borderColor = UIColor.red.cgColor
//        textLayer.borderWidth = 1
        
        let maxWidth = self.frame.size.width - 20 * 2
        let stringSize = attributedText.boundingRect(with: CGSize(width: maxWidth, height: 300), options: .usesLineFragmentOrigin, context: nil).size
        textLayer.frame = CGRect(x: 20.0, y: 100.0, width: stringSize.width + 5, height: stringSize.height + 50)
        textLayer.position = position
        return textLayer
    }
    
    func attrs(color: UIColor) -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = .byCharWrapping // 换行模式
        let attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont(name: "ArialRoundedMTBold", size: 60) as Any,
            .foregroundColor: color,
            .strokeColor: UIColor.white,
            .strokeWidth: -3,
            .paragraphStyle: paragraphStyle]
        return attrs
    }
}

/// ColorChangeAnimation
extension LyricTextAnimation {
    
    func colorChangeAnimation(info: (Int, Int, String)) {
        let (start, duration, text) = info
        
        if text.isEmpty {
            return
        }
        
        let textLayer = creatTextLayer(text: text)
        
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(attrs(color: UIColor.green), range: NSRange(location: 0, length: (text as NSString).length))
        addFrameAnimation(with: textLayer, attributedText: attributedText, info: info)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 0.9, 1.0, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.1, 0.95, 1.0]
        //opacityAnimation.duration = Double(duration) / 1000.0
        //opacityAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        //opacityAnimation.isRemovedOnCompletion = false
        //textLayer.add(opacityAnimation, forKey: "opacity")
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.1, 0.9, 1.0, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.1, 0.5, 1.0]
        //scaleAnimation.duration = Double(duration) / 1000.0
        //scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        //scaleAnimation.isRemovedOnCompletion = false
        //textLayer.add(scaleAnimation, forKey: "transform.scale")
        
        /*
        let progressAnimation = CAKeyframeAnimation(keyPath: "progress")
        progressAnimation.values = [0.0, 1.0]
        progressAnimation.keyTimes = [0.0, 1.0]
        //progressAnimation.duration = Double(duration) / 1000.0
         */
        
        addSublayer(textLayer)
        
        let beginTime = start == 0 ? AVCoreAnimationBeginTimeAtZero : Double(start) / 1000.0
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        animationGroup.duration = Double(duration) / 1000.0
        animationGroup.beginTime = beginTime
        animationGroup.isRemovedOnCompletion = false
        textLayer.add(animationGroup, forKey: "animationGroup")
        textLayer.displayIfNeeded()
    }
    
    private func addFrameAnimation(with layer: CATextLayer, attributedText: NSAttributedString, info: (Int, Int, String)) {
        let (start, duration, _) = info
        let subTextLayer = CATextLayer()
        subTextLayer.string = attributedText
        subTextLayer.shouldRasterize = true
        subTextLayer.rasterizationScale = UIScreen.main.scale
        subTextLayer.backgroundColor = UIColor.clear.cgColor
        subTextLayer.frame = layer.bounds
        subTextLayer.isWrapped = true
        layer.addSublayer(subTextLayer)
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        subTextLayer.mask = maskLayer
        maskLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        maskLayer.frame = CGRect(x: 0, y: 0, width: 0, height: subTextLayer.bounds.size.height)
        
        let widthAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        widthAnimation.duration = Double(duration) / 1000.0
        widthAnimation.fromValue = 0.0
        widthAnimation.toValue = subTextLayer.bounds.size.width
        widthAnimation.beginTime = start == 0 ? AVCoreAnimationBeginTimeAtZero : Double(start) / 1000.0
        widthAnimation.isRemovedOnCompletion = false
        widthAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        maskLayer.add(widthAnimation, forKey: "bounds.size.width")
    }
}

/// SlowShowAnimation
extension LyricTextAnimation {
    
    func slowShowAnimation(info: (Int, Int, String)) {
        let (start, duration, text) = info
        
        if text.isEmpty {
            return
        }
        
        let textLayer = creatTextLayer(text: text)
        addSublayer(textLayer)
        
        let beginTime = start == 0 ? AVCoreAnimationBeginTimeAtZero : Double(start) / 1000.0
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 0.9, 1.0, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.01, 0.95, 1.0]
        opacityAnimation.duration = Double(duration) / 1000.0
        opacityAnimation.beginTime = beginTime
        opacityAnimation.isRemovedOnCompletion = false
        textLayer.add(opacityAnimation, forKey: "opacityAnimation")
        textLayer.displayIfNeeded()
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        textLayer.mask = maskLayer
        maskLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        maskLayer.frame = CGRect(x: 0, y: 0, width: 0, height: textLayer.bounds.size.height)
        
        let widthAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        var realDuration = Double(duration) / 1000.0
        let expectedDuration = Double(text.count) * 0.06
        if realDuration > expectedDuration {
            realDuration = expectedDuration
        }
        widthAnimation.duration = realDuration
        widthAnimation.fromValue = 0.0
        widthAnimation.toValue = textLayer.bounds.size.width
        widthAnimation.beginTime = start == 0 ? AVCoreAnimationBeginTimeAtZero : Double(start) / 1000.0
        widthAnimation.fillMode = .both
        widthAnimation.isRemovedOnCompletion = false
        maskLayer.add(widthAnimation, forKey: "bounds.size.width")
        
        /*
        let stringAnimation = CAKeyframeAnimation(keyPath: "string")
        stringAnimation.beginTime = beginTime
        var values = [NSMutableAttributedString]()
        var realDuration = Double(duration) / 1000.0
        let expectedDuration = Double(text.count) * 0.06
        if realDuration > expectedDuration {
            realDuration = expectedDuration
        }
        stringAnimation.duration = realDuration
        for index in 1...text.count {
            let subtext = String(text.prefix(index))
            let attributedText = NSMutableAttributedString(string: subtext)
            attributedText.addAttributes(attrs(color: UIColor(named: "rw-green")!), range: NSRange(location: 0, length: (subtext as NSString).length))
            values.append(attributedText)
        }
        stringAnimation.values = values
        stringAnimation.fillMode = .both
        stringAnimation.isRemovedOnCompletion = false
        textLayer.add(stringAnimation, forKey: "stringAnimation")
         */
    }
}

/// NormalAnimation
extension LyricTextAnimation {
    
    func normalAnimation(info: (Int, Int, String)) {
        let (start, duration, text) = info
        
        if text.isEmpty {
            return
        }
        
        let textLayer = creatTextLayer(text: text)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 0.9, 1.0, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.1, 0.95, 1.0]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.1, 0.9, 1.0, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.1, 0.5, 1.0]
        
        addSublayer(textLayer)
        
        let beginTime = start == 0 ? AVCoreAnimationBeginTimeAtZero : Double(start) / 1000.0
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        animationGroup.duration = Double(duration) / 1000.0
        animationGroup.beginTime = beginTime
        animationGroup.isRemovedOnCompletion = false
        textLayer.add(animationGroup, forKey: "animationGroup")
        textLayer.displayIfNeeded()
    }
}

extension LyricTextAnimation {
    
    /*
    func exportVideo(fromVideoAt videoURL: URL, onComplete: @escaping (URL?) -> Void) {
        print(videoURL)
        let asset = AVURLAsset(url: videoURL)
        let composition = AVMutableComposition()
        
        guard
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let assetTrack = asset.tracks(withMediaType: .video).first
        else {
            print("Something is wrong with the asset.")
            onComplete(nil)
            return
        }
        
        do {
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
            
            if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    timeRange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            onComplete(nil)
            return
        }
        
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
        } else {
            videoSize = assetTrack.naturalSize
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = makeAnimationTool(videoSize)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        let layerInstruction = compositionLayerInstruction(
            for: compositionTrack,
            assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
        
        guard let export = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            onComplete(nil)
            return
        }
        
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mov")
        
        export.videoComposition = videoComposition
        export.outputFileType = .mov
        export.outputURL = exportURL
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    onComplete(exportURL)
                default:
                    print("Something went wrong during export.")
                    print(export.error ?? "unknown error")
                    onComplete(nil)
                    break
                }
            }
        }
    }
     */
    
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        
        return (assetOrientation, isPortrait)
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(transform, at: .zero)
        
        return instruction
    }
    
    private func addImage(to layer: CALayer, videoSize: CGSize) {
        let image = UIImage(named: "overlay")!
        let imageLayer = CALayer()
        
        let aspect: CGFloat = image.size.width / image.size.height
        let width = videoSize.width
        let height = width / aspect
        imageLayer.frame = CGRect(
            x: 0,
            y: -height * 0.15,
            width: width,
            height: height)
        
        imageLayer.contents = image.cgImage
        layer.addSublayer(imageLayer)
    }
    
    private func addConfetti(to layer: CALayer) {
        let images: [UIImage] = (0...5).map { UIImage(named: "confetti\($0)")! }
        let colors: [UIColor] = [.systemGreen, .systemRed, .systemBlue, .systemPink, .systemOrange, .systemPurple, .systemYellow]
        let cells: [CAEmitterCell] = (0...16).map { _ in
            let cell = CAEmitterCell()
            cell.contents = images.randomElement()?.cgImage
            cell.birthRate = 3
            cell.lifetime = 12
            cell.lifetimeRange = 0
            cell.velocity = CGFloat.random(in: 100...200)
            cell.velocityRange = 0
            cell.emissionLongitude = 0
            cell.emissionRange = 0.8
            cell.spin = 4
            cell.color = colors.randomElement()?.cgColor
            cell.scale = CGFloat.random(in: 0.2...0.8)
            return cell
        }
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height + 5)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: layer.frame.size.width, height: 2)
        emitter.emitterCells = cells
        
        layer.addSublayer(emitter)
    }
    
    private func add(text: String, to layer: CALayer, videoSize: CGSize) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont(name: "ArialRoundedMTBold", size: 60) as Any,
                .foregroundColor: UIColor(named: "rw-green")!,
                .strokeColor: UIColor.white,
                .strokeWidth: -3])
        
        let textLayer = CATextLayer()
        textLayer.string = attributedText
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        
        textLayer.frame = CGRect(
            x: 0,
            y: videoSize.height * 0.66,
            width: videoSize.width,
            height: 150)
        textLayer.displayIfNeeded()
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        scaleAnimation.isRemovedOnCompletion = false
        textLayer.add(scaleAnimation, forKey: "scale")
        
        layer.addSublayer(textLayer)
    }
}

extension LyricTextAnimation {
    
    /// (start, duration, text)
    func calcLyricList() -> [(Int, Int, String)] {
        let lyricInfo = parseLyricFile()
        
        var lyricList: [(Int, Int, String)] = []
        var previousInfo: (Int, String)? = nil
        for info in lyricInfo {
            if previousInfo != nil {
                lyricList.append((previousInfo!.0, info.0 - previousInfo!.0, previousInfo!.1))
                previousInfo = info
            }
            else {
                previousInfo = info
            }
        }
        return lyricList
    }
    
    func parseLyricFile() -> [(Int, String)] {
        if let fileURL = Bundle.main.url(forResource: "wumingderen", withExtension: "lrc"),
           let data = try? Data(contentsOf: fileURL), let lyric = String(data: data, encoding: .utf8) {
            
            if !lyric.isEmpty {
                let lyricList = lyric.components(separatedBy: "\n").filter { $0.contains { character in
                    character == "]"
                } }.map { $0.replacingOccurrences(of: "[", with: "") }
                let lyricMap = lyricList.compactMap { value in
                    let components = value.components(separatedBy: "]")
                    let time = parseTime(time: components[0])
                    let value = components[1].trimmingCharacters(in: .whitespaces)
                    if let time {
                        return (time, value)
                    }
                    return nil
                }
                return lyricMap
            }
        }
        return []
    }
    
    func parseTime(time: String) -> Int? {
        if !time.isEmpty {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "mm:ss.SSS"
            if let date = dateFormat.date(from: time) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.minute, .second, .nanosecond], from: date)
                let minutes = components.minute ?? 0
                let seconds = components.second ?? 0
                let milliseconds = Int(round(Double(components.nanosecond ?? 0) / 1_000_000.0))
                // 计算总毫秒数
                let totalMilliseconds = (minutes * 60 * 1000) + (seconds * 1000) + milliseconds
                return totalMilliseconds
            }
        }
        return nil
    }
}

class GifImageLayer: CALayer {
    
    init(frame: CGRect, gifURL: URL) {
        super.init()
        self.frame = frame
        contentsGravity = .resizeAspect
        addAnimation(with: gifURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnimation(with gifURL: URL) {
        guard let gifData = try? Data(contentsOf: gifURL) else { return }

        let gifImageSource = CGImageSourceCreateWithData(gifData as CFData, nil)
        let frameCount = CGImageSourceGetCount(gifImageSource!)

        var images: [CGImage] = []
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(gifImageSource!, i, nil) {
                images.append(cgImage)
            }
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.values = images
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = Double(images.count) * 0.15
        animation.repeatCount = .infinity
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        add(animation, forKey: "gifAnimation")
    }
}
