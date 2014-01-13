//
//  IPaProgressView.m
//  IPaProgressView
//
//  Created by IPa Chen on 2013/11/7.
//  Copyright (c) 2013年 AMagicStudio. All rights reserved.
//

#import "IPaProgressView.h"
@interface IPaProgressView()
@property (nonatomic,strong) UIView *progressView;
@end
@implementation IPaProgressView
{

    UIImageView *bgImageView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
    
}
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _progress = progress;
    
    
    
}

-(void)setProgressColor:(UIColor*)color
{
    
}
-(void)setProgressImage:(UIImage*)image;
-(void)setBackgroundImage:(UIImage*)image;
@end
