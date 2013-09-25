//
//  IPaPDFScannerSimpleFont.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerSimpleFont.h"

@implementation IPaPDFScannerSimpleFont
@synthesize encoding;

/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super initWithFontDictionary:dict]))
	{
		// Set encoding for any font
		[self setEncodingWithFontDictionary:dict];
	}
	return self;
}

/* Custom implementation for all simple fonts */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFArrayRef array;
	if (!CGPDFDictionaryGetArray(dict, "Widths", &array)) 
        return;
	size_t count = CGPDFArrayGetCount(array);
	CGPDFInteger firstChar, lastChar;
	if (!CGPDFDictionaryGetInteger(dict, "FirstChar", &firstChar))
        return;
	if (!CGPDFDictionaryGetInteger(dict, "LastChar", &lastChar))
        return;
	widthsRange = NSMakeRange(firstChar, lastChar-firstChar);
	NSMutableDictionary *widthsDict = [NSMutableDictionary dictionary];
	for (int i = 0; i < count; i++)
	{
		CGPDFReal width;
		if (!CGPDFArrayGetNumber(array, i, &width)) continue;
		NSNumber *key = [NSNumber numberWithInt:firstChar+i];
		NSNumber *value = [NSNumber numberWithFloat:width];
		[widthsDict setObject:value forKey:key];
	}
	self.widths = widthsDict;
}

/* Set encoding, given a font dictionary */
- (void)setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFObjectRef encodingObject;
	if (!CGPDFDictionaryGetObject(dict, "Encoding", &encodingObject)) return;
	[self setEncodingWithEncodingObject:encodingObject];
}

/* Custom implementation for all simple fonts */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	const unsigned char *bytes = CGPDFStringGetBytePtr(pdfString);
	NSInteger length = CGPDFStringGetLength(pdfString);
	NSData *rawBytes = [NSData dataWithBytes:bytes length:length];
	if (!self.encoding && self.toUnicode)
	{
		// Use ToUnicode map
		NSString *str = (__bridge_transfer NSString *) CGPDFStringCopyTextString(pdfString);
		NSMutableString *unicodeString = [NSMutableString string];
        
		// Translate to Unicode
		for (int i = 0; i < [str length]; i++)
		{
			unichar cid = [str characterAtIndex:i];
		 	[unicodeString appendFormat:@"%C", [self.toUnicode unicodeCharacter:cid]];
		}
		
		return unicodeString;
	}
	else if (!self.encoding)
	{
		return [[NSString alloc] initWithData:rawBytes encoding:NSMacOSRomanStringEncoding];
	}
	return [[NSString alloc] initWithData:rawBytes encoding:self.encoding];

}

/* Set encoding with name or dictionary */
- (void)setEncodingWithEncodingObject:(CGPDFObjectRef)object
{
	CGPDFObjectType type = CGPDFObjectGetType(object);
	
	/* Encoding dictionary with base encoding and differences */
	if (type == kCGPDFObjectTypeDictionary)
	{
		/*	NOTE: Also needs to capture differences */
		CGPDFDictionaryRef dict = nil;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
		CGPDFObjectRef baseEncoding = nil;
		if (!CGPDFDictionaryGetObject(dict, "BaseEncoding", &baseEncoding)) return;
		[self setEncodingWithEncodingObject:baseEncoding];
		return;
	}
	
	/* Only accept name objects */
	if (type != kCGPDFObjectTypeName) return;
	
	const char *name;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &name)) return;
	
	if (strcmp(name, "MacRomanEncoding") == 0)
	{
		self.encoding = NSMacOSRomanStringEncoding;
	}
	else if (strcmp(name, "MacExpertEncoding") == 0)
	{
		// What is MacExpertEncoding ??
		self.encoding = NSMacOSRomanStringEncoding;
	}
	else if (strcmp(name, "WinAnsiEncoding") == 0)
	{
		self.encoding = NSWindowsCP1252StringEncoding;
	}
}

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters
{
	return [NSString stringWithCString:characters encoding:encoding];
}
@end
