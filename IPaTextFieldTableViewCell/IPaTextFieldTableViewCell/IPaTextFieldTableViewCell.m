//
//  IPaTextFieldTableViewCell.m
//  17gonplay
//
//  Created by IPa Chen on 2014/12/26.
//  Copyright (c) 2014年 SleepNova. All rights reserved.
//

#import "IPaTextFieldTableViewCell.h"
@interface IPaTextFieldTableViewCell()<UITextFieldDelegate>
@end
@implementation IPaTextFieldTableViewCell
{
    __weak IBOutlet UITextField *textField;
}
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    textField.delegate = self;
}
- (void)dealloc
{
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    [_textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return [self.delegate onIPaTextFieldTableViewCell:self shouldChangeCharactersInRange:range replacementString:(NSString *)string];
}
- (void)textFieldDidEndEditing:(UITextField *)_textField
{
    [self.delegate onIPaTextFieldTableViewCellValueChanged:self value:_textField.text];
}

@end
