		//
//  IPaPDFView.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/6.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "IPaSinglePDFView.h"
#import "IPaPDFScanner.h"
#import "IPaListScrollView.h"
@interface PDFPageData : NSObject
@property (nonatomic,readwrite) CGAffineTransform transform;
@property (nonatomic,readwrite) CGPoint contentOffset;
@end
@implementation PDFPageData
@synthesize transform;
@synthesize contentOffset;
@end

@interface IPaPDFView () <IPaListScrollViewDelegate>
-(void)initialView;
//@property (nonatomic,strong) IPaPDFScanner *Scanner;
@property (nonatomic,readwrite) CGPDFDocumentRef PDFDocument;
@end


@implementation IPaPDFView
{
    //double PDFHeight, PDFWidth;
//    CGPDFDocumentRef PDFDocument;
    CGSize ItemPageSize;
    NSMutableDictionary *pageZoomData;
    NSMutableDictionary *selections;
}
@synthesize scrollDirection;
@synthesize scrollView = _scrollView;
//@synthesize pageSizeRatio;
@synthesize pagePerFrame = _pagePerFrame;
@synthesize PDFPathName;
@synthesize PDFDocument;
@synthesize delegate;
@synthesize pageRatio;
@synthesize currentPage = _currentPage;
//@synthesize Scanner = _Scanner;
//-(IPaPDFScanner*)Scanner
//{
//    if (_Scanner == nil) {
//        _Scanner = [[IPaPDFScanner alloc] init];
//    }
//    return _Scanner;
//}
-(void)initialView
{
//    self.pageSizeRatio = CGSizeMake(1, 1);        
    self.PDFDocument = nil;
    self.pagePerFrame = 1;
    self.pageRatio = CGSizeMake(1, 1);
    self.scrollView = [[IPaListScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.scrollView];
    [self.scrollView setControlDelegate:self];
    
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        [self initialView];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    [self initialView];
    return self;
}

-(UIImage*)getThumbnailWithPage:(NSUInteger)page withSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(self.PDFDocument);
    
    if (page >= totalNum) {
        return nil;
    }
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(self.PDFDocument, page+1);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [[UIColor whiteColor] set];
    UIRectFill(rect);
 
    
    
	CGRect cropBox = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
	int rotate = CGPDFPageGetRotationAngle(pageRef);


	switch (rotate) {
		case 0:
            
			CGContextTranslateCTM(context, 0, size.height);
			CGContextScaleCTM(context, 1, -1);
			break;
		case 90:
            
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -M_PI / 2);
			break;
		case 180:
		case -180:
            
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, size.width, 0);
			CGContextRotateCTM(context, M_PI);
			break;
		case 270:
		case -90:
            
			CGContextTranslateCTM(context, size.height, size.width);
			CGContextRotateCTM(context, M_PI / 2);
			CGContextScaleCTM(context, -1, 1);
			break;
	}
	
	// The CropBox defines the page visible area, clip everything outside it.
	//CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	//CGContextAddRect(context, clipRect);
	//CGContextClip(context);
	
	
	//CGContextTranslateCTM(context, -cropBox.origin.x, -cropBox.origin.y);
	CGContextScaleCTM(context,size.width / cropBox.size.width,size.height / cropBox.size.height);
    
    
       
	
	CGContextDrawPDFPage(context, pageRef);

    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 

    return thumbnailImage;
}
- (void)awakeFromNib
{
    [super awakeFromNib];

    
    
    
}
-(NSUInteger)PDFMaxPageNumber
{
    if (self.PDFDocument == nil) {
        return 0;
    }
    return CGPDFDocumentGetNumberOfPages(self.PDFDocument);
}
/*-(NSUInteger)currentPage
{
    NSInteger pageNum = [self.scrollView getCurrentPage];
    
    
    return pageNum * self.pagePerFrame;
}*/
-(void)setPagePerFrame:(NSUInteger)pagePerFrame
{
    
    NSUInteger currentPage = self.currentPage;
    _pagePerFrame = pagePerFrame;
    [self.scrollView RefreshItemViews];
    [self.scrollView ReloadContent];
    //when change orientation ,we need to recompute offset for current page

    [self setCurrentPage:currentPage animated:NO];
}
-(void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated
{
    _currentPage = currentPage;
    NSUInteger maxPageNum = CGPDFDocumentGetNumberOfPages(self.PDFDocument);
    if (maxPageNum == 0) {
        return;
    }
    if (currentPage >= maxPageNum) {
        currentPage = maxPageNum - 1;
    }
    
    NSInteger pageNum = currentPage / self.pagePerFrame;
    
    [self.scrollView setPage:MAX(pageNum,0) animated:animated];
}
-(void)setCurrentPage:(NSUInteger)currentPage
{
    [self setCurrentPage:currentPage animated:YES];
}

-(void)dealloc
{
    if (PDFDocument) {
        CGPDFDocumentRelease(PDFDocument);
        self.PDFDocument = nil;
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.scrollView ReloadContent];
}
-(void)clearAllSelection
{
    for (NSNumber *key in selections.allKeys) {
        NSUInteger page = [key unsignedIntegerValue];
        NSInteger itemIdx = page / self.pagePerFrame;
        UIView *item = [self.scrollView getItemWithIndex:itemIdx];
        UIView *contentView = [item viewWithTag:-1];
        itemIdx = page % self.pagePerFrame;
        IPaSinglePDFView *pageView = (IPaSinglePDFView *)[contentView viewWithTag:itemIdx];
        
        pageView.selectionArray = nil;    
        
    }
    [selections removeAllObjects];
}
-(void)setSelectionWithPage:(NSUInteger)page withSelection:(NSArray*)selection
{
    
    NSInteger itemIdx = page / self.pagePerFrame;
    UIView *item = [self.scrollView getItemWithIndex:itemIdx];
    UIView *contentView = [item viewWithTag:-1];
    itemIdx = page % self.pagePerFrame;
    
    IPaSinglePDFView *pageView = (IPaSinglePDFView *)[contentView viewWithTag:itemIdx];
    
    pageView.selectionArray = selection;    
    if (selection) {
        if (!selections) {
            selections = [NSMutableDictionary dictionaryWithObject:selection forKey:[NSNumber numberWithUnsignedInteger:page]];
        }
        else {
           
            [selections setObject:selection forKey:[NSNumber numberWithUnsignedInteger:page]];
        }
        
 
    }
    
    else {
        //clear data
        [selections removeObjectForKey:[NSNumber numberWithUnsignedInteger:page]];

        
    }
    

}

/*-(void)setSearchKeyword:(NSString*)keyword
{

    NSArray *result = [self.Scanner scanDocument:self.PDFDocument withPageNum:1 withKeyword:keyword];
    
    
    UIView *item = [self.scrollView getItemWithIndex:0];
    IPaSinglePDFView *pageView = (IPaSinglePDFView *)[[item viewWithTag:100].subviews lastObject];
    pageView.selectionArray = result;
}*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



-(void)setPDF:(NSString *)pdfFilePath
{
    
    if (self.PDFDocument) {
        CGPDFDocumentRelease(PDFDocument);
        self.PDFDocument = nil;  
    }
    self.PDFPathName = pdfFilePath;
    NSURL *pdfUrl = [NSURL fileURLWithPath:pdfFilePath];
    
    PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfUrl);
    
    CGPDFPageRef page = CGPDFDocumentGetPage(self.PDFDocument, 1); // assuming all the pages are the same size!
    
    // code from http://stackoverflow.com/questions/4080373/get-pdf-hyperlinks-on-ios-with-quartz, 
    // suitably amended
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(page);
    
    
    //******* getting the page size
    
    CGPDFArrayRef pageBoxArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "MediaBox", &pageBoxArray)) {
        NSLog(@"setPDF fail!!!");
        return; // we've got something wrong here!!!
    }
    
    //int pageBoxArrayCount = CGPDFArrayGetCount( pageBoxArray );
    CGPDFReal pageCoords[4];
    for( int k = 0; k < 4; ++k )
    {
        CGPDFObjectRef pageRectObj;
        if(!CGPDFArrayGetObject(pageBoxArray, k, &pageRectObj))
        {
            NSLog(@"setPDF fail!!!...get object fail!");
            return;
        }
        
        CGPDFReal pageCoord;
        if(!CGPDFObjectGetValue(pageRectObj, kCGPDFObjectTypeReal, &pageCoord)) {
            NSLog(@"setPDF fail!!!...get value fail!");
            return;
        }
        
        pageCoords[k] = pageCoord;
    }
    
    /*NSLog(@"PDF coordinates -- bottom left x %f  ",pageCoords[0]); // should be 0
    NSLog(@"PDF coordinates -- bottom left y %f  ",pageCoords[1]); // should be 0
    NSLog(@"PDF coordinates -- top right   x %f  ",pageCoords[2]);
    NSLog(@"PDF coordinates -- top right   y %f  ",pageCoords[3]);
    NSLog(@"-- i.e. PDF page is %f wide and %f high",pageCoords[2],pageCoords[3]);
    */
    // **** now to convert a point on the page from PDF coordinates to iOS coordinates. 
    
    
//    double PDFWidth =  pageCoords[2];
//    double PDFHeight = pageCoords[3];
    
    
  //  double ratio = self.frame.size.width / PDFWidth;
    ItemPageSize = CGSizeMake(pageCoords[2], pageCoords[3]);
    
    
  /*  // the size of your iOS view or image into which you have rendered your PDF page 
    // in this example full screen iPad in portrait orientation  
    double iOSWidth = 768.0; 
    double iOSHeight = 1024.0;
    
    // the PDF co-ordinate values you want to convert 
    double PDFxval = 89;  // or whatever
    double PDFyval = 520; // or whatever
    
    // the iOS coordinate values
    int iOSxval, iOSyval;
    
    iOSxval = (int) PDFxval * (iOSWidth/PDFWidth);
    iOSyval = (int) (PDFHeight - PDFyval) * (iOSHeight/PDFHeight);
    
    NSLog(@"PDF: %f %f",PDFxval,PDFyval);
    NSLog(@"iOS: %i %i",iOSxval,iOSyval);*/

    if (pageZoomData)
    {
        [pageZoomData removeAllObjects];
    }
    
    [self.scrollView RefreshItemViews];
    [self.scrollView RefreshContentSize];    
    [self.scrollView RefreshScrollView];
    
    
    
  //================================================  
    [self.scrollView setPage:0 animated:NO];
    
    
}

