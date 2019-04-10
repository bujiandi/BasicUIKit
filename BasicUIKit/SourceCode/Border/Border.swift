//
//  Border.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/5.
//  Copyright © 2018 李招利. All rights reserved.
//

import UIKit

extension CGColor {
    var uiColor:UIColor { return UIColor(cgColor: self) }
}


//@IBDesignable
extension UIView {
    
    @objc @IBInspectable var cornerRadius:CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius }
    }
    
    @objc @IBInspectable var borderWidth:CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @objc @IBInspectable var borderColor:UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get { return layer.borderColor?.uiColor }
    }
    
    @objc @IBInspectable var shadowOffset:CGSize {
        set { layer.shadowOffset = newValue }
        get { return layer.shadowOffset }
    }
    
    @objc @IBInspectable var shadowColor:UIColor? {
        set { layer.shadowColor = newValue?.cgColor }
        get { return layer.shadowColor?.uiColor }
    }
    
    @objc @IBInspectable var shadowRadius:CGFloat {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @objc @IBInspectable var shadowOpacity:Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }
}
