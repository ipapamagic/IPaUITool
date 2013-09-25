//
//  IPaPDFScannerRenderState.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerRenderState.h"
#import "IPaPDFScannerFontDescriptor.h"
NSMutableArray *RenderStateStack;
@interface IPaPDFScannerRenderState ()
+(NSMutableArray*)RenderStateStack;
@end
@implementation IPaPDFScannerRenderState
{
}
@synthesize characterSpacing;
@synthesize wordSpacing;
@synthesize leadning;
@synthesize textRise;
@synthesize horizontalScaling;
@synthesize font;
@synthesize fontSize;
@synthesize lineMatrix;
@synthesize textMatrix;
@synthesize ctm;
+(NSMutableArray*)RenderStateStack
{
    if(RenderStateStack == nil)
    {
        RenderStateStack = [[NSMutableArray alloc] init];
        
        [RenderStateStack addObject:[[IPaPDFScannerRenderState alloc] init]];
    }
    return RenderStateStack;
}
+(IPaPDFScannerRenderState*)currentRenderingState
{
    return [[IPaPDFScannerRenderState RenderStateStack] lastObject];
}

/* Push a rendering state to the stack */
+(void)pushRenderingState
{
    NSMutableArray *stack = [IPaPDFScannerRenderState RenderStateStack];
    IPaPDFScannerRenderState *newState = [[stack lastObject] copy];
    [stack addObject:newState];
}

/* Pops the top rendering state off the stack */
+(IPaPDFScannerRenderState *)popRenderingState
{
    NSMutableArray *stack = [IPaPDFScannerRenderState RenderStateStack];
    
    if (stack.count == 1) {
        
        //can not pop last one
        return nil;
    }
    
	IPaPDFScannerRenderState *state = [stack lastObject];
    if (state) {
        [stack removeLastObject];

    }
	return state;
}
+(IPaPDFScannerFont*)currentFont
{
    return [IPaPDFScannerRenderState currentRenderingState].font;
}
- (id)init
{
    if ((self = [super init]))
	{
		// Default values
		self.textMatrix = CGAffineTransformIdentity;
		self.lineMatrix = CGAffineTransformIdentity;
        self.ctm = CGAffineTransformIdentity;
		self.horizontalScaling = 1.0;
    }
    return self;
}
- (CGFloat)fontHeight
{
  
	// Height is ascent plus (negative) descent
	return [self convertToUserSpace:(self.font.maxY - self.font.minY)];
    
}
-(CGFloat)fontDescent
{
  
	IPaPDFScannerFontDescriptor *descriptor = [self.font fontDescriptor];


	return [self convertToUserSpace:descriptor.descent];
}
- (id)copyWithZone:(NSZone *)zone
{
	IPaPDFScannerRenderState *copy = [[IPaPDFScannerRenderState alloc] init];
	copy.lineMatrix = self.lineMatrix;
	copy.textMatrix = self.textMatrix;
	copy.leadning = self.leadning;
	copy.wordSpacing = self.wordSpacing;
	copy.characterSpacing = self.characterSpacing;
	copy.horizontalScaling = self.horizontalScaling;
	copy.textRise = self.textRise;
	copy.font = self.font;
	copy.fontSize = self.fontSize;
	copy.ctm = self.ctm;
	return copy;
}
/* Convert value to user space */
- (CGFloat)convertToUserSpace:(CGFloat)value
{
	CGFloat scaleFactor = self.fontSize / 1000;
	return value * scaleFactor;
}
/* Set the text matrix, and optionally the line matrix */
- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace
{
	self.textMatrix = matrix;
	if (replace)
	{
		self.lineMatrix = matrix;
	}
}


/* Moves the text cursor forward */
- (void)translateTextPosition:(CGSize)size
{
	self.textMatrix = CGAffineTransformTranslate(self.textMatrix, size.width, size.height);
}
/* Move to start of next line, with custom line height and relative indent */
- (void)newLineWithLeading:(CGFloat)aLeading indent:(CGFloat)indent save:(BOOL)save
{
	CGAffineTransform t = CGAffineTransformTranslate(self.lineMatrix, indent, -aLeading);
	[self setTextMatrix:t replaceLineMatrix:YES];
	if (save)
	{
		self.leadning = aLeading;
	}
}

/* Transforms the rendering state to the start of the next line, with custom line height */
- (void)newLineWithLeading:(CGFloat)lineHeight save:(BOOL)save
{
	[self newLineWithLeading:lineHeight indent:0 save:save];
}

/* Transforms the rendering state to the start of the next line */
- (void)newLine
{
	[self newLineWithLeading:self.leadning save:NO];
}
-(CGFloat)widthOfSpace
{
    return font.widthOfSpace;
}
@end
