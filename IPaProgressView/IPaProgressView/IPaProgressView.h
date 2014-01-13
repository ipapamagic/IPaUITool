//
//  IPaProgressView.h
//  IPaProgressView
//
//  Created by IPa Chen on 2013/11/7.
//  Copyright (c) 2013年 AMagicStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaProgressView : UIView
@property (nonatomic,assign) CGFloat progress;
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated;
-(void)setProgressColor:(UIColor*)color;
-(void)setProgressImage:(UIImage*)image;
-(void)setBackgroundImage:(UIImage*)image;
@end