-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    if (self.PDFDocument != nil) {
        return ceil((CGFloat)CGPDFDocumentGetNumberOfPages(self.PDFDocument) / self.pagePerFrame);
    }
    return 0;
}
//get item size
-(CGFloat) IPaListScrollViewItemHeight:(IPaListScrollView*)scrollView
{


    return self.bounds.size.height; 
//    return height *  self.pageSizeRatio.height;
}
-(CGFloat) IPaListScrollViewItemWidth:(IPaListScrollView*)scrollView
{
    return self.bounds.size.width;    
}

//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index
{
    UIScrollView *itemView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
    itemView.minimumZoomScale = 1;
    itemView.maximumZoomScale = 3.0;
    [itemView setBackgroundColor:[UIColor whiteColor]];

    itemView.delegate = self;
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
    containView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [itemView addSubview:containView];
  //  IPaSinglePDFView *pdfView = [[IPaSinglePDFView alloc] initWithFrame:CGRectMake(0, 0, 10,10)];
//    pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [itemView addSubview:pdfView];
    containView.tag = -1;
    
    return itemView;
}
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    //CGPDFDocumentGetPage's page number start from 1
    UIScrollView *pageScrollView = (UIScrollView*)Item;
    UIView *containView = [Item viewWithTag:-1];
    while (containView.subviews.count > self.pagePerFrame) {
        [containView.subviews.lastObject removeFromSuperview];
    }
    NSUInteger pageNumber = CGPDFDocumentGetNumberOfPages(self.PDFDocument);
    CGFloat PageSizeWidth = self.pageRatio.width * self.bounds.size.width / self.pagePerFrame;
    CGFloat PageSizeHeight = self.pageRatio.height * self.bounds.size.height;
    //right direction only
    
    NSUInteger startPage = Index * self.pagePerFrame;
    
    
    for (NSUInteger idx = 0; idx < self.pagePerFrame; idx++) {
        UIView *subView = [containView viewWithTag:idx];
        IPaSinglePDFView *pdfView;
        if (subView == nil) {
            pdfView = [[IPaSinglePDFView alloc] initWithFrame:CGRectMake(0, 0, 10,10)];
            pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [containView addSubview:pdfView];
            pdfView.tag = idx;
        }
        else {
            pdfView = (IPaSinglePDFView*)subView;
        }
        NSUInteger currentPage = startPage + idx;
        [pdfView setFrame:CGRectMake(PageSizeWidth * idx, 0, PageSizeWidth, PageSizeHeight)];
        pdfView.pdfPage = (pageNumber > currentPage)?CGPDFDocumentGetPage(self.PDFDocument, currentPage + 1):nil;


        pdfView.selectionArray = [selections objectForKey:[NSNumber numberWithUnsignedInteger:currentPage]];
        

        
        
        
    }
    
   
    Item.tag = Index;
    
    NSString *currentKey = [NSString stringWithFormat:@"%d",Index];
    PDFPageData *value = [pageZoomData objectForKey:currentKey];
    
    if (value == nil) {
        containView.transform = CGAffineTransformIdentity;        
        pageScrollView.contentSize = containView.frame.size;
        containView.center = CGPointMake(Item.frame.size.width/2, Item.frame.size.height/2);    
        pageScrollView.contentSize = CGSizeMake(PageSizeWidth * self.pagePerFrame, PageSizeHeight);
        
    }
    else {

        containView.transform = value.transform;
        
        pageScrollView.contentSize = CGSizeApplyAffineTransform(CGSizeMake(PageSizeWidth, PageSizeHeight),containView.transform);
        containView.center = CGPointMake(pageScrollView.contentSize.width/2, pageScrollView.contentSize.height/2);    
        pageScrollView.contentOffset = value.contentOffset;
    }
    
}
-(void)IPaListScrollViewDidScroll:(IPaListScrollView *)scrollView
{
    _currentPage = scrollView.lastCurrentPage * self.pagePerFrame;
    if ([self.delegate respondsToSelector:@selector(IPaPDFViewDidScroll:)]) {
        [self.delegate IPaPDFViewDidScroll:self];
    }
}


