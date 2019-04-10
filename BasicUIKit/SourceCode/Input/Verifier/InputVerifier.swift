//
//  InputVerifier.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/5.
//  Copyright © 2018 李招利. All rights reserved.
//

import Basic
import UIKit

public enum InputVerifierResult {
    case nothing
    case waiting
    case success(NSAttributedString?, UIColor)
    case failure(NSAttributedString?, UIColor)
    case warning(NSAttributedString?, UIColor)
}

public protocol InputVerifier {
    
    func verify(text:String, resultHandle: @escaping (InputVerifierResult) -> Void)
    
}


open class NoneVerifier: InputVerifier {
    
    public init () {}
    
    open func verify(text:String, resultHandle: @escaping (InputVerifierResult) -> Void) {
        resultHandle(.nothing)
    }
    
}

open class PhoneVerifier: InputVerifier {
    
    private static let _map:[String:[String]] = [
        "电信(虚拟)":["1700","1701","1702"],
        "联通(虚拟)":["1704","1707","1708","1709","171"],
        "移动(虚拟)":["1703","1705","1706"],
        "中国电信":["133","149","153","173","177","180","181","189","199"],
        "中国联通":["130","131","132","145","155","156","166","175","176","185","186"],
        "中国移动":["134","135","136","137","138","139","147","150","151","152","157","158",
                        "159","178","182","183","184","187","188","198"]
    ]
    
    public init () {}
    
    open func verify(text:String, resultHandle: @escaping (InputVerifierResult) -> Void) {
        if  text.isEmpty {
            return resultHandle(.nothing)
        }
        let phoneCount = 11
        let length = text.distance(from: text.startIndex, to: text.endIndex)
        if  length < phoneCount {
            let title = "电话号码不完整"
            let color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            let state = NSAttributedString(string: title, attributes: [.foregroundColor : color])
            let backgroundColor = color.lighterColor(threshold: 0.75)
            return resultHandle(.failure(state, backgroundColor))
        }
        let isNumeric = text[3..<phoneCount].unicodeScalars
            .firstIndex(where: { !(48..<58).contains($0.value) }) == nil
        
        if  length > phoneCount || !text.hasPrefix("1") || !isNumeric {
            let title = "无效的电话号码"
            let color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            let state = NSAttributedString(string: title, attributes: [.foregroundColor : color])
            let backgroundColor = color.lighterColor(threshold: 0.75)
            return resultHandle(.failure(state, backgroundColor))
        }
        for (name, list) in PhoneVerifier._map {
            for num in list where text.hasPrefix(num) {
                let color = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                let state = NSAttributedString(string: name, attributes: [.foregroundColor : color])
                let backgroundColor = color.lighterColor(threshold: 0.75)
                return resultHandle(.success(state, backgroundColor))
            }
        }
        
        let color = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        let state = NSAttributedString(string: "未知运营商", attributes: [.foregroundColor : color])
        let backgroundColor = color.lighterColor(threshold: 0.75)
        return resultHandle(.warning(state, backgroundColor))
    }
    
}
