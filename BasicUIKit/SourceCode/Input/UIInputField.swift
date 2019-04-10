//
//  UIInputField.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/5.
//  Copyright © 2018 李招利. All rights reserved.
//

import UIKit

#if canImport(CoreAnimations)
import CoreAnimations
#endif
//
//#if canImport(RichText)
//import RichText
//#endif

open class UIInputField: UIView {
    
    @IBOutlet open weak var delegate:UITextFieldDelegate?

    @IBOutlet open weak var inputStateLabel:UILabel! {
        didSet { inputStateLabel?.text = nil }
    }
    @IBOutlet open weak var placeholderLabel:UILabel! {
        didSet { placeholderLabel?.alpha = 0 }
    }
    @IBOutlet open weak var bottomLine:UIView! {
        didSet { bottomLine?.backgroundColor = bottomLineColor(textField?.isFirstResponder ?? false) }
    }
    @IBOutlet open weak var textField:UITextField! {
        didSet {
            if delegate == nil {
                delegate = textField?.delegate
            }
            _backgroundColor = super.backgroundColor
            textField?.delegate = self
        }
    }
    
    private func bottomLineColor(_ isFirstResponder:Bool) -> UIColor? {
        if isFirstResponder {
            return placeholderLabel?.highlightedTextColor ?? UIColor(white: 0.85, alpha: 1)
        }
        return UIColor(white: 0.85, alpha: 1)
    }
    private var _backgroundColor: UIColor?
    open override var backgroundColor: UIColor? {
        get { return _backgroundColor }
        set {
            _backgroundColor = newValue
            super.backgroundColor = newValue
        }
    }
    
    public func updateSuper(backgroundColor:UIColor?) {
        super.backgroundColor = backgroundColor
    }
    
    open var verifierResult:InputVerifierResult = .waiting
    open var limiter:InputLimiter?
    open var verifier:InputVerifier? = PhoneVerifier()
    
}

private let kPlaceholderAnimate:String = "placeholder.animate"

extension UIInputField : UITextFieldDelegate {
    
    
    private func showPlaceholderAnimating(_ textField: UITextField) {
        var rect = textField.placeholderRect(forBounds: textField.bounds)
        rect = textField.convert(rect, to: self)
        
        guard let placeholderLayer = placeholderLabel?.layer else { return }
        let position = placeholderLayer.position
        let offsetX = rect.minX - placeholderLayer.frame.minX
        let startPoint = CGPoint(x: position.x + offsetX, y: rect.minY + rect.height / 2)
        let endPoint = CGPoint(x: position.x, y: position.y)
        placeholderLayer.opacity = 1
        
        #if canImport(CoreAnimations)
        placeholderLayer.animate(forKey: kPlaceholderAnimate) {
            $0.position.value(from: startPoint, to: endPoint, duration: 0.25)
            $0.alpha.value(from: 0, to: 1, duration: 0.25)
            $0.timingFunction(.easeOut)
        }
        #endif
    }
    
    private func hidePlaceholderAnimating(_ textField: UITextField) {
        var rect = textField.placeholderRect(forBounds: textField.bounds)
        rect = textField.convert(rect, to: self)
        
        guard let placeholderLayer = placeholderLabel?.layer else { return }
        let position = placeholderLayer.position
        let offsetX = rect.minX - placeholderLayer.frame.minX
        let endPoint = CGPoint(x: position.x + offsetX, y: rect.minY + rect.height / 2)
        placeholderLayer.opacity = 0
        #if canImport(CoreAnimations)
        placeholderLayer.animate(forKey: kPlaceholderAnimate) {
            $0.position.value(to: endPoint, duration: 0.15)
            $0.alpha.value(to: 0, duration: 0.15)
            $0.timingFunction(.easeOut)
        }
        #endif
    }
    
    private func didEndEditingAnimating(_ textField: UITextField) {
        
        placeholderLabel?.isHighlighted = false
        bottomLine?.backgroundColor = bottomLineColor(false)
        
        verifier?.verify(text: textField.text ?? "") { [weak self] (result) in
            guard let this = self else { return }
            
            switch result {
            case .nothing:
                this.inputStateLabel?.attributedText = nil
                this.updateSuper(backgroundColor: this._backgroundColor)
            case .waiting:
                this.inputStateLabel?.attributedText = nil
                this.updateSuper(backgroundColor: this._backgroundColor)
            case .warning(let state, let backgroundColor):
                this.inputStateLabel?.attributedText = state
                this.updateSuper(backgroundColor: backgroundColor)
            case .failure(let state, let backgroundColor):
                this.inputStateLabel?.attributedText = state
                this.updateSuper(backgroundColor: backgroundColor)
            case .success(let state, let backgroundColor):
                this.inputStateLabel?.attributedText = state
                this.updateSuper(backgroundColor: backgroundColor)
            }
            this.verifierResult = result
        }
        
        if !(textField.text?.isEmpty ?? true) { return }
        
        hidePlaceholderAnimating(textField)
    }
    
    @available(iOS 2.0, *)
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    @available(iOS 2.0, *)
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        inputStateLabel?.attributedText = nil
        placeholderLabel?.isHighlighted = true
        bottomLine?.backgroundColor = bottomLineColor(true)
        updateSuper(backgroundColor: _backgroundColor)
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    @available(iOS 2.0, *)
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    @available(iOS 2.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditingAnimating(textField)
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let didEndEditing = delegate?.textFieldDidEndEditing(_:reason:) {
            didEndEditingAnimating(textField)
            didEndEditing(textField, reason)
        } else {
            textFieldDidEndEditing(textField)
        }
    }
    
    @available(iOS 2.0, *)
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text ?? ""
        let result1 = limiter?.allowChange(text: oldText, range: range, replaceTo: string, fromInput: textField) ?? true
        let result2 = delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        let result = result1 && result2
        if  result {
            if  oldText.isEmpty {
                showPlaceholderAnimating(textField)
            } else {
                let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
                if  newText.isEmpty {
                    hidePlaceholderAnimating(textField)
                }
            }
        }
        return result
    }
    
    @available(iOS 2.0, *)
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let result = delegate?.textFieldShouldClear?(textField) ?? true
        defer { if result { hidePlaceholderAnimating(textField) } }
        return result
    }
    
    @available(iOS 2.0, *)
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let result = delegate?.textFieldShouldReturn?(textField) ?? true
        defer { if result { didEndEditingAnimating(textField) } }
        return result
    }
    
}


extension UIInputField {
    
    
    public var text:String? {
        
        get { return textField?.text }
        set {
            guard let field = textField else { return }
            let length = field.offset(from: field.beginningOfDocument, to: field.endOfDocument)
            let range = NSRange(location: 0, length: length)
            if textField(field, shouldChangeCharactersIn: range, replacementString: newValue ?? "") {
                field.text = newValue
                field.sendActions(for: .editingChanged)
                didEndEditingAnimating(field)
            }
        }
        
    }
    
}
