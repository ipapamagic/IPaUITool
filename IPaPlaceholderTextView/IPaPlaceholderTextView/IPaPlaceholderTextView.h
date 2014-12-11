//
//  IPaPlaceholderTextView.h
//  IPaPlaceholderTextView
//
//  Created by IPa Chen on 2014/1/13.
//  Copyright (c) 2014年 AMagicStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface IPaPlaceholderTextView : UITextView
@property (nonatomic,copy) IBInspectable NSString *placeholder;
@property (nonatomic,strong) IBInspectable UIColor *placeholderColor;
@end
