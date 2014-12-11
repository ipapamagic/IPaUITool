//
//  IPaPlaceholderTextView.m
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2014/1/13.
//  Copyright (c) 2014年 AMagicStudio. All rights reserved.
//

#import "IPaPlaceholderTextView.h"
@interface IPaPlaceholderTextView ()
@property (nonatomic,strong) UILabel *placeholderLabel;
@end
@implementation IPaPlaceholderTextView
{

    id textChangedObserver;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self placeholderLabel];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self placeholderLabel];
}
- (UILabel*)placeholderLabel
{
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
        _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.font = self.font;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:_placeholderLabel];
        textChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self queue:nil usingBlock:^(NSNotification* noti){
            [_placeholderLabel setHidden:([[self text] length] > 0)];
        }];
    }
    return _placeholderLabel;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:textChangedObserver];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self.placeholderLabel sizeToFit];
}
-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self.placeholderLabel setTextColor:placeholderColor];
}

@end
