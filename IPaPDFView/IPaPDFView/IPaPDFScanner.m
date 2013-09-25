//
//  IPaPDFScanner.m
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPaPDFScanner.h"
#import "IPaPDFScannerRenderState.h"
#import "IPaPDFScannerFontCollection.h"


@interface IPaPDFScanner ()
/* Returts the operator callbacks table for scanning page stream */
@property (nonatomic, readonly) CGPDFOperatorTableRef operatorTable;
@property (nonatomic,strong) IPaPDFScannerFontCollection *fontCollection;
@property (nonatomic,strong) NSMutableArray *selections;
@property (nonatomic,strong) IPaPDFScannerSelection *currentSelection;
@property (nonatomic,strong) IPaPDFScannerStringDetector *stringDetector;
@end

@interface IPaPDFScanner (PDFOperatorTable)
#pragma mark - Text showing

// Text-showing operators
void Tj(CGPDFScannerRef scanner, void *info);
void quot(CGPDFScannerRef scanner, void *info);
void doubleQuot(CGPDFScannerRef scanner, void *info);
void TJ(CGPDFScannerRef scanner, void *info);

#pragma mark Text positioning

// Text-positioning operators
void Td(CGPDFScannerRef scanner, void *info);
void TD(CGPDFScannerRef scanner, void *info);
void Tm(CGPDFScannerRef scanner, void *info);
void TStar(CGPDFScannerRef scanner, void *info);

#pragma mark Text state

// Text state operators
void BT(CGPDFScannerRef scanner, void *info);
void Tc(CGPDFScannerRef scanner, void *info);
void Tw(CGPDFScannerRef scanner, void *info);
void Tz(CGPDFScannerRef scanner, void *info);
void TL(CGPDFScannerRef scanner, void *info);
void Tf(CGPDFScannerRef scanner, void *info);
void Ts(CGPDFScannerRef scanner, void *info);

#pragma mark Graphics state

// Special graphics state operators
void q(CGPDFScannerRef scanner, void *info);
void Q(CGPDFScannerRef scanner, void *info);
void cm(CGPDFScannerRef scanner, void *info);
#pragma mark Text showing operators

void didScanSpace(float value, IPaPDFScanner *scanner);
void didScanString(CGPDFStringRef pdfString, IPaPDFScanner *scanner);
@end

@implementation IPaPDFScanner (PDFOperatorTable)

#pragma mark - Text showing

// Text-showing operators
// Show a string
void Tj(CGPDFScannerRef scanner, void *info)
{
    CGPDFStringRef pdfString = nil;
	if (!CGPDFScannerPopString(scanner, &pdfString)) 
        return;
    
	didScanString(pdfString, (__bridge IPaPDFScanner*)info);
}
// Equivalent to operator sequence [T*, Tj] 
void quot(CGPDFScannerRef scanner, void *info)
{
    TStar(scanner, info);
	Tj(scanner, info);
}
// Equivalent to the operator sequence [Tw, Tc, ']
void doubleQuot(CGPDFScannerRef scanner, void *info)
{
    Tw(scanner, info);
	Tc(scanner, info);
	quot(scanner, info);
}
//Array of strings and spacings
void TJ(CGPDFScannerRef scanner, void *info)
{
    CGPDFArrayRef array = nil;
	CGPDFScannerPopArray(scanner, &array);
    size_t count = CGPDFArrayGetCount(array);
    
	for (int i = 0; i < count; i++)
	{
		CGPDFObjectRef object = nil;
		CGPDFArrayGetObject(array, i, &object);
		CGPDFObjectType type = CGPDFObjectGetType(object);
        
        switch (type)
        {
            case kCGPDFObjectTypeString:
            {
                CGPDFStringRef pdfString = nil;
                CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &pdfString);
                didScanString(pdfString, (__bridge IPaPDFScanner*)info);
                break;
            }
            case kCGPDFObjectTypeReal:
            {
                CGPDFReal tx = 0.0f;
                CGPDFObjectGetValue(object, kCGPDFObjectTypeReal, &tx);
                didScanSpace(tx, (__bridge IPaPDFScanner*)info);
                break;
            }
            case kCGPDFObjectTypeInteger:
            {
                CGPDFInteger tx = 0L;
                CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &tx);
                didScanSpace(tx, (__bridge IPaPDFScanner*)info);
                break;
            }
            default:
                NSLog(@"Scanner: TJ: Unsupported type: %d", type);
                break;
        }
	}
}

