//
//  IPaPDFScanner.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPaPDFScannerStringDetector.h"
#import "IPaPDFScannerSelection.h"
#import "IPaPDFOutlineData.h"
@interface IPaPDFScanner : NSObject <IPaPDFScannerStringDetectorDelegate>


+(IPaPDFScanner*)defaultScanner;
//return outline data in Document
+(NSArray *)scanDocumentOutline:(CGPDFDocumentRef)document;

//return IPaPDFScannerSelection的array
+ (NSArray *)scanPage:(CGPDFPageRef)page withKeyword:(NSString*)keyword;
//return array of arry ，the first level of array represent search result of every page ，the second level of array is array of IPaPDFScannerSelection
+ (NSArray *)scanDocument:(CGPDFDocumentRef)document withKeyword:(NSString*)keyword;

//return array of IPaPDFScannerSelection
+ (NSArray *)scanDocument:(CGPDFDocumentRef)document withPageNum:(NSUInteger)pageNum withKeyword:(NSString*)keyword;
@end
