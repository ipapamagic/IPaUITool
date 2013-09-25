//
//  IPaSinglePDFView.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/6.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaSinglePDFView : UIView
@property(nonatomic,readwrite) CGPDFPageRef pdfPage;
@property(nonatomic,readwrite) BOOL isEnableLink;
//array of IPaPDFScannerSelection
@property (nonatomic,strong) NSArray *selectionArray;
@end
