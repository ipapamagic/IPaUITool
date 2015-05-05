//
//  IPaTextFieldTableViewCell.h
//  IPaTextFieldTableViewCell
//
//  Created by IPa Chen on 2015/5/4.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

// In this header, you should import all the public headers of your framework using statements like #import <IPaTextFieldTableViewCell/PublicHeader.h>

@protocol IPaTextFieldTableViewCellDelegate;
@interface IPaTextFieldTableViewCell : UITableViewCell
@property (nonatomic,copy) NSString *identifer;
@property (nonatomic,weak) id <IPaTextFieldTableViewCellDelegate> delegate;
@end
@protocol IPaTextFieldTableViewCellDelegate <NSObject>

- (void)onIPaTextFieldTableViewCellValueChanged:(IPaTextFieldTableViewCell*)cell value:(NSString*)value;
- (BOOL)onIPaTextFieldTableViewCell:(IPaTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string;
@end

