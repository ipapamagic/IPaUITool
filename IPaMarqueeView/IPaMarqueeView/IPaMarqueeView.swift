//
//  IPaMarqueeView.swift
//  IPaMarqueeView
//
//  Created by IPa Chen on 2015/10/3.
//  Copyright © 2015年 A Magic Studio. All rights reserved.
//

import UIKit

class IPaMarqueeView: UIView {
    let layerAnimationKey = "Marquee"
    var marqueeQueue = [String]()
    var currentMarqueeIndex = 0
    var isAnimPlaying = false
    @IBOutlet lazy var textLabel:UILabel! = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textLabel)
        var constraint = NSLayoutConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        //        constraint = NSLayoutConstraint(item: textLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        //        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        return textLabel
    }()
    var scrollingSpeed:CGFloat = 100
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    func isAnimating() -> Bool {
        return textLabel.layer.animationForKey(layerAnimationKey) != nil
    }
    func playText(text:String) {
        marqueeQueue.removeAll()
        marqueeQueue.append(text)
        textLabel.text = text
    }
    func startAnimation() {
        if isAnimPlaying {
            return
        }
        isAnimPlaying = true
        playAnimation()
    }
    func playAnimation() {
        
        self.textLabel.layer.transform = CATransform3DMakeTranslation(bounds.width, 0, 0)
        if self.marqueeQueue.count == 0 {
            return
        }
        if self.currentMarqueeIndex >= self.marqueeQueue.count {
            self.currentMarqueeIndex = 0
        }

        self.textLabel.text = self.marqueeQueue[self.currentMarqueeIndex]
        self.textLabel.sizeToFit()
//        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D: CATransform3DMakeTranslation(bounds.width, 0, 0))
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeTranslation(-textLabel.bounds.width, 0, 0))
        animation.duration = NSTimeInterval((bounds.width + textLabel.bounds.width) / scrollingSpeed)
        animation.removedOnCompletion = true
        animation.delegate = self
//        CATransaction.setCompletionBlock({
//            if !self.isAnimPlaying {
//                return
//            }
//            self.currentMarqueeIndex++
//            if self.currentMarqueeIndex >= self.marqueeQueue.count {
//                self.currentMarqueeIndex = 0
//            }
//
//            self.playAnimation()
//        })
        
        textLabel.layer.addAnimation(animation, forKey: layerAnimationKey)
        //        animation.fromValue =
        

//        CATransaction.commit()
    }
    func stopAnimation() {
        isAnimPlaying = false
        textLabel.layer.transform = CATransform3DIdentity
        textLabel.layer.removeAllAnimations()
//        textLabel.layer.removeAnimationForKey(layerAnimationKey)
    }
    
    func pauseAnimation() {
        let pausedTime = textLabel.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        textLabel.layer.speed = 0
        textLabel.layer.timeOffset = pausedTime
    }
    func resumeAnimation() {
        let pausedTime = textLabel.layer.timeOffset
        textLabel.layer.speed = 1
        textLabel.layer.timeOffset = 0
        textLabel.layer.beginTime = 0
        let timeSincePause = textLabel.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {
        if !self.isAnimPlaying || !flag {
            return
        }
        self.currentMarqueeIndex++
        if self.currentMarqueeIndex >= self.marqueeQueue.count {
            self.currentMarqueeIndex = 0
        }
        
        self.playAnimation()
    }
}