#pragma mark Text positioning

// Move to start of next line

void Td(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal tx = 0, ty = 0;
	if (!CGPDFScannerPopNumber(scanner, &ty)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) 
        return;
    IPaPDFScannerRenderState *currentState = [IPaPDFScannerRenderState currentRenderingState];
    IPaPDFScannerRenderState *oldState = [currentState copy];
    [[IPaPDFScannerRenderState currentRenderingState] newLineWithLeading:-ty indent:tx save:NO];
    [[IPaPDFScanner defaultScanner].currentSelection insertNewLineWithState:currentState withOldState:oldState];
}
// Move to start of next line, and set leading
void TD(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) 
        return;
	
    
    IPaPDFScannerRenderState *currentState = [IPaPDFScannerRenderState currentRenderingState];
    IPaPDFScannerRenderState *oldState = [currentState copy];
    [[IPaPDFScannerRenderState currentRenderingState] newLineWithLeading:-ty indent:tx save:YES];
    [[IPaPDFScanner defaultScanner].currentSelection insertNewLineWithState:currentState withOldState:oldState];
}
// Set line and text matrixes
void Tm(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &d)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &c)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &b)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &a)) 
        return;
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
	[[IPaPDFScannerRenderState currentRenderingState] setTextMatrix:t replaceLineMatrix:YES];
}

// Go to start of new line, using stored text leading
void TStar(CGPDFScannerRef scanner, void *info)
{
    IPaPDFScannerRenderState *currentState = [IPaPDFScannerRenderState currentRenderingState];
    IPaPDFScannerRenderState *oldState = [currentState copy];
    [[IPaPDFScannerRenderState currentRenderingState] newLine];
    [[IPaPDFScanner defaultScanner].currentSelection insertNewLineWithState:currentState withOldState:oldState];
}

#pragma mark Text state

// Text state operators
void BT(CGPDFScannerRef scanner, void *info)
{
    [[IPaPDFScannerRenderState currentRenderingState] setTextMatrix:CGAffineTransformIdentity replaceLineMatrix:YES];    
}
// Set character spacing
void Tc(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal charSpace;
	if (!CGPDFScannerPopNumber(scanner, &charSpace))
        return;
	[[IPaPDFScannerRenderState currentRenderingState] setCharacterSpacing:charSpace];
}
// Set word spacing
void Tw(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal wordSpace;
	if (!CGPDFScannerPopNumber(scanner, &wordSpace)) 
        return;
	[[IPaPDFScannerRenderState currentRenderingState] setWordSpacing:wordSpace];
}
//Set horizontal scale factor
void Tz(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal hScale;
	if (!CGPDFScannerPopNumber(scanner, &hScale)) 
        return;
	[[IPaPDFScannerRenderState currentRenderingState] setHorizontalScaling:hScale];
}
//Set text leading
void TL(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal leading;
	if (!CGPDFScannerPopNumber(scanner, &leading)) 
        return;
	[[IPaPDFScannerRenderState currentRenderingState] setLeadning:leading];
}
// Font and font size
void Tf(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal fontSize;
	const char *fontName;
	if (!CGPDFScannerPopNumber(scanner, &fontSize))
        return;
	if (!CGPDFScannerPopName(scanner, &fontName)) 
        return;
	IPaPDFScanner *ipaScanner = (__bridge IPaPDFScanner *)info;
	IPaPDFScannerRenderState *state = [IPaPDFScannerRenderState currentRenderingState];
	IPaPDFScannerFont *font = [ipaScanner.fontCollection fontNamed:[NSString stringWithUTF8String:fontName]];
    NSLog(@"IPaPDFScanner setFont with name:%s",fontName);
	[state setFont:font];
	[state setFontSize:fontSize];
}
//Set text rise
void Ts(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal rise;
	if (!CGPDFScannerPopNumber(scanner, &rise)) 
        return;
	[[IPaPDFScannerRenderState currentRenderingState] setTextRise:rise];
}

#pragma mark Graphics state

