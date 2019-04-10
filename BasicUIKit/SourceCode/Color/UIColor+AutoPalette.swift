//
//  UIColor+AutoPalette.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/2.
//  Copyright © 2018 李招利. All rights reserved.
//

import UIKit



extension UIColor {
    
    public func darkerColor(threshold:CGFloat = 0.3) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let threshold = 1 - threshold
        r *= threshold * threshold
        g *= threshold * threshold
        b *= threshold * threshold
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    public func lighterColor(threshold:CGFloat = 0.3) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let threshold = 1 - threshold
        r = 1 - (1 - r) * threshold * threshold
        g = 1 - (1 - g) * threshold * threshold
        b = 1 - (1 - b) * threshold * threshold
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
