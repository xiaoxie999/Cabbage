//
//  TextRotateAnimate.swift
//  DeepLibDemo
//
//  Created by Caillen on 2024/8/2.
//

import Foundation
import UIKit

struct RotateLayerModel {
    var layer: CALayer
    var direction: Bool
}

private let RotateNum = 5

class RotateAnimateLabel: UILabel {
    
}

class TextRotateAnimate: UIViewController {
    
    var textAnimationLayer = CALayer()
    var tempLayer = CALayer()
    
    // 文字数组
//    let texts = ["Hello World", "Swift", "Animation", "BackgroundColor", "rotate_ViewDidLoad", "ViewWillAppear"]
    let texts = ["Hello World", "AIG", "Animation", "BackgroundColor", "rotate_ViewDidLoad",
                 "ViewWillAppear", "TextRotateAnimate", "UIViewController", "addSublayer", "rotate_CGRect",
                 "UIViewProperty", "kScreenWidth", "kScreenHeight", "setTitleColor", "rotate_Action",
                 "backgroundColor"]
    var remainingAnimations: [(UIViewPropertyAnimator, UIView)] = []
    
    var addedList: [UIView] = []
    var remainItemList: [UIView] = []
    var rotateLayerList: [RotateLayerModel] = []
    var rotateDirection: Bool = true // false 向右 true 向左
    var currentFontScale: CGFloat = 1.0
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        textAnimationLayer.frame = CGRect(x: (kScreenWidth - 300) / 2.0, y: (kScreenHeight - 400) / 2.0, width: 300, height: 400)
        textAnimationLayer.backgroundColor = UIColor.gray.cgColor
        textAnimationLayer.masksToBounds = true
        view.layer.addSublayer(textAnimationLayer)
        
