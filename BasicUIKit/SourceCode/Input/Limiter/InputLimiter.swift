//
//  InputLimiter.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/5.
//  Copyright © 2018 李招利. All rights reserved.
//

import Basic

public protocol InputLimiter {
    
    func allowChange(text:String, range:NSRange, replaceTo value:String, fromInput input:UITextInput) -> Bool
    
}

extension UITextInput {
    
    public func conver(textRange:UITextRange) -> NSRange {
        var range = NSRange(location: 0, length: 0)
        range.location = offset(from: beginningOfDocument, to: textRange.start)
        let end = offset(from: beginningOfDocument, to: textRange.end)
        range.length = end - range.location
        return range
    }
    
    public func conver(range:NSRange) -> UITextRange? {
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: beginningOfDocument, offset: range.location + range.length) else {
                return nil
        }
        return textRange(from: start, to: end)
    }
    
    fileprivate func replace(to value:String) {
        if let range = textRange(from: beginningOfDocument, to: endOfDocument) {
            setMarkedText(nil, selectedRange: NSRange(location: 0, length: 0))
            replace(range, withText: value)
            selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
        }
        
    }
}

open class NoneLimiter : InputLimiter {
    
    public init () {}
    open func allowChange(text: String, range: NSRange, replaceTo value: String, fromInput input:UITextInput) -> Bool {
        return true
    }
}

open class LengthLimiter : InputLimiter {
    
    open var maxCount:Int = 0
    
    public init () {}
    public init(maxCount:Int = 0) {
        self.maxCount = maxCount
    }
    
    open func allowChange(text: String, range: NSRange, replaceTo value: String, fromInput input:UITextInput) -> Bool {
        guard maxCount > 0 else { return true }
        
        let oldText = text
        let newText = oldText.replacingCharacters(in: range, with: value)
        let oldCount = oldText.distance(from: oldText.startIndex, to: oldText.endIndex)
        let newCount = newText.distance(from: newText.startIndex, to: newText.endIndex)
        
        var change:Bool = newCount < oldCount || newCount <= maxCount
        if let textRange = input.markedTextRange {
            let markedRange = input.conver(textRange: textRange)
            
            // 如果是拼音输入的markedText 则允许继续
            if !NSEqualRanges(markedRange, range), markedRange.length != 0 {
                // 与替换范围相等则表示从拼音转成用户选择的文字
                change = true
            } else {
                change = newCount <= maxCount
            }
        }
        return change
        
    }
}


open class NumberLimiter : InputLimiter {
    
    var isInteger:Bool = false
    var max:Double = .infinity  // 无限的
    var min:Double = .infinity  // 无限的
    
    public init(max:Double = .infinity, min:Double = .infinity, isInteger:Bool = false) {
        self.max = max
        self.min = min
        self.isInteger = isInteger
    }
    
    open func allowChange(text: String, range: NSRange, replaceTo value: String, fromInput input:UITextInput) -> Bool {
        let newText = text.replacingCharacters(in: range, with: value)
        
        var change:Bool = false
        if newText.isEmpty {
            return true
        } else if isInteger, newText.isInteger {
            change = true
        } else if !isInteger, newText.isNumeric {
            change = true
        } else {
            return false
        }
        
        if  max != .infinity, let value = Double(newText), value > max {
            change = false
            input.replace(to: String(describing: NSNumber(value: max)))
        }
        if  min != .infinity, let value = Double(newText), value < min {
            change = false
            input.replace(to: String(describing: NSNumber(value: min)))
        }
        return change
    }
    
    
}

open class PhoneLimiter : LengthLimiter {
    
    public override init() { super.init(maxCount: 11) }
    
    open override func allowChange(text: String, range: NSRange, replaceTo value: String, fromInput input:UITextInput) -> Bool {
        
        if range.location == 0, !value.isEmpty, value.first != "1" {
            return false
        }
        return super.allowChange(text: text, range: range, replaceTo: value, fromInput: input)
    }
    
    
}


