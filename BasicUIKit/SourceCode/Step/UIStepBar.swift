//
//  UIStepBar.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/6.
//  Copyright © 2018 李招利. All rights reserved.
//

import UIKit
import Basic
#if canImport(CoreAnimations)
import CoreAnimations
#endif


@IBDesignable
open class UIStepBar: UIControl {

    @IBOutlet weak open var delegate:UIStepBarDelegate?
    
    @IBInspectable open var stepLineColor:UIColor? = nil
    @IBInspectable open var stepPointColor:UIColor? = nil

    @IBInspectable open var stepHighlightColor:UIColor? = nil
    @IBInspectable open var stepBackgroundColor:UIColor? = nil

    @IBInspectable open var stepCurrentScale:CGFloat = 2
    
    @IBInspectable open var stepTitleSize:CGFloat = 14
    @IBInspectable open var stepTitleOffset:CGFloat = 8

    @IBInspectable open var stepLineWidth:CGFloat = 2
    @IBInspectable open var stepCornerRadius:CGFloat = 3
    
    @IBInspectable open var stepIndex:Int = 0 {
        didSet {
//            _step = newValue
            _epercent = 0
            if !_skipLayout {
                layoutStepLayers()
                sendActions(for: .valueChanged)
            }
        }
//        get { return _step }
    }
//    private var _step:Int = 0
    private var _skipLayout:Bool = false