// Special graphics state operators
//Push a copy of current rendering state
void q(CGPDFScannerRef scanner, void *info)
{
//    IPaPDFScanner *ipaScanner = (__bridge IPaPDFScanner *)info;
//    RenderingStateStack *stack = [(Scanner *)info renderingStateStack];
//	RenderingState *state = [[(Scanner *)info currentRenderingState] copy];
//	[stack pushRenderingState:state];
    [IPaPDFScannerRenderState pushRenderingState];
}
//Pop current rendering state
void Q(CGPDFScannerRef scanner, void *info)
{
    [IPaPDFScannerRenderState popRenderingState];
}
//Update CTM
void cm(CGPDFScannerRef scanner, void *info)
{
    CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty))
        return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &d)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &c)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &b)) 
        return;
	if (!CGPDFScannerPopNumber(scanner, &a)) 
        return;
	IPaPDFScannerRenderState *state = [IPaPDFScannerRenderState currentRenderingState];
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
	state.ctm = CGAffineTransformConcat(state.ctm, t);
}
#pragma mark Text showing operators

void didScanSpace(float value, IPaPDFScanner *scanner)
{
    IPaPDFScannerRenderState *state = [IPaPDFScannerRenderState currentRenderingState];
    float width = [state convertToUserSpace:value];
    [state translateTextPosition:CGSizeMake(-width, 0)];

    if (abs(value) >= state.widthOfSpace)
    {
        [scanner.stringDetector reset];
    }
}

// Called any time the scanner scans a string
void didScanString(CGPDFStringRef pdfString, IPaPDFScanner *scanner)
{	
    
    [scanner.stringDetector appendPDFString:pdfString withFont:[IPaPDFScannerRenderState currentFont]];
	
}
@end


@implementation IPaPDFScanner
{

}
@synthesize stringDetector;
@synthesize operatorTable;
@synthesize currentSelection;
@synthesize selections;
@synthesize fontCollection;

-(IPaPDFScannerStringDetector*)stringDetector
{
    if (stringDetector == nil) {
        stringDetector = [[IPaPDFScannerStringDetector alloc] init];
        stringDetector.delegate = self;
    }
    return stringDetector;
}
-(NSArray*)selections
{
    if (selections == nil) {
        selections = [NSMutableArray array];
    }
    return selections;
}

/* The operator table used for scanning PDF pages */
- (CGPDFOperatorTableRef)operatorTable
{
	if (operatorTable)
	{
		return operatorTable;
	}
	
	operatorTable = CGPDFOperatorTableCreate();
    
	// Text-showing operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tj", Tj);
	CGPDFOperatorTableSetCallback(operatorTable, "\'", quot);
	CGPDFOperatorTableSetCallback(operatorTable, "\"", doubleQuot);
	CGPDFOperatorTableSetCallback(operatorTable, "TJ", TJ);
	
	// Text-positioning operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tm", Tm);
	CGPDFOperatorTableSetCallback(operatorTable, "Td", Td);		
	CGPDFOperatorTableSetCallback(operatorTable, "TD", TD);
	CGPDFOperatorTableSetCallback(operatorTable, "T*", TStar);
	
	// Text state operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tw", Tw);
	CGPDFOperatorTableSetCallback(operatorTable, "Tc", Tc);
	CGPDFOperatorTableSetCallback(operatorTable, "TL", TL);
	CGPDFOperatorTableSetCallback(operatorTable, "Tz", Tz);
	CGPDFOperatorTableSetCallback(operatorTable, "Ts", Ts);
	CGPDFOperatorTableSetCallback(operatorTable, "Tf", Tf);
	
	// Graphics state operators
	CGPDFOperatorTableSetCallback(operatorTable, "cm", cm);
	CGPDFOperatorTableSetCallback(operatorTable, "q", q);
	CGPDFOperatorTableSetCallback(operatorTable, "Q", Q);
	
	CGPDFOperatorTableSetCallback(operatorTable, "BT", BT);
	
	return operatorTable;
}

