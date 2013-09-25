//
//  IPaActionSheet.h
//  IPaActionSheet
//
//  Created by IPaPa on 11/10/25.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface IPaActionSheet : UIActionSheet <UIActionSheetDelegate> {
  
}


+(void) IPaActionSheetWithTitle:(NSString*)title 
                       callback:(void (^)(NSUInteger buttonIdx))callback
                          Style:(UIActionSheetStyle)Style
                       showView:(UIView*)showView
              cancelButtonIndex:(NSInteger)cancelButtonIndex 
         destructiveButtonIndex:(NSInteger)destructiveButtonIndex 
                   ButtonTitles:(NSString *)ButtonTitle,...NS_REQUIRES_NIL_TERMINATION;


-(id) initWithTitle:(NSString*)title
           callback:(void (^)(NSUInteger buttonIdx))callback
  cancelButtonIndex:(NSInteger)cancelButtonIndex 
destructiveButtonIndex:(NSInteger)destructiveButtonIndex 
       ButtonTitles:(NSString *)ButtonTitles,
...NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic,copy) void (^Callback)(NSUInteger buttonIdx);
@end
