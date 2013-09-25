//
//  IPaPDFScannerFont.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerFont.h"
#import "IPaPDFScannerFontDescriptor.h"
// Simple fonts
#import "IPaPDFScannerType1Font.h"
#import "IPaPDFScannerTrueTypeFont.h"
#import "IPaPDFScannerMMType1Font.h"
#import "IPaPDFScannerType3Font.h"

// Composite fonts
#import "IPaPDFScannerType0Font.h"
#import "IPaPDFScannerCIDType2Font.h"
#import "IPaPDFScannerCIDType0Font.h"

#pragma mark IPaPDFScannerFontCMap


@implementation IPaPDFScannerFontCMap

- (void)scanCodeSpaceRange:(NSScanner *)scanner
{
	static NSString *endToken = @"endcodespacerange";
	NSString *content = nil;
	[scanner scanUpToString:endToken intoString:&content];
	[scanner scanString:endToken intoString:nil];
//	NSLog(@"%@", content);
}

- (void)scanRanges:(NSScanner *)scanner
{
	NSString *content = nil;
	static NSString *endToken = @"endbfrange";
	[scanner scanUpToString:endToken intoString:&content];
	NSCharacterSet *alphaNumericalSet = [NSCharacterSet alphanumericCharacterSet];
	

	NSScanner *rangeScanner = [NSScanner scannerWithString:content];
	while (![rangeScanner isAtEnd])
	{
		unsigned int start, end, offset;
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&start];
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&end];
		[rangeScanner scanUpToCharactersFromSet:alphaNumericalSet intoString:nil];
		[rangeScanner scanHexInt:&offset];
        //		NSLog(@"%d,%d offset %d", start, end, offset);

        
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:start], @"First",
							  [NSNumber numberWithInt:end], @"Last",
							  [NSNumber numberWithInt:offset], @"Offset", 
							  nil];
		[offsets addObject:dict];
        
	}

	[scanner scanString:endToken intoString:nil];
}

- (void)scanChars:(NSScanner *)scanner 
{
	NSString *content = nil;
	static NSString *endToken = @"endbfchar";
	[scanner scanUpToString:endToken intoString:&content];
    NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
    NSCharacterSet *tagSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *separatorString = @"> <";
    

    NSScanner *rangeScanner = [NSScanner scannerWithString:content];
    while (![rangeScanner isAtEnd])
    {
        NSString *line = nil;
        [rangeScanner scanUpToCharactersFromSet:newLineSet intoString:&line];
        line = [line stringByTrimmingCharactersInSet:tagSet];
        NSArray *parts = [line componentsSeparatedByString:separatorString];
        
        NSUInteger from, to;
        NSScanner *scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
        [scanner scanHexInt:&from];
        
        scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
        [scanner scanHexInt:&to];
        
        NSNumber *fromNumber = [NSNumber numberWithInt:from];
        NSNumber *toNumber = [NSNumber numberWithInt:to];
        [chars setObject:toNumber  forKey:fromNumber];
    }

}