        let button = UIButton(frame: CGRect(x: 100, y: CGRectGetMaxY(textAnimationLayer.frame) + 30, width: kScreenWidth - 100 * 2, height: 50))
        button.setTitle("play", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    private func playAnimations() {
        guard let firstAnimator = remainingAnimations.first else {
            return
        }
        
        firstAnimator.0.addCompletion { [weak self] position in
            guard let self else { return }
            
            let element = remainingAnimations.removeFirst()
            if let willRotateLayerModel = rotateLayerList.last {
                willRotateLayerModel.layer.addSublayer(element.1.layer)
            }
            
            addAnimator()
            if let _ = remainingAnimations.first {
                playAnimations()
            } else {
                print("complete")
            }
        }
        firstAnimator.0.startAnimation()
    }
    
    func clearData() {
        rotateDirection = false
        remainingAnimations.removeAll()
        addedList.removeAll()
        remainItemList.removeAll()
        _ = rotateLayerList.map { $0.layer.removeFromSuperlayer() }
        rotateLayerList.removeAll()
        textAnimationLayer.removeAllAnimations()
        _ = textAnimationLayer.sublayers?.map({ $0.removeFromSuperlayer() })
    }
    
    @objc func buttonAction() {
        clearData()
        
        addAnimator()
        playAnimations()
    }
    
    func addAnimator() {
        if addedList.count < texts.count {
            let text = texts[addedList.count]
            //currentFontScale = CGFloat.random(in: 1.0...2.0)
            currentFontScale = text.count > 15 ? 1.0 : 20 / CGFloat(text.count)
            
            let attributedString = NSMutableAttributedString(string: text)
            var attributes:[NSAttributedString.Key:Any] = [:]
            attributes[.font] = UIFont.systemFont(ofSize: 16 * currentFontScale)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: (text as NSString).length))
            var stringSize = attributedString.boundingRect(with: CGSize(width: 300, height: 300), options: .usesLineFragmentOrigin, context: nil).size
            if stringSize.height < 40 {
                stringSize.height += 10
            }
            let textLabelHeight = stringSize.height
            let rotateAnimateText = RotateAnimateLabel(frame: CGRect(x: (textAnimationLayer.bounds.size.width - 300) / 2.0, y: (textAnimationLayer.bounds.size.height - textLabelHeight) / 2.0, width: 300, height: textLabelHeight))
            rotateAnimateText.alpha = 0.0
            //rotateAnimateText.textAlignment = rotateDirection ? .right : .left
            rotateAnimateText.textAlignment = .center
            rotateAnimateText.text = text
            rotateAnimateText.font = UIFont.systemFont(ofSize: 16 * currentFontScale)
            rotateAnimateText.textColor = [UIColor.green, UIColor.white].randomElement()
            //rotateAnimateText.backgroundColor = UIColor.red
            
            if addedList.count % RotateNum == 0 {
                //rotateAnimateText.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                rotateAnimateText.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            else {
                rotateAnimateText.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            textAnimationLayer.addSublayer(rotateAnimateText.layer)
            
            remainItemList = Array(addedList)
            if addedList.count > RotateNum {
                while remainItemList.count > RotateNum {
                    remainItemList = Array(remainItemList.suffix(from: RotateNum))
                }
            }
            
            /// Double(text.count) * 0.1
            let animator = UIViewPropertyAnimator(duration: 0.8, curve: .easeOut) { [weak self] in
                guard let self else { return }
                
                if remainItemList.count % RotateNum == 0 {
                    /// 旋转时机
                    //rotateAnimateText.transform = CGAffineTransform(rotationAngle: 0)
                    
                    if remainItemList.isEmpty {
                        tempLayer = CALayer()
                        tempLayer.frame = CGRect(x: 0, y: 0, width: textAnimationLayer.frame.size.width, height: textAnimationLayer.frame.size.height / 2.0)
                        textAnimationLayer.addSublayer(tempLayer)
                        rotateLayerList.append(RotateLayerModel(layer: tempLayer, direction: rotateDirection))
                    }
                    else {
                        if let willRotateLayerModel = rotateLayerList.last {
                            let willRotateLayer = willRotateLayerModel.layer
                            if rotateDirection {
                                willRotateLayer.anchorPoint = CGPoint(x: 0, y: 0.8)
                                willRotateLayer.position = CGPoint(x: 0, y: willRotateLayer.bounds.height)
                                willRotateLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
                            }
                            else {
                                willRotateLayer.anchorPoint = CGPoint(x: 0.8, y: 0.8)
                                willRotateLayer.position = CGPoint(x: willRotateLayer.bounds.width, y: willRotateLayer.bounds.height)
                                willRotateLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
                            }
                            rotateDirection = !rotateDirection
                        }
                        
                        tempLayer = CALayer()
                        tempLayer.frame = CGRect(x: 0, y: 0, width: textAnimationLayer.frame.size.width, height: textAnimationLayer.frame.size.height / 2.0)
                        textAnimationLayer.addSublayer(tempLayer)
                        rotateLayerList.append(RotateLayerModel(layer: tempLayer, direction: rotateDirection))
                    }
                }
                else {
                    let reversedList = remainItemList.reversed()
                    var lastOffY: CGFloat?
                    reversedList.forEach { view in
                        let frame = view.frame
                        if let lastOffY {
                            view.frame = CGRect(x: frame.origin.x, y: lastOffY - frame.size.height, width: frame.size.width, height: frame.size.height)
                        }
                        else {
                            let tempOffY = frame.size.height / 2.0 + textLabelHeight / 2.0
                            view.frame = CGRect(x: frame.origin.x, y: frame.origin.y - tempOffY, width: frame.size.width, height: frame.size.height)
                        }
                        lastOffY = view.frame.origin.y
                    }
                    
                    rotateLayerList.enumerated().forEach { [weak self] (offset, layerModel) in
                        guard let self else { return }
                        if offset != rotateLayerList.count - 1 {
                            let layer = layerModel.layer
                            let direction = layerModel.direction
                            layer.transform = CATransform3DTranslate(layer.transform, direction ? textLabelHeight : -1 * textLabelHeight, 0, 0)
                        }
                    }
                }
                
                rotateAnimateText.alpha = 1.0
                //rotateAnimateText.font = UIFont.systemFont(ofSize: 16 * currentFontScale)
                rotateAnimateText.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                textAnimationLayer.layoutSublayers()
            }
            remainingAnimations.append((animator, rotateAnimateText))
            addedList.append(rotateAnimateText)
        }
    }
}

class TextAnimationLayer: CALayer {
    
    var tempLayer = CALayer()
    
    // 文字数组
//    let texts = ["Hello World", "Swift", "Animation", "BackgroundColor", "rotate_ViewDidLoad", "ViewWillAppear"]
    let texts = ["Hello World", "AIG", "Animation", "BackgroundColor", "rotate_ViewDidLoad",
                 "ViewWillAppear", "TextRotateAnimate", "UIViewController", "addSublayer", "rotate_CGRect",
                 "UIViewProperty", "kScreenWidth", "kScreenHeight", "setTitleColor", "rotate_Action",
                 "backgroundColor"]
    var remainingAnimations: [(UIViewPropertyAnimator, UIView)] = []
    
    var addedList: [UIView] = []
    var remainItemList: [UIView] = []
    var rotateLayerList: [RotateLayerModel] = []
    var rotateDirection: Bool = true // false 向右 true 向左
    var currentFontScale: CGFloat = 1.0
    
