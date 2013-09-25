//
//  IPaPDFScannerCIDType0Font.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerCIDType0Font.h"

@implementation IPaPDFScannerCIDType0Font
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
	size_t length = CGPDFStringGetLength(pdfString);
	const unsigned char *cid = CGPDFStringGetBytePtr(pdfString);
    NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < length; i+=2) {
		char unicodeValue = cid[i+1];
        [result appendFormat:@"%C",(unsigned short) unicodeValue];
	}
    return result;
}
@end
