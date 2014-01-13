//
//  IPaPlaceholderTextView.m
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2014/1/13.
//  Copyright (c) 2014年 AMagicStudio. All rights reserved.
//

#import "IPaPlaceholderTextView.h"

@implementation IPaPlaceholderTextView
{
    UILabel *placeholderLabel;
    id textChangedObserver;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialPlaceholder];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialPlaceholder];
}
-(void)initialPlaceholder
{
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    if ( placeholderLabel == nil )
    {
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
        placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.font = self.font;
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:placeholderLabel];
    }
    
    textChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self queue:nil usingBlock:^(NSNotification* noti){
        [placeholderLabel setHidden:([[self text] length] > 0)];
    }];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:textChangedObserver];
}
-(NSString*)placeholder
{
    return placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)newplaceholder
{
    placeholderLabel.text = newplaceholder;
    [placeholderLabel sizeToFit];
}
-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [placeholderLabel setTextColor:placeholderColor];
}
-(UIColor*)placeholderColor
{
    return [placeholderLabel textColor];
}
@end
