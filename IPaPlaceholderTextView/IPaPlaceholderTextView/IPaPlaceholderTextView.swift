//
//  IPaPlaceholderTextView.swift
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2015/7/10.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import UIKit
//@IBDesignable
open class IPaPlaceholderTextView: UITextView {
    
    @IBInspectable dynamic open var placeholder = ""
    @IBInspectable dynamic var placeholderColor = UIColor.darkGray
    lazy var placeholderLabelLeftConstraint = NSLayoutConstraint()
    //    lazy var placeholderLabelRightConstraint = NSLayoutConstraint()
    lazy var placeholderLabelWidthConstraint = NSLayoutConstraint()
    lazy var placeholderLabelTopConstraint = NSLayoutConstraint()
    lazy var placeholderLabel:UILabel = {
        
        var _placeholderLabel = UILabel()
        _placeholderLabel.lineBreakMode = .byWordWrapping
        _placeholderLabel.numberOfLines = 0
        //_placeholderLabel.preferredMaxLayoutWidth = 200
        _placeholderLabel.font = self.font
        _placeholderLabel.backgroundColor = UIColor.clear
        _placeholderLabel.textColor = self.placeholderColor
        _placeholderLabel.text = self.placeholder
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_placeholderLabel)
        self.textContainer.lineFragmentPadding = 0
        self.placeholderLabelLeftConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: .leading, multiplier: 1, constant: self.textContainerInset.left)
        //        self.placeholderLabelRightConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .Trailing, relatedBy: NSLayoutRelation.Equal, toItem:self , attribute: .Trailing, multiplier: 1, constant: self.textContainerInset.right)
        
        self.placeholderLabelWidthConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: -self.textContainerInset.left-self.textContainerInset.right)
        
        self.placeholderLabelTopConstraint = NSLayoutConstraint(item: _placeholderLabel, attribute: .top, relatedBy: NSLayoutRelation.equal, toItem:self , attribute: .top, multiplier: 1, constant: self.textContainerInset.top)
        
        
        self.addConstraints([self.placeholderLabelWidthConstraint,self.placeholderLabelTopConstraint,self.placeholderLabelLeftConstraint])
        
        
        
        return _placeholderLabel
    }()
    var textChangedObserver:NSObjectProtocol?
    override open func awakeFromNib() {
        super.awakeFromNib()
        initialPlaceholderLabel()
    }
    func initialPlaceholderLabel () {
        textChangedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: self, queue: nil, using: {
            noti in
            self.placeholderLabel.isHidden = (self.text.characters.count > 0)
            self.updateConstraintsIfNeeded()
        })
        self.placeholderLabel.isHidden = text.characters.count > 0
        addObserver(self, forKeyPath: "font", options: .new, context: nil)
        addObserver(self, forKeyPath: "text", options: .new, context: nil)
        addObserver(self, forKeyPath: "placeholder", options: .new, context: nil)
        addObserver(self, forKeyPath: "placeholderColor", options: .new, context: nil)
        addObserver(self, forKeyPath: "textContainerInset", options: .new, context: nil)
    }
    deinit {
        if let textChangedObserver = textChangedObserver {
            NotificationCenter.default.removeObserver(textChangedObserver)
        }
        //        removeObserver(self, forKeyPath: "font")
        //        removeObserver(self, forKeyPath: "text")
        //        removeObserver(self, forKeyPath: "placeholder")
        //        removeObserver(self, forKeyPath: "placeholderColor")
        //        removeObserver(self, forKeyPath: "textContainerInset")
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            switch (keyPath) {
            case "font":
                placeholderLabel.font = font
                placeholderLabel.superview?.updateConstraintsIfNeeded()
                
            case "text":
                placeholderLabel.isHidden = text.characters.count > 0
            case "placeholder":
                placeholderLabel.text = placeholder
                placeholderLabel.superview?.updateConstraintsIfNeeded()
            case "placeholderColor":
                placeholderLabel.textColor = placeholderColor
            case "textContainerInset":
                self.placeholderLabelTopConstraint.constant = self.textContainerInset.top
                self.placeholderLabelLeftConstraint.constant = self.textContainerInset.left
                //                self.placeholderLabelRightConstraint.constant = self.textContainerInset.right
                self.placeholderLabelWidthConstraint.constant =
                    -self.textContainerInset.left-self.textContainerInset.right
                placeholderLabel.superview?.updateConstraintsIfNeeded()
            default:
                break
            }
        }
    }
    
    
}
