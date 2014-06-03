//
//  IPaImagePreviewView.m
//  IPaImagePreviewView
//
//  Created by IPa Chen on 2014/6/3.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "IPaImagePreviewView.h"
@interface IPaImagePreviewView () <UIScrollViewDelegate>
@end
@implementation IPaImagePreviewView
{
    UIImageView *previewImgView;
    NSLayoutConstraint *imgViewWidthConstraint;
    NSLayoutConstraint *imgViewHeightConstraint;
    NSLayoutConstraint *imgViewTopConstraint;
    NSLayoutConstraint *imgViewLeftConstraint;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialPreviewView];
    }
    return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialPreviewView];
}
-(void)initialPreviewView
{
    self.delegate = self;
    if (previewImgView != nil) {
        return;
    }
    previewImgView = [[UIImageView alloc] init];
    
    [previewImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:previewImgView];
    NSDictionary *views = NSDictionaryOfVariableBindings(previewImgView,self);
    
    imgViewWidthConstraint = [NSLayoutConstraint constraintWithItem:previewImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetWidth(self.frame)];
    imgViewHeightConstraint = [NSLayoutConstraint constraintWithItem:previewImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:CGRectGetHeight(self.frame)];
    imgViewLeftConstraint = [NSLayoutConstraint constraintWithItem:previewImgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    imgViewTopConstraint = [NSLayoutConstraint constraintWithItem:previewImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previewImgView]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previewImgView]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:@[imgViewLeftConstraint,imgViewTopConstraint,imgViewWidthConstraint,imgViewHeightConstraint]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)refreshConstraint
{
    CGFloat imageWidth = previewImgView.image.size.width;
    CGFloat imageHeight = previewImgView.image.size.height;
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    
    
    CGFloat ratio = imageWidth / imageHeight;
    CGFloat viewRatio = viewWidth / viewHeight;
    
    
    CGFloat imageViewWidth;
    CGFloat imageViewHeight;
    if (ratio >= viewRatio) {
        imageViewWidth = viewWidth;
        imageViewHeight = viewWidth / ratio;
        imgViewLeftConstraint.constant = 0;
        imgViewTopConstraint.constant = (viewHeight - imageViewHeight) * .5;
        
    }
    else {
        imageViewHeight = viewHeight;
        imageViewWidth = viewHeight * ratio;
        imgViewTopConstraint.constant = 0;
        imgViewLeftConstraint.constant = (viewWidth - imageViewWidth) * .5;
    }
    if (self.zoomScale > 1) {
        imgViewTopConstraint.constant = 0;
        imgViewLeftConstraint.constant = 0;
    }
    imgViewWidthConstraint.constant = imageViewWidth;
    imgViewHeightConstraint.constant = imageViewHeight;
}
-(void)setImage:(UIImage *)image
{
    [previewImgView setImage:image];
    [self refreshConstraint];
    [self layoutIfNeeded];
    
}
-(UIImage*)image
{
    return previewImgView.image;
}
#pragma mark - UIScrollViewDelegate
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   
    return previewImgView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshConstraint];
    [UIView animateWithDuration:0.3 animations:^(){
        [self layoutIfNeeded];
    }];
}

@end
