//
//  IPaPDFScannerCIDType2Font.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScannerCompositeFont.h"

@interface IPaPDFScannerCIDType2Font : IPaPDFScannerCompositeFont
@property (nonatomic, assign, getter = isIdentity) BOOL identity;
@end
