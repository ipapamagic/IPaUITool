//
//  IPaPDFScannerFontCollection.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerFontCollection.h"
#import "IPaPDFScannerFont.h"
@implementation IPaPDFScannerFontCollection
{
	NSMutableDictionary *fonts;
	NSArray *names;
}
@synthesize names;



/* Applier function for font dictionaries */
void didScanFont(const char *key, CGPDFObjectRef object, void *collection)
{
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) 
        return;
	CGPDFDictionaryRef dict;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) 
        return;
	IPaPDFScannerFont *font = [IPaPDFScannerFont fontWithDictionary:dict];
	if (!font) 
        return;
	NSString *name = [NSString stringWithUTF8String:key];
	[(__bridge NSMutableDictionary *)collection setObject:font forKey:name];
//	NSLog(@" %s: %@", key, font);
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		//NSLog(@"Font Collection (%zu)", CGPDFDictionaryGetCount(dict));
		fonts = [[NSMutableDictionary alloc] init];
		// Enumerate the Font resource dictionary
		CGPDFDictionaryApplyFunction(dict, didScanFont, (__bridge void*)fonts);
        
		NSMutableArray *namesArray = [NSMutableArray array];
		for (NSString *name in [fonts allKeys])
		{
			[namesArray addObject:name];
		}
        
		names = [namesArray sortedArrayUsingSelector:@selector(compare:)];
	}
	return self;
}

/* Returns a copy of the font dictionary */
- (NSDictionary *)fontsByName
{
	return [NSDictionary dictionaryWithDictionary:fonts];
}

/* Return the specified font */
- (IPaPDFScannerFont *)fontNamed:(NSString *)fontName
{
	return [fonts objectForKey:fontName];
}

@end
