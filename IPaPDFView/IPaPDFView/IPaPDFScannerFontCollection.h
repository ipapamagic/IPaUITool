//
//  IPaPDFScannerFontCollection.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaPDFScannerFont;
@interface IPaPDFScannerFontCollection : NSObject

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Return the specified font */
- (IPaPDFScannerFont *)fontNamed:(NSString *)fontName;

@property (nonatomic, readonly) NSDictionary *fontsByName;

@property (nonatomic, readonly) NSArray *names;

@end