/* Create a font dictionary given a PDF page */
- (void)setFontCollectionWithPage:(CGPDFPageRef)page
{
    self.fontCollection = nil;
	CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
	if (!dict)
	{
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing");
		return ;
	}
	CGPDFDictionaryRef resources;
	if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources))
	{
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing Resources dictionary");
		return;	
	}
	CGPDFDictionaryRef fonts;
	if (!CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) 
        return;
	self.fontCollection = [[IPaPDFScannerFontCollection alloc] initWithFontDictionary:fonts];

}
-(NSArray *)scanDocumentOutline:(CGPDFDocumentRef)document
{

    CGPDFDictionaryRef dict = CGPDFDocumentGetCatalog(document  );
    CGPDFDictionaryRef subDict;
  //  const char *type;
  //  CGPDFDictionaryGetName(dict, "Type", &type);
        
    if (CGPDFDictionaryGetDictionary(dict, "Outlines", &subDict))
    {
        return [self scanOutlineFromPDFDictionary:subDict withDocument:document];
    }
    return nil;
}

- (int) getPageNumberFromArray:(CGPDFArrayRef)array ofPdfDoc:(CGPDFDocumentRef)pdfDoc
{
    int pageNumber = -1;
    
    // Page number reference is the first element of array (el 0)
    CGPDFDictionaryRef pageDic;
    CGPDFArrayGetDictionary(array, 0, &pageDic);
    NSUInteger numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDoc);
    // page searching
    for (int p=1; p<=numberOfPages; p++)
    {
        CGPDFPageRef page = CGPDFDocumentGetPage(pdfDoc, p);
        if (CGPDFPageGetDictionary(page) == pageDic)
        {
            pageNumber = p;
            break;
        }
    }
    
    return pageNumber;
}
-(NSArray *)scanOutlineFromPDFDictionary:(CGPDFDictionaryRef) pdfDict withDocument:(CGPDFDocumentRef) document
{
    CGPDFDictionaryRef currentDict;
    if (!CGPDFDictionaryGetDictionary(pdfDict, "First", &currentDict))
    {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray array];
    CGPDFStringRef title;
    //CGPDFDictionaryGetDictionary(pdfDict, "Last", &dictSub4);
    
    //  NSLog(@"outline--");    
    NSInteger idx = 0;
    
    while (1) {
        //讀入title
        IPaPDFOutlineData *outlineData = [[IPaPDFOutlineData alloc] init];
        
        if(!CGPDFDictionaryGetString(currentDict, "Title", &title))
            break;
        outlineData.Title = (__bridge_transfer NSString*)CGPDFStringCopyTextString(title);
        
        //讀入頁數..
        
        //只處理"A"標籤的連結，不處理Name destination的方式，(搞不懂...)
        CGPDFDictionaryRef dicoActions;
        if(CGPDFDictionaryGetDictionary(currentDict, "A", &dicoActions))
        {
            const char * typeOfActionConstChar;
            CGPDFDictionaryGetName(dicoActions, "S", &typeOfActionConstChar);
            
            NSString * typeOfAction = [NSString stringWithUTF8String:typeOfActionConstChar];
            if([typeOfAction isEqualToString:@"GoTo"]) // only support "GoTo" entry. See PDF spec p653
            {
                CGPDFArrayRef dArray;
                if(CGPDFDictionaryGetArray(dicoActions, "D", &dArray)) 
                {
                    outlineData.pageNum = 0;
                    
                    // Page number reference is the first element of array (el 0)
                    CGPDFDictionaryRef pageDic;
                    CGPDFArrayGetDictionary(dArray, 0, &pageDic);
                    NSUInteger numberOfPages = CGPDFDocumentGetNumberOfPages(document);
                    // page searching
                    for (int p=1; p<=numberOfPages; p++)
                    {
                        CGPDFPageRef page = CGPDFDocumentGetPage(document, p);
                        if (CGPDFPageGetDictionary(page) == pageDic)
                        {
                            outlineData.pageNum = p;
                            break;
                        }
                    }
                    
                
                }
            }
        }

        
        
        
        //搜尋此outline的子oultine
        outlineData.children = [self scanOutlineFromPDFDictionary:currentDict withDocument:document];
        
        
        
        [result addObject:outlineData];
        CGPDFDictionaryRef next;
        if (!CGPDFDictionaryGetDictionary(currentDict, "Next", &next))
            break;
            
        if (next == currentDict) {
            break;
        }
        currentDict = next;
        idx++;
    }
    return result;
}
- (NSArray *)scanDocument:(CGPDFDocumentRef)document withKeyword:(NSString*)keyword
{
    NSUInteger pageNum = CGPDFDocumentGetNumberOfPages(document);

    self.stringDetector.keyword = keyword;
    if (pageNum == 0) {
        return [NSArray array];
    }
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:pageNum];
    for (NSUInteger idx = 0; idx < pageNum; idx++) {
        CGPDFPageRef page = CGPDFDocumentGetPage(document, idx);
        [resultArray addObject:[self doScanPage:page]];
    }
    return resultArray;
}
- (NSArray *)scanDocument:(CGPDFDocumentRef)document withPageNum:(NSUInteger)pageNum withKeyword:(NSString*)keyword
{
    if (keyword == nil || [keyword isEqualToString:@""]) {
        return [NSArray array];
    }
    
    self.stringDetector.keyword = keyword;
    CGPDFPageRef page = CGPDFDocumentGetPage(document, pageNum);
    return [self doScanPage:page];
}
- (NSArray *)scanPage:(CGPDFPageRef)page withKeyword:(NSString*)keyword
{
    if (keyword == nil || [keyword isEqualToString:@""]) {
        return [NSArray array];
    }
    
    self.stringDetector.keyword = keyword;
    return [self doScanPage:page];
}
-(NSArray *)doScanPage:(CGPDFPageRef)page
{
    [self setFontCollectionWithPage:page];
    self.selections = nil;
    

    CGPDFContentStreamRef content = CGPDFContentStreamCreateWithPage(page);
	CGPDFScannerRef scanner = CGPDFScannerCreate(content, self.operatorTable, (__bridge void*)self);
	CGPDFScannerScan(scanner);
	CGPDFScannerRelease(scanner);
    scanner = nil;
	CGPDFContentStreamRelease(content); 
    content = nil;
    NSArray* retSelection = [NSArray arrayWithArray:self.selections];
    self.selections = nil;


    return retSelection;
    
}
#pragma mark IPaPDFScannerStringDetectorDelegate

