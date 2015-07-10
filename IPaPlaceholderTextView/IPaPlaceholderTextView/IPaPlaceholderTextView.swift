//
//  IPaPlaceholderTextView.swift
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2015/7/10.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import UIKit
@IBDesignable
public class IPaPlaceholderTextView: UITextView {
    
    @IBInspectable public var placeholder = ""
    
    
    @IBInspectable var placeholderColor = UIColor.darkGrayColor()
    lazy var placeholderLabel:UILabel = {
        
        var _placeholderLabel = UILabel(frame: CGRect(x: self.textContainerInset.left, y: self.textContainerInset.top, width: self.bounds.width - (self.textContainerInset.left + self.textContainerInset.right), height: 0))
        _placeholderLabel.lineBreakMode = .ByWordWrapping
        _placeholderLabel.numberOfLines = 0
        _placeholderLabel.font = self.font
        _placeholderLabel.backgroundColor = UIColor.clearColor()
        _placeholderLabel.textColor = self.placeholderColor
        _placeholderLabel.text = self.placeholder
        _placeholderLabel.sizeToFit()
        self.addSubview(_placeholderLabel)
        
        
        return _placeholderLabel
        }()
    var textChangedObserver:NSObjectProtocol?
    override public func awakeFromNib() {
        super.awakeFromNib()
        initialPlaceholderLabel()
    }
    func initialPlaceholderLabel () {
        textChangedObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: self, queue: nil, usingBlock: {
            noti in
            self.placeholderLabel.hidden = (count(self.text) > 0)
            self.placeholderLabel.sizeToFit()
        })
        placeholderLabel.hidden = count(text) > 0
        addObserver(self, forKeyPath: "font", options: .New, context: nil)
        addObserver(self, forKeyPath: "text", options: .New, context: nil)
        addObserver(self, forKeyPath: "placeholder", options: .New, context: nil)
        addObserver(self, forKeyPath: "placeholderColor", options: .New, context: nil)
        addObserver(self, forKeyPath: "textContainerInset", options: .New, context: nil)
    }
    deinit {
        if let textChangedObserver = textChangedObserver {
            NSNotificationCenter.defaultCenter().removeObserver(textChangedObserver)
        }
        removeObserver(self, forKeyPath: "font")
        removeObserver(self, forKeyPath: "text")
        removeObserver(self, forKeyPath: "placeholder")
        removeObserver(self, forKeyPath: "placeholderColor")
        removeObserver(self, forKeyPath: "textContainerInset")
    }
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch (keyPath) {
        case "font":
            placeholderLabel.font = font
            placeholderLabel.sizeToFit()
            
        case "text":
            placeholderLabel.hidden = count(text) > 0
        case "placeholder":
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
        case "placeholderColor":
            placeholderLabel.textColor = placeholderColor
        case "textContainerInset":
            placeholderLabel.frame = CGRect(x: self.textContainerInset.left, y: self.textContainerInset.top, width: self.bounds.width - (self.textContainerInset.left + self.textContainerInset.right), height: 0)
            placeholderLabel.sizeToFit()
        default:
            break
        }
    }
    
    
}