    init(frame: CGRect) {
        super.init()
        self.frame = frame
        
        addAnimator()
        playAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnimator() {
        if addedList.count < texts.count {
            let text = texts[addedList.count]
            //currentFontScale = CGFloat.random(in: 1.0...2.0)
            currentFontScale = text.count > 15 ? 1.0 : 20 / CGFloat(text.count)
            
            let attributedString = NSMutableAttributedString(string: text)
            var attributes:[NSAttributedString.Key:Any] = [:]
            attributes[.font] = UIFont.systemFont(ofSize: 16 * currentFontScale)
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: (text as NSString).length))
            var stringSize = attributedString.boundingRect(with: CGSize(width: 300, height: 300), options: .usesLineFragmentOrigin, context: nil).size
            if stringSize.height < 40 {
                stringSize.height += 10
            }
            let textLabelHeight = stringSize.height
            let rotateAnimateText = RotateAnimateLabel(frame: CGRect(x: (bounds.size.width - 300) / 2.0, y: (bounds.size.height - textLabelHeight) / 2.0, width: 300, height: textLabelHeight))
            rotateAnimateText.alpha = 0.0
            //rotateAnimateText.textAlignment = rotateDirection ? .right : .left
            rotateAnimateText.textAlignment = .center
            rotateAnimateText.text = text
            rotateAnimateText.font = UIFont.systemFont(ofSize: 16 * currentFontScale)
            rotateAnimateText.textColor = [UIColor.green, UIColor.white].randomElement()
            //rotateAnimateText.backgroundColor = UIColor.red
            
            if addedList.count % RotateNum == 0 {
                //rotateAnimateText.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                rotateAnimateText.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            else {
                rotateAnimateText.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            addSublayer(rotateAnimateText.layer)
            
            remainItemList = Array(addedList)
            if addedList.count > RotateNum {
                while remainItemList.count > RotateNum {
                    remainItemList = Array(remainItemList.suffix(from: RotateNum))
                }
            }
            
            /// Double(text.count) * 0.1
            let animator = UIViewPropertyAnimator(duration: 0.8, curve: .easeOut) { [weak self] in
                guard let self else { return }
                
                if remainItemList.count % RotateNum == 0 {
                    /// 旋转时机
                    //rotateAnimateText.transform = CGAffineTransform(rotationAngle: 0)
                    
                    if remainItemList.isEmpty {
                        tempLayer = CALayer()
                        tempLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height / 2.0)
                        addSublayer(tempLayer)
                        rotateLayerList.append(RotateLayerModel(layer: tempLayer, direction: rotateDirection))
                    }
                    else {
                        if let willRotateLayerModel = rotateLayerList.last {
                            let willRotateLayer = willRotateLayerModel.layer
                            if rotateDirection {
                                willRotateLayer.anchorPoint = CGPoint(x: 0, y: 0.8)
                                willRotateLayer.position = CGPoint(x: 0, y: willRotateLayer.bounds.height)
                                willRotateLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
                            }
                            else {
                                willRotateLayer.anchorPoint = CGPoint(x: 0.8, y: 0.8)
                                willRotateLayer.position = CGPoint(x: willRotateLayer.bounds.width, y: willRotateLayer.bounds.height)
                                willRotateLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
                            }
                            rotateDirection = !rotateDirection
                        }
                        
                        tempLayer = CALayer()
                        tempLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height / 2.0)
                        addSublayer(tempLayer)
                        rotateLayerList.append(RotateLayerModel(layer: tempLayer, direction: rotateDirection))
                    }
                }
                else {
                    let reversedList = remainItemList.reversed()
                    var lastOffY: CGFloat?
                    reversedList.forEach { view in
                        let frame = view.frame
                        if let lastOffY {
                            view.frame = CGRect(x: frame.origin.x, y: lastOffY - frame.size.height, width: frame.size.width, height: frame.size.height)
                        }
                        else {
                            let tempOffY = frame.size.height / 2.0 + textLabelHeight / 2.0
                            view.frame = CGRect(x: frame.origin.x, y: frame.origin.y - tempOffY, width: frame.size.width, height: frame.size.height)
                        }
                        lastOffY = view.frame.origin.y
                    }
                    
                    rotateLayerList.enumerated().forEach { [weak self] (offset, layerModel) in
                        guard let self else { return }
                        if offset != rotateLayerList.count - 1 {
                            let layer = layerModel.layer
                            let direction = layerModel.direction
                            layer.transform = CATransform3DTranslate(layer.transform, direction ? textLabelHeight : -1 * textLabelHeight, 0, 0)
                        }
                    }
                }
                
                rotateAnimateText.alpha = 1.0
                //rotateAnimateText.font = UIFont.systemFont(ofSize: 16 * currentFontScale)
                rotateAnimateText.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                layoutSublayers()
            }
            remainingAnimations.append((animator, rotateAnimateText))
            addedList.append(rotateAnimateText)
        }
    }
    
    private func playAnimations() {
        guard let firstAnimator = remainingAnimations.first else {
            return
        }
        
        firstAnimator.0.addCompletion { [weak self] position in
            guard let self else { return }
            
            let element = remainingAnimations.removeFirst()
            if let willRotateLayerModel = rotateLayerList.last {
                willRotateLayerModel.layer.addSublayer(element.1.layer)
            }
            
            addAnimator()
            if let _ = remainingAnimations.first {
                playAnimations()
            } else {
                print("complete")
            }
        }
        firstAnimator.0.startAnimation()
    }
}
