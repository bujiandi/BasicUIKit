//
//  UIGradientButton.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/1.
//  Copyright © 2018 李招利. All rights reserved.
//

import UIKit

@IBDesignable
open class UIGradientButton: UIButton {

    @IBInspectable open var cornerRadii:CGSize = .zero {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var corners:UIRectCorner = .allCorners {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var startPoint:CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var endPoint:CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var startLocation:CGFloat = 0 {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var endLocation:CGFloat = 1 {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var startColor:UIColor? = nil {
        didSet { updateBackgroundImage() }
    }
    @IBInspectable open var endColor:UIColor? = nil {
        didSet { updateBackgroundImage() }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.size
        if  size != oldSize {
            updateBackgroundImage()
        }
    }
    
    private lazy var oldSize:CGSize = frame.size
    private func updateBackgroundImage() {
        let rect = bounds
        let size = rect.size

        oldSize = size

        guard let start = startColor, let end = endColor else {
            setBackgroundImage(nil, for: .normal)
            setBackgroundImage(nil, for: .highlighted)
            return
        }
        
        let opaque:Bool = backgroundColor != nil && backgroundColor != .clear
        let scale:CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            oldSize = .zero
            return setNeedsLayout()
        }

        if opaque {
            backgroundColor!.setFill()
            UIRectFill(rect)
        }
        if cornerRadii.width != 0 || cornerRadii.height != 0 {
            
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
            //  进行路劲裁切   后续的绘图都会出现在圆形内  外部的都被干掉
            path.addClip()
        }
        
        let layer = CAGradientLayer()
        layer.frame = rect
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.colors = [start.cgColor, end.cgColor]
        layer.locations = [startLocation, endLocation].map { $0 as NSNumber }
        layer.render(in: context)
        
        var outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(outputImage, for: .normal)
        
        // 设置高亮图片
        layer.colors = [start.darkerColor(threshold: 0.2).cgColor, end.darkerColor(threshold: 0.2).cgColor]
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        if opaque {
            backgroundColor!.setFill()
            UIRectFill(rect)
        }
        if cornerRadii.width != 0 || cornerRadii.height != 0 {
            
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
            //  进行路劲裁切   后续的绘图都会出现在圆形内  外部的都被干掉
            path.addClip()
        }
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(outputImage, for: .highlighted)

    }
}

