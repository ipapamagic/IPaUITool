//
//  IPaPDFScannerFontDescriptor.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Flags as defined in PDF 1.7 */
typedef enum FontFlags
{
	FontFixedPitch		= 1 << 0,
	FontSerif			= 1 << 1,
	FontSymbolic		= 1 << 2,
	FontScript			= 1 << 3,
	FontNonSymbolic		= 1 << 5,
	FontItalic			= 1 << 6,
	FontAllCap			= 1 << 16,
	FontSmallCap		= 1 << 17,
	FontForceBold		= 1 << 18,
} FontFlags;


@interface IPaPDFScannerFontDescriptor : NSObject

@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, assign) CGFloat descent;
@property (nonatomic, assign) CGFloat leading;
@property (nonatomic, assign) CGFloat capHeight;
@property (nonatomic, assign) CGFloat xHeight;
@property (nonatomic, assign) CGFloat averageWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat missingWidth;
@property (nonatomic, assign) CGFloat verticalStemWidth;
@property (nonatomic, assign) CGFloat horizontalStemWidth;
@property (nonatomic, assign) CGFloat italicAngle;
@property (nonatomic, assign) NSUInteger flags;
@property (nonatomic, readonly, getter = isSymbolic) BOOL symbolic;
@property (nonatomic, copy) NSString *fontName;

/* Initialize a descriptor using a FontDescriptor dictionary */
- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict;

@end