-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:-1];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (pageZoomData == nil) {
        pageZoomData = [NSMutableDictionary dictionaryWithCapacity:CGPDFDocumentGetNumberOfPages(self.PDFDocument)];
    }
    NSString *currentKey = [NSString stringWithFormat:@"%d",scrollView.tag];
    
    CGFloat PageSizeWidth = self.pageRatio.width * self.bounds.size.width;
    CGFloat PageSizeHeight = self.pageRatio.height * self.bounds.size.height;
    
    if (scale == 1.0) {
        [pageZoomData removeObjectForKey:currentKey];
    }
    else {
        
        PDFPageData *data = [pageZoomData objectForKey:currentKey];
        if (data == nil) {
            data = [[PDFPageData alloc] init];
        }
        data.transform = view.transform;
        data.contentOffset = scrollView.contentOffset;
        [pageZoomData setObject:data forKey:currentKey];
    }
    
    
    [scrollView setContentSize:CGSizeMake(PageSizeWidth * scale, PageSizeHeight * scale)];
    
    [view setNeedsLayout];
//    [view.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSString *currentKey = [NSString stringWithFormat:@"%d",scrollView.tag];
    PDFPageData *data = [pageZoomData objectForKey:currentKey];
    if (data != nil) {
        UIView* view = [scrollView viewWithTag:-1];
        data.transform = view.transform;
        data.contentOffset = scrollView.contentOffset;
    }
}

-(void) IPaListScrollViewStopOnItemPage:(IPaListScrollView*)scrollView withPage:(NSInteger)page
{
    
    _currentPage = page * self.pagePerFrame;
    if ([self.delegate respondsToSelector:@selector(IPaPDFView:stopOnPage:)]) {
        [self.delegate IPaPDFView:self stopOnPage:page];
    }

}
@end
