//
//  UIButton+IPaUITool.m
//  IPaUITool
//
//  Created by IPa Chen on 2014/11/2.
//  Copyright (c) 2014年 AMagicStudio. All rights reserved.
//

#import "UIButton+IPaUITool.h"

@implementation UIButton (IPaUITool)
- (void)centerImageUpTitleDownWithSpace:(CGFloat)space
{
    // the space between the image and text
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = self.imageView.image.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + space), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + space), 0.0, 0.0, - titleSize.width);
}
@end