- (void)detector:(IPaPDFScannerStringDetector *)detector didScanCharacter:(unichar)character
{
	IPaPDFScannerRenderState *state = [IPaPDFScannerRenderState currentRenderingState];
	CGFloat width = [[IPaPDFScannerRenderState currentFont] widthOfCharacter:character withFontSize:state.fontSize];
	width /= 1000;
	width += state.characterSpacing;
	if (character == 32)
	{
		width += state.wordSpacing;
	}
	[state translateTextPosition:CGSizeMake(width, 0)];
}

- (void)detector:(IPaPDFScannerStringDetector *)detector didStartMatchingString:(NSString *)string
{
	self.currentSelection = [[IPaPDFScannerSelection alloc] initWithStartState:[IPaPDFScannerRenderState currentRenderingState]];
}

- (void)detector:(IPaPDFScannerStringDetector *)detector foundString:(NSString *)needle
{	

	[self.currentSelection finalizeWithState:[IPaPDFScannerRenderState currentRenderingState]];
    
	if (self.currentSelection)
	{
		[self.selections addObject:self.currentSelection];
		self.currentSelection = nil;
	}
}
#pragma mark - Global
+(IPaPDFScanner*)defaultScanner
{
    static IPaPDFScanner *defaultScanner = nil;
    if (defaultScanner == nil) {
        defaultScanner = [[IPaPDFScanner alloc] init];
    }
    return defaultScanner;
}
//return outline data in Document
+(NSArray *)scanDocumentOutline:(CGPDFDocumentRef)document
{
    return [[IPaPDFScanner defaultScanner] scanDocumentOutline:document];
}


//return array of IPaPDFScannerSelection
+ (NSArray *)scanPage:(CGPDFPageRef)page withKeyword:(NSString*)keyword
{
    return [[IPaPDFScanner defaultScanner] scanPage:page withKeyword:keyword];
}
//return array of arry ，the first level of array represent search result of every page ，the second level of array is array of IPaPDFScannerSelection
+ (NSArray *)scanDocument:(CGPDFDocumentRef)document withKeyword:(NSString*)keyword
{
    return [[IPaPDFScanner defaultScanner] scanDocument:document withKeyword:keyword];
}
//return array of IPaPDFScannerSelection
+ (NSArray *)scanDocument:(CGPDFDocumentRef)document withPageNum:(NSUInteger)pageNum withKeyword:(NSString*)keyword
{
    return [[IPaPDFScanner defaultScanner] scanDocument:document withPageNum:pageNum withKeyword:keyword];
}

@end

