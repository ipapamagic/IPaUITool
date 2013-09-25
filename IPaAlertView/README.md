IPaAlertView
============

Block-base AlertView for IOS

you can easily use class method

+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                    callback:(void (^)(NSInteger))callback
           cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;

to show a UIAlertView (if you use class method,you don't need to make [UIAlertView show],it will automatically to do that)

callback block has one parameter, it is button index on UIAlertView