- (void)scanCMap:(NSScanner *)scanner
{
	while (![scanner isAtEnd])
	{
		NSString *line;
		[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
		if ([line rangeOfString:@"begincodespacerange"].location != NSNotFound)
		{
            //有可能在一開始就掃到結束字了，就不用在掃了
            if ([line rangeOfString:@"endcodespacerange"].location == NSNotFound)
                [self scanCodeSpaceRange:scanner];
		}
		else if ([line rangeOfString:@"beginbfrange"].location != NSNotFound)
		{
            [self scanRanges:scanner];
		}
        else if ([line rangeOfString:@"beginbfchar"].location != NSNotFound) 
        {
            [self scanChars:scanner];
        }
	}
}

- (void)scanning:(NSString *)text
{
//    NSLog(@"====================");
//    NSLog(@"%@",text);
//    NSLog(@"====================");
	NSScanner *scanner = [NSScanner scannerWithString:text];
	[scanner scanUpToString:@"begincmap" intoString:nil];
	[scanner scanString:@"begincmap" intoString:nil];
	//NSLog(@"%d", scanner.scanLocation);
    chars = [NSMutableDictionary dictionary];
    offsets = [NSMutableArray array];
	[self scanCMap:scanner];
}

- (id)initWithPDFStream:(CGPDFStreamRef)stream
{
	if ((self = [super init]))
	{
		NSData *data = (__bridge_transfer NSData *) CGPDFStreamCopyData(stream, nil);
		NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		offsets = nil;
        chars = nil;
		
		[self scanning:text];
		return self;
	}
	return self;
}

- (NSDictionary *)rangeWithCharacter:(unichar)character
{

    for (NSDictionary *dict in offsets)
    {
        if ([[dict objectForKey:@"First"] intValue] <= character && [[dict objectForKey:@"Last"] intValue] >= character)
        {
            return dict;
        }
    }

	return nil;
}

- (unichar)unicodeCharacter:(unichar)cid
{
	NSDictionary *dict = [self rangeWithCharacter:cid];
    if (dict)
    {
        NSUInteger internalOffset = cid - [[dict objectForKey:@"First"] intValue];
        return [[dict objectForKey:@"Offset"] intValue] + internalOffset;
    }



    NSNumber *fromChar = [NSNumber numberWithInt: cid];
    NSNumber *toChar = [chars objectForKey: fromChar];
    if (toChar != nil) {
        return [toChar intValue];
    }

    return cid;
}

@end



#pragma mark IPaPDFScannerFont
@interface IPaPDFScannerFont ()


@end
@implementation IPaPDFScannerFont
@synthesize widths;
@synthesize fontDescriptor;
@synthesize toUnicode;
@synthesize ligatures;
@synthesize widthsRange;
/* Factory method returns a Font object given a PDF font dictionary */
+ (IPaPDFScannerFont *)fontWithDictionary:(CGPDFDictionaryRef)dictionary
{
	const char *type = nil;
	CGPDFDictionaryGetName(dictionary, "Type", &type);
	if (!type || strcmp(type, "Font") != 0) 
        return nil;
    const char *encoding = nil; 
    CGPDFDictionaryGetName(dictionary, "Encoding", &encoding);
    
    
	const char *subtype = nil;
	CGPDFDictionaryGetName(dictionary, "Subtype", &subtype);
    
    NSString *subTypeString = [NSString stringWithUTF8String:subtype];
    Class FontClassObj = NSClassFromString([NSString stringWithFormat:@"IPaPDFScanner%@Font",subTypeString]);
    if (FontClassObj) {
        NSLog(@"encoding method...%@,..%s",subTypeString,encoding);
        return [[FontClassObj alloc] initWithFontDictionary:dictionary];
    }
	
	return nil;
}


/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		// Populate the glyph widths store
		[self setWidthsWithFontDictionary:dict];
		
		// Initialize the font descriptor
		[self setFontDescriptorWithFontDictionary:dict];
		
		// Parse ToUnicode map
		[self setToUnicodeWithFontDictionary:dict];
		
		// NOTE: Any furhter initialization is performed by the appropriate subclass
	}
	return self;
}

#pragma mark Font Resources

/* Import font descriptor */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFDictionaryRef descriptor;
	if (!CGPDFDictionaryGetDictionary(dict, "FontDescriptor", &descriptor))
        return;
	self.fontDescriptor = [[IPaPDFScannerFontDescriptor alloc] initWithPDFDictionary:descriptor];

}

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	// Custom implementation in subclasses
}

/* Parse the ToUnicode map */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFStreamRef stream;
	if (!CGPDFDictionaryGetStream(dict, "ToUnicode", &stream))
        return;
	self.toUnicode = [[IPaPDFScannerFontCMap alloc] initWithPDFStream:stream];

}

#pragma mark Font Property Accessors

/* Subclasses will override this method with their own implementation */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    // Copy PDFString to NSString
    NSString *string = (__bridge_transfer NSString *) CGPDFStringCopyTextString(pdfString);
	return string;
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    // Copy PDFString to NSString
    NSString *string = (__bridge_transfer NSString *) CGPDFStringCopyTextString(pdfString);
	return string;
}

/* Lowest point of any character */
- (CGFloat)minY
{
	return [self.fontDescriptor descent];
}

/* Highest point of any character */
- (CGFloat)maxY
{
	return [self.fontDescriptor ascent];
}

/* Width of the given character (CID) scaled to fontsize */
- (CGFloat)widthOfCharacter:(unichar)character withFontSize:(CGFloat)fontSize
{
	NSNumber *key = [NSNumber numberWithInt:character];
	NSNumber *width = [self.widths objectForKey:key];
	return [width floatValue] * fontSize;
}

/* Ligatures available in the current font encoding */
- (NSDictionary *)ligatures
{
	if (!ligatures)
	{
		// Mapping ligature Unicode character values to strings
		ligatures = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"ff", [NSString stringWithFormat:@"%C", (unsigned short)0xfb00],
					 @"fi", [NSString stringWithFormat:@"%C", (unsigned short)0xfb01],
					 @"fl", [NSString stringWithFormat:@"%C", (unsigned short)0xfb02],
					 @"ae", [NSString stringWithFormat:@"%C", (unsigned short)0x00e6],
					 @"oe", [NSString stringWithFormat:@"%C", (unsigned short)0x0153],
					 nil];
	}
	return ligatures;
}

/* Width of space chacacter in glyph space */
- (CGFloat)widthOfSpace
{
	return [self widthOfCharacter:0x20 withFontSize:1.0];
}

/* Description is the class name of the object */
- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@>", [self.class description]];
}

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters
{
	return 0;
}


@end
