//
//  IPaPDFScannerCIDType2Font.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerCIDType2Font.h"
#import <zlib.h>
@implementation IPaPDFScannerCIDType2Font

@synthesize identity;
- (void)setCIDToGIDMapWithDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFObjectRef object = nil;
	if (!CGPDFDictionaryGetObject(dict, "CIDToGIDMap", &object)) 
        return;
	CGPDFObjectType type = CGPDFObjectGetType(object);
	if (type == kCGPDFObjectTypeName)
	{
		const char *mapName;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &mapName))
            return;
		self.identity = YES;
	}
	else if (type == kCGPDFObjectTypeStream)
	{
		CGPDFStreamRef stream = nil;
		if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeStream, &stream)) 
            return;
		NSData *data = (__bridge_transfer NSData *) CGPDFStreamCopyData(stream, nil);
		NSLog(@"CIDType2Font: no implementation for CID mapping with stream (%d bytes)", [data length]);

	}
}


- (void)setCIDSystemInfoWithDictionary:(CGPDFDictionaryRef)dict
{
	CGPDFDictionaryRef cidSystemInfo;
	if (!CGPDFDictionaryGetDictionary(dict, "CIDSystemInfo", &cidSystemInfo)) 
        return;
    
	CGPDFStringRef registry;
	if (!CGPDFDictionaryGetString(cidSystemInfo, "Registry", &registry)) 
        return;
    
    
	CGPDFStringRef ordering;
	if (!CGPDFDictionaryGetString(cidSystemInfo, "Ordering", &ordering)) 
        return;
	
	CGPDFInteger supplement;
	if (!CGPDFDictionaryGetInteger(cidSystemInfo, "Supplement", &supplement))
        return;
	
	NSString *registryString = (__bridge_transfer NSString *) CGPDFStringCopyTextString(registry);
	NSString *orderingString = (__bridge_transfer NSString *) CGPDFStringCopyTextString(ordering);
	
	NSString *cidSystemString = [NSString stringWithFormat:@"%@ (%@) %d", registryString, orderingString, (int)supplement];
	NSLog(@"%@", cidSystemString);
	

}

- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
//	NSLog(@"CID FONT TYPE 2");
	if ((self = [super initWithFontDictionary:dict]))
	{
		[self setCIDToGIDMapWithDictionary:dict];
		[self setCIDSystemInfoWithDictionary:dict];
	}
	return self;
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	if (self.identity)
	{

		// Use 2-byte CIDToGID identity mapping
		size_t length = CGPDFStringGetLength(pdfString);
            
        NSMutableString *string = [NSMutableString stringWithCapacity:length];
        const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);

        
      //  NSString *nspdfString = (__bridge_transfer NSString*)CGPDFStringCopyTextString(pdfString);
        
        
        
       //  NSString *uri = [NSString stringWithCString:cid encoding:NSUTF8StringEncoding];
//		NSString *cstring = [[NSString alloc] initWithUTF8String:(const char*)cid];
//		NSData *data = [NSData dataWithBytes:cid length:length];
//		NSLog(@"Type2Font stringWithPDFString:%@", data);
       
        
        //這邊將資料用zlib"解壓縮"

        
        
		for (int i = 0; i < length; i+=2)
		{
            unichar unicodeValue = (cid[i] << 8 )| cid[i+1];    
            [string appendFormat:@"%C", unicodeValue];
            
            
		}
        
        return string;
		
	}
	else
	{
		
	}
	
	
	return @"";
}

@end
