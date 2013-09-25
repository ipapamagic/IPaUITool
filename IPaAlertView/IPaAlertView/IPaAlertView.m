//
//  IPaAlertView.m
//  IPaAlertView
//
//  Created by IPaPa on 11/9/8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import "IPaAlertView.h"

@implementation IPaAlertView
static NSMutableArray *alertViewList;
+(void)RetainAlertView:(IPaAlertView*)alertView
{
    if (alertViewList == nil) {
        alertViewList = [@[] mutableCopy];
    }
    if ([alertViewList indexOfObject:alertView] == NSNotFound)
    {
        [alertViewList addObject:alertView];
    }
    
}
+(void)ReleaseAlertView:(IPaAlertView*)alertView
{
    [alertViewList removeObject:alertView];
}

+(id) IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle
{
    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    
    [newView show];
    return newView;
}


+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                  callback:(void (^)(NSInteger))callback
         cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message callback:callback
                                              cancelButtonTitles:cancelButtonTitle,nil];
    
    
 
    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [newView addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    

    [newView show];
    return newView;
    
}
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitle:(NSString*)cancelButtonTitle
{
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    self.Callback = nil;
    return self;
    
}
-(id) initWithTitle:(NSString*)title message:(NSString*)message
        cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    self = [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];

    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [self addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    
    return self;
}

-(id) initWithTitle:(NSString*)title message:(NSString*)message 
           callback:(void (^)(NSInteger))callback
  cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    self = [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];

    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [self addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    self.Callback = callback;

    return self;
}

-(void)show
{
    self.delegate = self;
    [super show];
//return self or arc may release this object
    [IPaAlertView RetainAlertView:self];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.Callback != nil) {
    
        self.Callback(buttonIndex);
        
    }
    self.delegate = nil;
    [IPaAlertView ReleaseAlertView:self];
    
}

@end
