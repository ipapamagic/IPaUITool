//
//  IPaPDFScannerFontDescriptor.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerFontDescriptor.h"

@implementation IPaPDFScannerFontDescriptor

@synthesize ascent;
@synthesize descent;
@synthesize bounds;
@synthesize leading;
@synthesize capHeight;
@synthesize averageWidth;
@synthesize maxWidth;
@synthesize missingWidth;
@synthesize xHeight;
@synthesize flags;
@synthesize verticalStemWidth;
@synthesize horizontalStemWidth;
@synthesize italicAngle;
@synthesize fontName;
/*void copyDictionaryValues (const char *key, CGPDFObjectRef object, void *info) {
    NSLog(@"key: %s", key);
    
    CGPDFObjectType type = CGPDFObjectGetType(object);
    switch (type) {
        case kCGPDFObjectTypeString: {
            NSLog(@"string!!");
        }
            break;
        case kCGPDFObjectTypeInteger: {
            NSLog(@"integer");
        }
            break;            
        case kCGPDFObjectTypeBoolean: {
            NSLog(@"bool");
        }
            break;            
        case kCGPDFObjectTypeArray : {
            NSLog(@"set array value");
        }
            break;
        case kCGPDFObjectTypeName :{
            NSLog(@"Name");    
            
            
        }
            break;        
            
    }
}*/
- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict
{
	const char *type = nil;
	CGPDFDictionaryGetName(dict, "Type", &type);
	if (!type || strcmp(type, "FontDescriptor") != 0)
	{
		return nil;
	}
    
	if ((self = [super init]))
	{
		CGPDFInteger ascentValue = 0L;
		CGPDFInteger descentValue = 0L;
		CGPDFInteger leadingValue = 0L;
		CGPDFInteger capHeightValue = 0L;
		CGPDFInteger xHeightValue = 0L;
		CGPDFInteger averageWidthValue = 0L;
		CGPDFInteger maxWidthValue = 0L;
		CGPDFInteger missingWidthValue = 0L;
		CGPDFInteger flagsValue = 0L;
		CGPDFInteger stemV = 0L;
		CGPDFInteger stemH = 0L;
		CGPDFInteger italicAngleValue = 0L;
		const char *fontNameString = nil;
		CGPDFArrayRef bboxValue = nil;
        
		CGPDFDictionaryGetInteger(dict, "Ascent", &ascentValue);
        CGPDFDictionaryGetInteger(dict, "Descent", &descentValue);
        CGPDFDictionaryGetInteger(dict, "Leading", &leadingValue);
		CGPDFDictionaryGetInteger(dict, "CapHeight", &capHeightValue);
		CGPDFDictionaryGetInteger(dict, "XHeight", &xHeightValue);
		CGPDFDictionaryGetInteger(dict, "AvgWidth", &averageWidthValue);
		CGPDFDictionaryGetInteger(dict, "MaxWidth", &maxWidthValue);
		CGPDFDictionaryGetInteger(dict, "MissingWidth", &missingWidthValue);
		CGPDFDictionaryGetInteger(dict, "Flags", &flagsValue);
		CGPDFDictionaryGetInteger(dict, "StemV", &stemV);
        CGPDFDictionaryGetInteger(dict, "StemH", &stemH);
        CGPDFDictionaryGetInteger(dict, "ItalicAngle", &italicAngleValue);
        CGPDFDictionaryGetName(dict, "FontName", &fontNameString);
		CGPDFDictionaryGetArray(dict, "FontBBox", &bboxValue);
        
        self.ascent = ascentValue;
        self.descent = descentValue;
        self.leading = leadingValue;
		self.capHeight = capHeightValue;
		self.xHeight = xHeightValue;
		self.averageWidth = averageWidthValue;
		self.maxWidth = maxWidthValue;
        self.missingWidth = missingWidthValue;
        self.flags = flagsValue;
        self.verticalStemWidth = stemV;
        self.horizontalStemWidth = stemH;
        self.italicAngle = italicAngleValue;
        self.fontName = [NSString stringWithUTF8String:fontNameString];
        
		if (CGPDFArrayGetCount(bboxValue) == 4)
		{
			CGPDFInteger x = 0, y = 0, width = 0, height = 0;
			CGPDFArrayGetInteger(bboxValue, 0, &x);
			CGPDFArrayGetInteger(bboxValue, 1, &y);
			CGPDFArrayGetInteger(bboxValue, 2, &width);
			CGPDFArrayGetInteger(bboxValue, 3, &height);
			self.bounds = CGRectMake(x, y, width, height);
		}
    /*    CGPDFStreamRef fontFileStream = nil;
        if (CGPDFDictionaryGetStream(dict, "FontFile", &fontFileStream))
        {
            NSLog(@"FontFile exist!");
        }
        if (CGPDFDictionaryGetStream(dict, "FontFile2", &fontFileStream))
        {
            NSLog(@"FontFile2 exist!");
            CGPDFDictionaryRef fontFileDict;
            fontFileDict = CGPDFStreamGetDictionary(fontFileStream);
            const char *name;
            CGPDFDictionaryGetName(fontFileDict, "Filter", &name);
            NSLog(@"%s",name);
           // CGPDFDictionaryApplyFunction(fontFileDict, copyDictionaryValues, NULL);
            

            
        }
        if (CGPDFDictionaryGetStream(dict, "FontFile3", &fontFileStream))
        {
            NSLog(@"FontFile3 exist!");
        }*/
	}
	return self;
}

/* True if a font is symbolic */
- (BOOL)isSymbolic
{
	return ((self.flags & FontSymbolic) > 0) && ((self.flags & FontNonSymbolic) == 0);
}




@end