//
//  IPaSinglePDFView.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/6.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaSinglePDFView.h"
#import <QuartzCore/QuartzCore.h>
#import "IPaPDFScannerSelection.h"
@interface FastCATiledLayer : CATiledLayer
@end

@implementation FastCATiledLayer
+(CFTimeInterval)fadeDuration {
    return 0.0;
}
@end
@interface IPaSinglePDFView ()
- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint;
- (void) switchLinkButton:(BOOL)isOn;
-(void)removeAllLinkButton;
@end
@implementation IPaSinglePDFView
{
    NSArray *LinkButtons;
}
@synthesize isEnableLink = _isEnableLink;
@synthesize pdfPage = _pdfPage;
@synthesize selectionArray = _selectionArray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        FastCATiledLayer *animLayer = (FastCATiledLayer *) self.layer;
		animLayer.levelsOfDetailBias = 3;
		animLayer.levelsOfDetail = 5;
        animLayer.tileSize = CGSizeMake(1024, 1024);
        self.opaque = YES;
        self.isEnableLink = NO;
    }
    return self;
}
+(Class)layerClass
{
	return [FastCATiledLayer class];
}
-(void)setPdfPage:(CGPDFPageRef)pdfPage
{
    
    _pdfPage = pdfPage;
    
    
    [self switchLinkButton:_isEnableLink];
    [self setNeedsDisplay];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    /* 
     EDIT: After some additional experimentation, 
     I Have found that you can modify this number to .5 but you need
     to check to make sure you are working on a 3rd gen iPad. This
     seems to improve performance even further.
     */
    
    // Check if app is running on iPad 3rd Gen otherwise set contentScaleFactor to 1
    
    //  self.contentScaleFactor = 0.5;
    //  return;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            //newIPad
            self.contentScaleFactor = 0.5;
        }
        else {
            self.contentScaleFactor = 1;
        }
        
        
    } else {
        // non-Retina display
        self.contentScaleFactor = 1;
    }
    
    
    
}
- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] set];
    UIRectFill(rect);
    if (self.pdfPage == nil) {
        return;
    }
    
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            //newIPad
            self.contentScaleFactor = 0.5;
        }
        else {
            
            self.contentScaleFactor = 1;
        }
    } else {
        // non-Retina display
        self.contentScaleFactor = 1;
    }
    
    
    
	CGRect cropBox = CGPDFPageGetBoxRect(self.pdfPage, kCGPDFCropBox);
	int rotate = CGPDFPageGetRotationAngle(self.pdfPage);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	//CGContextTranslateCTM(context, point.x, point.y);
	
	// Scale the page to desired zoom level.
	//CGContextScaleCTM(context, zoom / 100, zoom / 100);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (rotate) {
		case 0:
            
			CGContextTranslateCTM(context, 0, self.frame.size.height);
			CGContextScaleCTM(context, 1, -1);
			break;
		case 90:
            
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -M_PI / 2);
			break;
		case 180:
		case -180:
            
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, self.frame.size.width, 0);
			CGContextRotateCTM(context, M_PI);
			break;
		case 270:
		case -90:
            
			CGContextTranslateCTM(context, self.frame.size.height, self.frame.size.width);
			CGContextRotateCTM(context, M_PI / 2);
			CGContextScaleCTM(context, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	//CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	//CGContextAddRect(context, clipRect);
	//CGContextClip(context);
	
	
	//CGContextTranslateCTM(context, -cropBox.origin.x, -cropBox.origin.y);
	CGContextScaleCTM(context,self.frame.size.width / cropBox.size.width,self.frame.size.height / cropBox.size.height);
    
    

    //draw selection text
    
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    for (IPaPDFScannerSelection *selection in self.selectionArray) {
        
        
        for (IPaPDFScannerSelectionPartObj *partObj in selection.frameList) {
            CGContextSaveGState(context);
            
            
            
            
            
            CGContextConcatCTM(context, partObj.transform);
            CGContextFillRect(context, partObj.frame);
            // NSLog(@"select Frame:%f %f %f %f",selection.frame.origin.x,selection.frame.origin.y,selection.frame.size.width,selection.frame.size.height);
            
            
            CGContextRestoreGState(context);
        }
        
        
        
    }   
    
    
	
	CGContextDrawPDFPage(context, self.pdfPage);
	CGContextRestoreGState(context);
    
    
    
    /*
     [[UIColor whiteColor] set];
     UIRectFill(rect);
     if (self.pdfPage == nil) {
     return;
     }
     
     CGContextRef ctx = UIGraphicsGetCurrentContext();
     CGContextSaveGState(ctx);
     CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);     
     CGContextTranslateCTM(ctx, 0.0,[self bounds].size.height);
     CGContextScaleCTM(ctx, 1.0, -1.0);
     CGContextConcatCTM(ctx,CGPDFPageGetDrawingTransform(self.pdfPage, kCGPDFCropBox, [self bounds], 0, true));
     CGContextDrawPDFPage(ctx, self.pdfPage);
     CGContextRestoreGState(ctx);
     */
    
    
    
    
    
}
-(void)setSelectionArray:(NSArray *)selectionArray
{
    _selectionArray = selectionArray;
    
    [self setNeedsDisplay];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.isEnableLink) {
        [self switchLinkButton:YES];
    }
    
}
-(void)removeAllLinkButton
{
    for (UIButton *button in LinkButtons) {
        [button removeFromSuperview];
    }
    LinkButtons = nil;
}
-(void)switchLinkButton:(BOOL)isOn
{
    if (isOn) {
        if (self.pdfPage == nil) {
            [self removeAllLinkButton];
            return;
        }
        NSMutableArray *linkButtonsArray;
        NSMutableArray *newButtonsArray;
        newButtonsArray = [NSMutableArray array];
        linkButtonsArray = (LinkButtons)?[NSMutableArray arrayWithArray:LinkButtons]:[NSMutableArray array];
        
        
        CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(self.pdfPage);
        
        CGPDFArrayRef outputArray;
        if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
            //沒有Link資料
            [self removeAllLinkButton];
            return;
        }
        
        int arrayCount = 0;
        arrayCount = CGPDFArrayGetCount(outputArray);
        if(arrayCount > 0) {
            for(int j = 0; j < arrayCount; ++j) {
                CGPDFObjectRef aDictObj;
                if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
                    [self removeAllLinkButton];
                    return;
                }
                
                CGPDFDictionaryRef annotDict;
                if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
                    [self removeAllLinkButton];
                    return;
                }
                
                CGPDFDictionaryRef aDict;
                if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
                    [self removeAllLinkButton];
                    return;
                }
                
                CGPDFStringRef uriStringRef;
                if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
                    [self removeAllLinkButton];
                    return;
                }
                
                CGPDFArrayRef rectArray;
                if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
                    [self removeAllLinkButton];
                    return;
                }
                
                
                
                CGPDFReal coords[4] = {0,0,0,0};
                if (rectArray != NULL) {
                    
                    CGPDFArrayGetNumber(rectArray, 0, &coords[0]);
                    
                    CGPDFArrayGetNumber(rectArray, 1, &coords[1]);
                    
                    CGPDFArrayGetNumber(rectArray, 2, &coords[2]);
                    
                    CGPDFArrayGetNumber(rectArray, 3, &coords[3]);
                    
                    if (coords[0] > coords[2]) {
                        CGPDFReal temp = coords[0];
                        coords[0] = coords[2];
                        coords[2] = temp;
                    }
                    if (coords[1] > coords[3]) {
                        CGPDFReal temp = coords[1];
                        coords[1] = coords[3];
                        coords[3] = temp;
                    }
                    
                    
                }
                
                //char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
                
                //                NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
                
                CGPoint lowerLeft = [self convertPDFPointToViewPoint:CGPointMake(coords[0], coords[1])];
                CGPoint upperRight = [self convertPDFPointToViewPoint:CGPointMake(coords[2], coords[3])];
                // lowerLeft = [self convertPDFPointToViewPoint:CGPointMake(0,0)];
                //upperRight = [self convertPDFPointToViewPoint:CGPointMake(100, 100)]; 
                // This is the rectangle positioned under the link
                CGRect viewRect = CGRectMake(lowerLeft.x, lowerLeft.y, upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
                
                // Now adjusting the rectangle to be on top of the link
                // viewRect = CGRectMake(viewRect.origin.x, viewRect.origin.y - viewRect.size.height, viewRect.size.width, viewRect.size.height);
                
                //                NSLog(@"%@", uri);
                
                UIButton *button;
                if (linkButtonsArray.count > 0) {
                    button = [linkButtonsArray lastObject];
                    [linkButtonsArray removeLastObject];
                }
                else {
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor greenColor]];
                    [button setAlpha:0.65];
                    [self addSubview:button];
                }
                [button setFrame:viewRect];
                [newButtonsArray addObject:button];
            }
            
            LinkButtons = [NSArray arrayWithArray:newButtonsArray];
            while (linkButtonsArray.count > 0) {
                UIButton *button = [linkButtonsArray lastObject];
                [linkButtonsArray removeLastObject];
                [button removeFromSuperview];
            }
        } 
    }
    else {
        [self removeAllLinkButton];
    }
}
-(void)setIsEnableLink:(BOOL)isEnableLink
{
    if (_isEnableLink == isEnableLink) {
        return;
    }
    [self setUserInteractionEnabled:isEnableLink];
    _isEnableLink = isEnableLink;
    
    [self switchLinkButton:_isEnableLink];
}



- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint
{
    CGPoint viewPoint = CGPointMake(0, 0);
    
    
    
    CGRect cropBox = CGPDFPageGetBoxRect(self.pdfPage, kCGPDFCropBox);
    
    int rotation = CGPDFPageGetRotationAngle(self.pdfPage);
    
    CGRect pageRenderRect;
    switch (rotation) {
        case 90:
        case -270:
            pageRenderRect = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
            
            viewPoint.x = pageRenderRect.size.width * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            viewPoint.y = pageRenderRect.size.height * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            break;
        case 180:
        case -180:
            pageRenderRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            viewPoint.x = pageRenderRect.size.width * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            viewPoint.y = pageRenderRect.size.height * (pdfPoint.y - cropBox.origin.y) / cropBox.size.height;
            break;
        case -90:
        case 270:
            pageRenderRect = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
            
            viewPoint.x = pageRenderRect.size.width * (cropBox.size.height - (pdfPoint.y - cropBox.origin.y)) / cropBox.size.height;
            viewPoint.y = pageRenderRect.size.height * (cropBox.size.width - (pdfPoint.x - cropBox.origin.x)) / cropBox.size.width;
            break;
        case 0:
        default:
            pageRenderRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            viewPoint.x = pageRenderRect.size.width * (pdfPoint.x - cropBox.origin.x) / cropBox.size.width;
            viewPoint.y = pageRenderRect.size.height * (cropBox.size.height - pdfPoint.y) / cropBox.size.height;
            break;
    }
    
    viewPoint.x = viewPoint.x + pageRenderRect.origin.x;
    viewPoint.y = viewPoint.y + pageRenderRect.origin.y;
    
    return viewPoint;
}

@end
