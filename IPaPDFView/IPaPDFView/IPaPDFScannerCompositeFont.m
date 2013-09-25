//
//  IPaPDFScannerCompositeFont.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerCompositeFont.h"

@implementation IPaPDFScannerCompositeFont
@synthesize defaultWidth;


/* Override with implementation for composite fonts */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
    self.defaultWidth = 1000;
	CGPDFArrayRef ws;
	if (!CGPDFDictionaryGetArray(dict, "W", &ws)) return;
    
	CGPDFInteger dw;
	if (CGPDFDictionaryGetInteger(dict, "DW", &dw))
	{
		self.defaultWidth = dw;
	}
    
	NSUInteger count = CGPDFArrayGetCount(ws);
    
	CGPDFObjectRef nextObject = nil;
	CGPDFInteger firstCharacter = 0;
	NSMutableDictionary *widthsDict = [NSMutableDictionary dictionary];
	for (int i = 0; i < count; )
	{
		// Read two first items from sequence
		if (!CGPDFArrayGetInteger(ws, i++, &firstCharacter)) break;
		if (!CGPDFArrayGetObject(ws, i++, &nextObject)) break;
        
		CGPDFObjectType type = CGPDFObjectGetType(nextObject);
        
		if (type == kCGPDFObjectTypeInteger)
		{
			// If the second item is another integer, the sequence
			// defines a range on the form [ first last width ]
			CGPDFInteger lastCharacter;
			CGPDFInteger characterWidth;
			CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeInteger, &lastCharacter);
			CGPDFArrayGetInteger(ws, i++, &characterWidth);
			
			for (int index = firstCharacter; index <= lastCharacter; index++)
			{
				NSNumber *key = [NSNumber numberWithInt:index];
				NSNumber *val = [NSNumber numberWithInt:characterWidth];
				[widthsDict setObject:val forKey:key];
			}
		}
		else if (type == kCGPDFObjectTypeArray)
		{
			// If the second item is an array, the sequence
			// defines widths on the form [ first list-of-widths ]
			CGPDFArrayRef characterWidths;
			if (!CGPDFObjectGetValue(nextObject, kCGPDFObjectTypeArray, &characterWidths)) break;
			NSUInteger count = CGPDFArrayGetCount(characterWidths);
			for (int index = 0; index < count ; index++)
			{
				CGPDFInteger width;
				if (CGPDFArrayGetInteger(characterWidths, index, &width))
				{
					NSNumber *key = [NSNumber numberWithInt:firstCharacter+index];
					NSNumber *val = [NSNumber numberWithInt:width];
					[widthsDict setObject:val forKey:key];
				}
			}
		}
		else
		{
			break;
		}
	}
	self.widths = widthsDict;
}

/* Custom implementation */
- (CGFloat)widthOfCharacter:(unichar)characher withFontSize:(CGFloat)fontSize
{
    //	CGFloat width = [super widthOfCharacter:characher withFontSize:fontSize];
	
	NSNumber *width = [self.widths objectForKey:[NSNumber numberWithInt:characher]];
	
	if (!width)
	{
		return self.defaultWidth * fontSize;
	}
	return [width floatValue] * fontSize;
}

@end
