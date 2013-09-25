//
//  IPaAlertView.h
//
//  Created by IPaPa on 11/9/8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
@interface IPaAlertView : UIAlertView <UIAlertViewDelegate>{
                                
}

-(id) initWithTitle:(NSString*)title message:(NSString*)message 
           callback:(void (^)(NSInteger))callback
  cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitles:(NSString*)cancelButtonTitles ,...NS_REQUIRES_NIL_TERMINATION;
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitle:(NSString*)cancelButtonTitle;
-(void)show;
+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle;

+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                    callback:(void (^)(NSInteger))callback
           cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic,copy) void (^Callback)(NSInteger);
@end
