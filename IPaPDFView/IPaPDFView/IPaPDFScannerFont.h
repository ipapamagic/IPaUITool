//
//  IPaPDFScannerFont.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaPDFScannerFontDescriptor;
@interface IPaPDFScannerFontCMap : NSObject {
	NSMutableArray *offsets;
    NSMutableDictionary *chars;
}

/* Initialize with PDF stream containing a CMap */
- (id)initWithPDFStream:(CGPDFStreamRef)stream;

/* Unicode mapping for character ID */
- (unichar)unicodeCharacter:(unichar)cid;

@end


@interface IPaPDFScannerFont : NSObject
{
    NSRange widthsRange;
}
@property (nonatomic, strong) NSMutableDictionary *widths;
@property (nonatomic, readonly) NSDictionary *ligatures;
@property (nonatomic, readonly) CGFloat widthOfSpace;
@property (nonatomic, readonly) NSRange widthsRange;
@property (nonatomic,strong) IPaPDFScannerFontDescriptor *fontDescriptor;
@property (nonatomic,strong) IPaPDFScannerFontCMap *toUnicode;
@property (nonatomic, readonly) CGFloat minY;
@property (nonatomic, readonly) CGFloat maxY;
/* Factory method returns a Font object given a PDF font dictionary */
+ (IPaPDFScannerFont *)fontWithDictionary:(CGPDFDictionaryRef)dictionary;
/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Construct a font descriptor given font dictionary */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Given a PDF string, returns a Unicode string */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString;

/* Given a PDF string, returns a CID string */
- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString;

/* Returns the width of a charachter (optionally scaled to some font size) */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize;

/* Import a ToUnicode CMap from a font dictionary */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters;


@end
