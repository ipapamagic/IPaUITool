//
//  IPaPDFScannerSelection.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class IPaPDFScannerRenderState;
@interface IPaPDFScannerSelectionPartObj :NSObject
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) CGAffineTransform transform;
@end



@interface IPaPDFScannerSelection : NSObject


/* Initalize with rendering state (starting marker) */
- (id)initWithStartState:(IPaPDFScannerRenderState *)state;
//when we met new line,it need recompute, oldState is the state before new line
- (void)insertNewLineWithState:(IPaPDFScannerRenderState *)state withOldState:(IPaPDFScannerRenderState*)oState;
- (void)insertWithState:(IPaPDFScannerRenderState *)state;
/* Finalize the selection (ending marker) */
- (void)finalizeWithState:(IPaPDFScannerRenderState *)state;

/* The frame with zero origin covering the selection */
//@property (nonatomic, readonly) CGRect frame;

@property (nonatomic,readonly) NSArray *frameList;

/* The transformation needed to position the selection */
//@property (nonatomic, readonly) CGAffineTransform transform;

@end