    @IBInspectable open var stepCount:Int = 3 {
        didSet {
            _epercent = 0
            if stepCount != _stepLayers.count {
//                _step = 0
                _skipLayout = true
                stepIndex = 0
                _skipLayout = false

                // 更新步骤图层
                setupStepLayers()
                sendActions(for: .valueChanged)
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutStepLayers()
            CATransaction.commit()
        }
    }
    

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isUserInteractionEnabled, let point = touches.first?.location(in: self) else { return }
        
        for (i, layer) in _stepTextLayers.enumerated() {
            if layer.frame.minX < point.x, layer.frame.maxX > point.x {
                stepIndex = i
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layoutStepLayers()
        CATransaction.commit()
    }
    
    deinit { clearStepLayers() }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        setupStepLayers()
    }
    
    private var _stepLayers:[CAShapeLayer] = []
    private var _stepTextLayers:[CATextLayer] = []
    private var _stepHighlightLayer:CALayer? = nil
    private var _stepBackgroundLayer:CALayer? = nil
    
    private func clearStepLayers() {
        _stepLayers.forEach { $0.removeFromSuperlayer() }
        _stepTextLayers.forEach { $0.removeFromSuperlayer() }
        _stepHighlightLayer?.removeFromSuperlayer()
        _stepBackgroundLayer?.removeFromSuperlayer()
        
        _stepLayers = []
        _stepTextLayers = []
        _stepHighlightLayer = nil
        _stepBackgroundLayer = nil
    }
    
    private func layoutStepLayers() {
        if  stepCount < 1 { return }
        let insets = layoutMargins
        let width = bounds.width - insets.left - insets.right
//        let height = bounds.height - insets.top - insets.bottom
        let radius = stepCornerRadius

        let centerY = insets.top + radius + radius //height / 2
        let offsetY = stepTitleOffset + radius * 2 + stepTitleSize / 2 + 2

        let highlightColor = stepHighlightColor ?? tintColor
        let backgroundColor = stepBackgroundColor ?? UIColor.lightGray
        
        if  stepCount < 2 {
            let x = insets.left + width / 2
            _stepLayers.first?.position = CGPoint(x: x, y: centerY)
            _stepLayers.first?.fillColor = highlightColor?.cgColor
            _stepTextLayers.first?.position = CGPoint(x: x, y: centerY + offsetY)
            _stepTextLayers.first?.foregroundColor = highlightColor?.cgColor
            _stepHighlightLayer?.frame.size.width = 0
            _stepHighlightLayer?.position = CGPoint(x: x, y: centerY)
            _stepBackgroundLayer?.frame.size.width = 0
            _stepBackgroundLayer?.position = CGPoint(x: x, y: centerY)
            return
        }
        

        if  _stepLayers.count < stepCount { return }
        let count = CGFloat(stepCount - 1)
        
        let percentWidth = stepIndex < stepCount - 1 || _epercent < 0 ? width / count * _epercent : 0
        let highlightWidth = CGFloat(stepIndex) / count * width + percentWidth
        _stepHighlightLayer?.frame.size.width = highlightWidth
        _stepHighlightLayer?.position = CGPoint(x: insets.left + highlightWidth / 2, y: centerY)
        _stepBackgroundLayer?.frame.size.width = width
        _stepBackgroundLayer?.position = CGPoint(x: insets.left + width / 2, y: centerY)
        for i in 0..<stepCount {
            let x = (CGFloat(i) / count) * width + insets.left
            let color = i <= stepIndex ? highlightColor : backgroundColor
            let scale = i == stepIndex ? stepCurrentScale : 1
            _stepLayers[i].position = CGPoint(x: x, y: centerY)
            _stepLayers[i].fillColor = color?.cgColor
            _stepLayers[i].transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            _stepTextLayers[i].position = CGPoint(x: x, y: centerY + offsetY)
            _stepTextLayers[i].foregroundColor = color?.cgColor
//            print(_stepTextLayers[i].frame)
        }
    }
    
    private func setupStepLayers() {
        clearStepLayers()
        
        let position = center
        let scale = UIScreen.main.scale
        let radius = stepCornerRadius

        if stepCount > 1 {
            let backLayer = CALayer()
            backLayer.backgroundColor = (stepBackgroundColor ?? UIColor.lightGray)?.cgColor
            backLayer.contentsScale = scale
            backLayer.frame = CGRect(x: 0, y: 0, width: 0, height: stepLineWidth)
            backLayer.position = position
            backLayer.cornerRadius = stepLineWidth / 2
            layer.addSublayer(backLayer)
            _stepBackgroundLayer = backLayer
            
            let lineLayer = CALayer()
            lineLayer.backgroundColor = (stepHighlightColor ?? tintColor)?.cgColor
            lineLayer.contentsScale = scale
            lineLayer.frame = CGRect(x: 0, y: 0, width: 0, height: stepLineWidth)
            lineLayer.position = position
            lineLayer.cornerRadius = stepLineWidth / 2
            layer.addSublayer(lineLayer)
            _stepHighlightLayer = lineLayer
        }
        let side = radius * 2
        let fontSize = stepTitleSize
        for i in 0..<stepCount {
            let color:UIColor? = i <= stepIndex ? stepHighlightColor : stepBackgroundColor
            // 添加圆点
            let stepLayer = CAShapeLayer()
            stepLayer.path = delegate?.stepBar?(self, stepShapePathAt: i) ?? CGPath(roundedRect: CGRect(x: 0, y: 0, width: side, height: side), cornerWidth: radius, cornerHeight: radius, transform: nil)
            stepLayer.fillColor = (color ?? tintColor)?.cgColor
            stepLayer.frame = CGRect(x: 0, y: 0, width: side, height: side)
            stepLayer.position = position
            layer.addSublayer(stepLayer)
            _stepLayers.append(stepLayer)
            
            // 添加标题
            #if canImport(CoreAnimations)
            let textLayer = CATextLayer()
            #else
            let textLayer = CATextLayer()
            #endif
            
            let font = UIFont.systemFont(ofSize: fontSize)
            
            var rect = CGRect(x: 0, y: 0, width: 36, height: fontSize + 4)
            if let text = delegate?.stepBar?(self, titleAt: i), !text.isEmpty {
                if let attr = delegate?.stepBar?(self, attributesWithTitle: text, at: i) {
                    rect.size.width = attr.boundingRect(with: .zero, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width
                    textLayer.string = attr
                } else {
                    rect.size.width = (text as NSString).boundingRect(with: .zero, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font:font], context: nil).width
                    textLayer.string = text
                }
            } else {
                rect.size.width = 0
            }
            textLayer.isWrapped = true
            textLayer.truncationMode = .end
            textLayer.alignmentMode = .center
            textLayer.fontSize = fontSize
            textLayer.font = font.fontName as CFTypeRef //"HiraKakuProN-W3" as CFTypeRef
            //解决CATextLayer在Retina屏幕绘制字体模糊的问题
            textLayer.contentsScale = scale
            textLayer.foregroundColor = (stepPointColor ?? tintColor)?.cgColor
//            textLayer.borderColor = UIColor.lightGray.cgColor
//            textLayer.borderWidth = 1
            textLayer.frame = rect
            textLayer.position = position

            layer.addSublayer(textLayer)
            
            _stepTextLayers.append(textLayer)
        }
    }
    
    private var _epercent:CGFloat = 0
    public func from(step startStep:Int, toStep endStep:Int, epercent:CGFloat){
        
        if stepCount <= 1 {
            return
        }
        if startStep < 0 || startStep >= stepCount {
            return
        }
        if endStep < 0 || endStep >= stepCount {
            return
        }
        if epercent < CGFloat(0) || epercent > CGFloat(1) {
            return
        }
        let minStep = min(startStep, endStep)
        
        let count = CGFloat(stepCount) - 1
        let insets = layoutMargins
        let width = bounds.width - insets.left - insets.right
        let one = width / count

        let highlightWidth = (CGFloat(minStep) * one) + (one * epercent)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _stepHighlightLayer?.frame.size.width = highlightWidth
        _stepHighlightLayer?.position.x = insets.left + highlightWidth / 2
        CATransaction.commit()

        if highlightWidth < CGFloat(stepIndex) * one {
            _epercent = -(1 - epercent)
        } else {
            _epercent = epercent
        }
    }

}


@objc public protocol UIStepBarDelegate: class {
    
    @objc optional func stepBar(_ stepBar:UIStepBar, titleAt index:Int) -> String?
    
    @objc optional func stepBar(_ stepBar:UIStepBar, attributesWithTitle title:String, at index:Int) -> NSAttributedString?
    @objc optional func stepBar(_ stepBar:UIStepBar, stepShapePathAt index:Int) -> CGPath?
    
}

