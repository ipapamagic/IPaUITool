//
//  UIButton+IPaUITool.swift
//  IPaUITool
//
//  Created by IPa Chen on 2015/10/5.
//  Copyright © 2015年 A Magic Studio. All rights reserved.
//

import UIKit

extension UIButton
{
    func centerImageUpTitleDown(space:CGFloat) {
        let imageSize = imageView.image.size
        titleEdgeInsets = UIEdgeInsetsMake(
            0.0, - imageSize.width, - (imageSize.height + space), 0.0)
        
        // raise the image and push it right so it appears centered
        //  above the text
        let titleSize = titleLabel.text.sizeWithAttributes([NSFontAttributeName: titleLabel.font])
        imageEdgeInsets = UIEdgeInsetsMake(
        - (titleSize.height + space), 0.0, 0.0, - titleSize.width)
    }
    func imageAlignRight(space:CGFloat) {
        titleEdgeInsets = UIEdgeInsetsMake(0, -imageView.frame.size.width - space, 0, imageView.frame.size.width);
        imageEdgeInsets = UIEdgeInsetsMake(0, titleLabel.frame.size.width + space, 0, -titleLabel.frame.size.width);
        
        contentEdgeInsets = UIEdgeInsetsMake(0, space, 0, space);
    }
}

   