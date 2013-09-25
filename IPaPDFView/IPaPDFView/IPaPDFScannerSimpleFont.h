//
//  IPaPDFScannerSimpleFont.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerFont.h"

@interface IPaPDFScannerSimpleFont : IPaPDFScannerFont
/* Custom implementation for all simple fonts */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Set encoding with name or dictionary */
- (void)setEncodingWithEncodingObject:(CGPDFObjectRef)object;

/* Set encoding, given a font dictionary */
- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict;
@property (nonatomic, assign) NSStringEncoding encoding;
@end
