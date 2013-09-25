//
//  IPaPDFScannerRenderState.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//this class is used to record text reading pointer position in current pdf
#import <UIKit/UIKit.h>
#import "IPaPDFScannerFont.h"
@interface IPaPDFScannerRenderState : NSObject <NSCopying>
/* Matrixes (line-, text- and global) */
@property (nonatomic, assign) CGAffineTransform lineMatrix;
@property (nonatomic, assign) CGAffineTransform textMatrix;
@property (nonatomic, assign) CGAffineTransform ctm;

/* Text size, spacing, scaling etc. */
@property (nonatomic, assign) CGFloat characterSpacing;
@property (nonatomic, assign) CGFloat wordSpacing;
@property (nonatomic, assign) CGFloat leadning;
@property (nonatomic, assign) CGFloat textRise;
@property (nonatomic, assign) CGFloat horizontalScaling;

/* Font and font size */
@property (nonatomic, strong) IPaPDFScannerFont *font;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, readonly) CGFloat widthOfSpace;
@property (nonatomic, readonly) CGFloat fontHeight;
@property (nonatomic, readonly) CGFloat fontDescent;
/* Set the text matrix and (optionally) the line matrix */
- (void)setTextMatrix:(CGAffineTransform)matrix replaceLineMatrix:(BOOL)replace;

/* Converts a float to user space */
- (CGFloat)convertToUserSpace:(CGFloat)value;

/* Transform the text matrix */
- (void)translateTextPosition:(CGSize)size;

/* Move to start of next line, optionally with custom line height and indent, and optionally save line height */
- (void)newLineWithLeading:(CGFloat)aLeading indent:(CGFloat)indent save:(BOOL)save;
- (void)newLineWithLeading:(CGFloat)lineHeight save:(BOOL)save;
- (void)newLine;

+(IPaPDFScannerRenderState*)currentRenderingState;
+(void)pushRenderingState;
+(IPaPDFScannerRenderState *)popRenderingState;
+(IPaPDFScannerFont*)currentFont;
@end
