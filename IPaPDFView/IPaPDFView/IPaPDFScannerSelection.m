//
//  IPaPDFScannerSelection.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerSelection.h"
#import "IPaPDFScannerRenderState.h"
#import "IPaPDFScannerFont.h"
#import "IPaPDFScannerFontDescriptor.h"
@interface IPaPDFScannerSelectionPartObj()
@property (nonatomic, copy) IPaPDFScannerRenderState *initialState;
@property (nonatomic, readwrite) CGRect frame;
@property (nonatomic, readwrite) CGAffineTransform transform;
@end
@implementation IPaPDFScannerSelectionPartObj
@synthesize frame, transform;
@synthesize initialState;
@end


@implementation IPaPDFScannerSelection
{
  //  IPaPDFScannerRenderState *initialState;

    IPaPDFScannerRenderState *usingState;
    NSMutableArray *_frameList;
    
}
//@synthesize frame, transform;

-(NSArray*)frameList
{
    return _frameList;
}
/* Rendering state represents opening (left) cap */
- (id)initWithStartState:(IPaPDFScannerRenderState *)state
{
	if ((self = [super init]))
	{
		//initialState = [state copy];
        
        _frameList = [NSMutableArray array];
        
        IPaPDFScannerSelectionPartObj *newObj = [[IPaPDFScannerSelectionPartObj alloc] init];

        newObj.initialState = state;
        usingState = newObj.initialState;        
        // Concatenate CTM onto text matrix
        newObj.transform = CGAffineTransformConcat([state textMatrix], [state ctm]);
        
        [_frameList addObject:newObj];
	}
	return self;
}

//insert new line
- (void)insertNewLineWithState:(IPaPDFScannerRenderState *)state withOldState:(IPaPDFScannerRenderState*)oState
{
    [self finalizeWithState:oState];
    
    IPaPDFScannerSelectionPartObj *newObj = [[IPaPDFScannerSelectionPartObj alloc] init];
    newObj.initialState = state;
    // Concatenate CTM onto text matrix
    newObj.transform = CGAffineTransformConcat([state textMatrix], [state ctm]);
    [_frameList addObject:newObj];
}
/* Render state represents new character*/
-(void)insertWithState:(IPaPDFScannerRenderState *)state
{
    IPaPDFScannerSelectionPartObj *partObj = [_frameList lastObject];

	// Use tallest cap for entire selection
	CGFloat startHeight = partObj.initialState.fontHeight;
	CGFloat finishHeight = state.fontHeight;
    usingState = (startHeight > finishHeight) ? usingState : state;
    
}


/* Rendering state represents closing (right) cap */
- (void)finalizeWithState:(IPaPDFScannerRenderState *)state
{
    IPaPDFScannerSelectionPartObj *partObj = [_frameList lastObject];
    

	// Width (difference between caps) with text transformation removed
	CGFloat width = [state textMatrix].tx - [partObj.initialState textMatrix].tx;	
   
	width /= [state textMatrix].a;
    
	// Use tallest cap for entire selection
    // Height is ascent plus (negative) descent
	CGFloat height = usingState.fontHeight;
    
	// Descent
	CGFloat descent = usingState.fontDescent;
    
	// Selection frame in text space
	partObj.frame = CGRectMake(0, descent, width, height);
	
    //	[initialState release]; initialState = nil;
}



@end
