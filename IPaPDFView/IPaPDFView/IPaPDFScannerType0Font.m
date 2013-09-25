//
//  IPaPDFScannerType0Font.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerType0Font.h"
#import "IPaPDFScannerCIDType0Font.h"
#import "IPaPDFScannerCIDType2Font.h"
#import "IPaPDFScannerFontDescriptor.h"

@interface IPaPDFScannerType0Font ()
@property (nonatomic, readonly) NSMutableArray *descendantFonts;
@end

@implementation IPaPDFScannerType0Font
{
    NSMutableArray *descendantFonts;
}

/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super initWithFontDictionary:dict]))
	{
		CGPDFArrayRef dFonts;
		if (CGPDFDictionaryGetArray(dict, "DescendantFonts", &dFonts))
		{
			NSUInteger count = CGPDFArrayGetCount(dFonts);
			for (int i = 0; i < count; i++)
			{
				CGPDFDictionaryRef fontDict;
				if (!CGPDFArrayGetDictionary(dFonts, i, &fontDict)) 
                    continue;
				const char *subtype;
				if (!CGPDFDictionaryGetName(fontDict, "Subtype", &subtype)) 
                    continue;
                
//				NSLog(@"Descendant font type %s", subtype);
                
				if (strcmp(subtype, "CIDFontType0") == 0)
				{
					// Add descendant font of type 0
					IPaPDFScannerCIDType0Font *font = [[IPaPDFScannerCIDType0Font alloc] initWithFontDictionary:fontDict];
					if (font) 
                        [self.descendantFonts addObject:font];
				}
				else if (strcmp(subtype, "CIDFontType2") == 0)
				{
					// Add descendant font of type 2
					IPaPDFScannerCIDType2Font *font = [[IPaPDFScannerCIDType2Font alloc] initWithFontDictionary:fontDict];
					if (font)
                        [self.descendantFonts addObject:font];

				}
                
                
             /*   const char *BaseFont;
				if (!CGPDFDictionaryGetName(fontDict, "BaseFont", &BaseFont)) 
                    continue;
                NSLog(@"BaseFont...%s",BaseFont);
*/
			}
		}
	}
	return self;
}

/* Custom implementation, using descendant fonts */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize
{
	for (IPaPDFScannerFont *font in self.descendantFonts)
	{
		CGFloat width = [font widthOfCharacter:characher withFontSize:fontSize];
		if (width > 0) return width;
	}
	return 0;
}

- (NSDictionary *)ligatures
{
    IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
    return descendantFont.ligatures;
}

- (IPaPDFScannerFontDescriptor *)fontDescriptor {
	IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
	return descendantFont.fontDescriptor;
}

- (CGFloat)minY
{
	IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
	return [descendantFont.fontDescriptor descent];
}

/* Highest point of any character */
- (CGFloat)maxY
{
	IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
	return [descendantFont.fontDescriptor ascent];
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    NSMutableString *result;
	IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
    NSString *descendantResult = [descendantFont stringWithPDFString: pdfString];
    if (self.toUnicode) {
        unichar mapping;
        result = [[NSMutableString alloc] initWithCapacity: [descendantResult length]];
        for (int i = 0; i < [descendantResult length]; i++) {
            mapping = [self.toUnicode unicodeCharacter: [descendantResult characterAtIndex:i]];
            [result appendFormat: @"%C", mapping];
        }        
    } else {
        result = [NSMutableString stringWithString: descendantResult];
    }
    return result;
}

- (NSString *)cidWithPDFString:(CGPDFStringRef)pdfString {
    IPaPDFScannerFont *descendantFont = [self.descendantFonts lastObject];
    return [descendantFont stringWithPDFString: pdfString];
}


#pragma mark -
#pragma mark Memory Management

- (NSMutableArray *)descendantFonts
{
	if (!descendantFonts)
	{
		descendantFonts = [[NSMutableArray alloc] init];
	}
	return descendantFonts;
}
@end
