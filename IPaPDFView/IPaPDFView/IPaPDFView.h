//
//  IPaPDFView.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/6.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaListScrollView;
@protocol IPaPDFViewDelegate;
typedef enum {
   IPaPDF_SCROLL_LEFT = 0, 
   IPaPDF_SCROLL_RIGHT,
   IPaPDF_SCROLL_UP,
   IPaPDF_SCROLL_DOWN    
} IPaPDF_SCROLL_DIRECTION;
@interface IPaPDFView : UIView <UIScrollViewDelegate>


@property (nonatomic,assign) IPaPDF_SCROLL_DIRECTION scrollDirection;
//Scroll View in PDF View
@property (nonatomic,strong) IPaListScrollView *scrollView;

@property (nonatomic,copy) NSString *PDFPathName;
//page number of left page
@property (nonatomic,readwrite) NSUInteger currentPage;
//number of pdf pages in one presenting page
@property (nonatomic,assign) NSUInteger pagePerFrame;
//current PDFDocument
@property (nonatomic,readonly) CGPDFDocumentRef PDFDocument;
@property (nonatomic,assign) id <IPaPDFViewDelegate> delegate;
@property (nonatomic,assign) CGSize pageRatio;
@property (nonatomic,readonly) NSUInteger PDFMaxPageNumber;

-(void)setPDF:(NSString*)pdfFilePath;
-(void)setSelectionWithPage:(NSUInteger)page withSelection:(NSArray*)selection;
//clear all selection
-(void)clearAllSelection;
-(void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated;
-(UIImage*)getThumbnailWithPage:(NSUInteger)page withSize:(CGSize)size;

@end

@protocol IPaPDFViewDelegate <NSObject>
@optional
-(void) IPaPDFView:(IPaPDFView*)pdfView stopOnPage:(NSUInteger)page;
-(void) IPaPDFViewDidScroll:(IPaPDFView*)pdfView;



@end
