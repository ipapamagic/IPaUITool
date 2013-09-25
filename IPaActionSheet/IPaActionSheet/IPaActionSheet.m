//
//  IPaActionSheet.m
//  IPaActionSheet
//
//  Created by IPaPa on 11/10/25.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IPaActionSheet.h"

@implementation IPaActionSheet
static NSMutableArray *actionSheetList;
+(void)RetainActionSheet:(IPaActionSheet*)actionSheet
{
    if (actionSheetList == nil) {
        actionSheetList = [@[] mutableCopy];
    }
    if ([actionSheetList indexOfObject:actionSheet] == NSNotFound)
    {
        [actionSheetList addObject:actionSheet];
    }
    
}
+(void)ReleaseActionSheet:(IPaActionSheet*)actionSheet
{
    [actionSheetList removeObject:actionSheet];
}


+(void) IPaActionSheetWithTitle:(NSString*)title 
                       callback:(void (^)(NSUInteger))callback
                          Style:(UIActionSheetStyle)Style
                       showView:(UIView*)showView
              cancelButtonIndex:(NSInteger)cancelButtonIndex 
         destructiveButtonIndex:(NSInteger)destructiveButtonIndex 
                   ButtonTitles:(NSString *)ButtonTitle,...
{
    IPaActionSheet *ActionSheet = [[IPaActionSheet alloc] initWithTitle:title
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:ButtonTitle, nil];
    ActionSheet.delegate = ActionSheet;
    id current;
    va_list argumentList;
    va_start(argumentList, ButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [ActionSheet addButtonWithTitle:current];
        current = va_arg(argumentList, id);
    }
    va_end(argumentList);
    ActionSheet.cancelButtonIndex = cancelButtonIndex;
    ActionSheet.destructiveButtonIndex = destructiveButtonIndex;
    ActionSheet.Callback = callback;
    ActionSheet.actionSheetStyle = Style;
    [ActionSheet showInView:showView];
    
    
}

-(id)       initWithTitle:(NSString*)title
                 callback:(void (^)(NSUInteger))callback
        cancelButtonIndex:(NSInteger)cancelButtonIndex 
   destructiveButtonIndex:(NSInteger)destructiveButtonIndex 
             ButtonTitles:(NSString *)ButtonTitle,...
{

    self = [super initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:ButtonTitle,nil];
    self.delegate = self;
    id current;
    va_list argumentList;
    va_start(argumentList, ButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [self addButtonWithTitle:current];
        current = va_arg(argumentList, id);
    }
    va_end(argumentList);
    self.cancelButtonIndex = cancelButtonIndex;
    self.destructiveButtonIndex = destructiveButtonIndex;

    self.Callback = callback;
    return self;
}



-(void)showInView:(UIView*)view
{
    [super showInView:view];
    
    [IPaActionSheet RetainActionSheet:self];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.Callback != nil) {

        self.Callback(buttonIndex);
    }
    [IPaActionSheet ReleaseActionSheet:self];
}
-(void)dealloc
{
    self.Callback = nil;
}
@end
