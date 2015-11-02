//
//  IPaPlaceholderTextView.swift
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2015/7/10.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import UIKit
//@IBDesignable
public class IPaPlaceholderTextView: UITextView {
    
    @IBInspectable dynamic public var placeholder = ""
    @IBInspectable dynamic var placeholderColor = UIColor.darkGrayColor()
    lazy var placeholderLabelLeftConstraint = NSLayoutConstraint()
    lazy var placeholderLabelRightConstraint = NSLayoutConstraint()
    lazy var placeholderLabelTopConstraint = NSLayoutConstraint()
    lazy var placeholderLabel:UILabel = {
        
        var _placeholderLabel = UILabel(frame: CGRect(x: self.textContainerInset.left, y: self.textContainerInset.top, width: self.bounds.width - (self.textContainerInset.left + self.textContainerInset.right), height: 0))
        _placeholderLabel.lineBreakMode = .ByWordWrapping
        _placeholderLabel.numberOfLines = 0
        _placeholderLabel.font = self.font
        _placeholderLabel.backgroundColor = UIColor.clearColor()
        _placeholderLabel.textColor = self.placeholderColor
        _placeholderLabel.text = self.placeholder
        _placeholderLabel.sizeToFit()
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_placeholderLabel)
        self.textContainer.lineFragmentPadding = 0
        self.placeholderLabelLeftConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: self.textContainerInset.left)
        
        self.placeholderLabelRightConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: NSLayoutRelation.Equal, toItem: _placeholderLabel, attribute: .Trailing, multiplier: 1, constant: self.textContainerInset.right)
        
        self.placeholderLabelTopConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem:self , attribute: .Top, multiplier: 1, constant: self.textContainerInset.top)
        
        self.addConstraints([self.placeholderLabelLeftConstraint,self.placeholderLabelRightConstraint,self.placeholderLabelTopConstraint])
        
        
        
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
            self.placeholderLabel.hidden = (self.text.characters.count > 0)
            self.placeholderLabel.sizeToFit()
        })
        placeholderLabel.hidden = text.characters.count > 0
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
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            switch (keyPath) {
            case "font":
                placeholderLabel.font = font
                placeholderLabel.sizeToFit()
                
            case "text":
                placeholderLabel.hidden = text.characters.count > 0
            case "placeholder":
                placeholderLabel.text = placeholder
                placeholderLabel.sizeToFit()
            case "placeholderColor":
                placeholderLabel.textColor = placeholderColor
            case "textContainerInset":
                self.placeholderLabelTopConstraint.constant = self.textContainerInset.top
                self.placeholderLabelLeftConstraint.constant = self.textContainerInset.left
                self.placeholderLabelRightConstraint.constant = self.textContainerInset.right
                placeholderLabel.superview?.updateConstraintsIfNeeded()
            default:
                break
            }
        }
    }
    
    
}
