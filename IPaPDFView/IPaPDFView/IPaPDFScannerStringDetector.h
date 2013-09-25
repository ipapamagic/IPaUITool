//
//  IPaPDFScannerStringDetector.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaPDFScannerStringDetector;
@class IPaPDFScannerFont;
@protocol IPaPDFScannerStringDetectorDelegate <NSObject>

@optional

/* Tells the delegate that the first character of the needle was detected */
- (void)detector:(IPaPDFScannerStringDetector *)detector didStartMatchingString:(NSString *)string;

/* Tells the delegate that the entire needle was detected */
- (void)detector:(IPaPDFScannerStringDetector *)detector foundString:(NSString *)needle;

/* Tells the delegate that one character was scanned */
- (void)detector:(IPaPDFScannerStringDetector *)detector didScanCharacter:(unichar)character;

@end


@interface IPaPDFScannerStringDetector : NSObject {




}

/* Initialize with a given needle */
- (id)initWithKeyword:(NSString *)needle;

/* Feed more charachers into the state machine */
- (NSString *)appendPDFString:(CGPDFStringRef)string withFont:(IPaPDFScannerFont *)font;

/* Reset the detector state */
- (void)reset;

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, weak) id<IPaPDFScannerStringDetectorDelegate> delegate;
@property (nonatomic,readonly) NSString *unicodeContent;
@end

