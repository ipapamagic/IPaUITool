//
//  IPaListScrollView.m
//  IPaListScrollView
//
//  Created by IPaPa on 11/10/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IPaListScrollView.h"

#define LOOP_SIZE_RATIO 5
enum {
    NONE_ANIM = 0,
    SET_PAGE_ANIM,
    END_SCROLL_TO_PAGE_ANIM
};
@interface IPaListScrollView ()
@property (nonatomic,readwrite) NSInteger lastCurrentPage;
@end
@implementation IPaListScrollView
{
    
    NSArray *itemArray;
    //record every UIView data
    NSMutableArray *itemData;
    NSUInteger RowItemNum;
    NSUInteger ColumnItemNum;
    NSInteger workingScrollingAnim;
}
#pragma mark - Property
-(BOOL) isLoop
{
    return [self.controlDelegate respondsToSelector:@selector(isIPaListScrollViewLoopShow:)]?
    [self.controlDelegate isIPaListScrollViewLoopShow:self]:NO;
    
}
-(NSUInteger) LoopSizeRatio
{
    return [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewLoopSizeRatio:)]?
    [self.controlDelegate IPaListScrollViewLoopSizeRatio:self]:LOOP_SIZE_RATIO;
}
-(BOOL) isColumnMajor
{
    return ([self.controlDelegate respondsToSelector:@selector(isIPaListScrollViewColumnMajor:)])?
    [self.controlDelegate isIPaListScrollViewColumnMajor:self]:YES;
}

#pragma mark -
-(void)drawRect:(CGRect)rect
{
    
    if (_backgroundImg) {
        CGSize imgSize = self.bounds.size;
        if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewBackgroundImgSize:)]) {
            imgSize = [self.controlDelegate IPaListScrollViewBackgroundImgSize:self];
        }
        
        NSInteger temp = floor(self.contentOffset.x / imgSize.width);
        CGFloat posX = (self.contentOffset.x - (imgSize.width * temp));
        temp = floor(self.contentOffset.y / imgSize.height);
        CGFloat posY = (self.contentOffset.y - (imgSize.height * temp));
        
        CGPoint drawPoint = CGPointMake(-posX, -posY);
        //畫第一張
        
        while (drawPoint.x < self.bounds.size.width) {
            
            while (drawPoint.y < self.bounds.size.height) {
                [_backgroundImg drawInRect:CGRectMake(drawPoint.x + self.contentOffset.x, drawPoint.y + self.contentOffset.y, imgSize.width, imgSize.height)];
                
                drawPoint.y += imgSize.height;
            }
            drawPoint.x += imgSize.width;
            
            drawPoint.y = -posY;
        }
        //        [self layoutSubviews];
    }
}

-(void)RefreshItemViews
{
    if (self.controlDelegate == nil) {
        return;
    }
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    CGFloat contentSizeX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetX:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetX:self]:0;
    CGFloat contentSizeY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetY:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetY:self]:0;
    
    RowItemNum = ceil((self.bounds.size.height - offsetY - contentSizeY + DistanceY) / actualItemDisH);
    ColumnItemNum = ceil((self.bounds.size.width - offsetX - contentSizeX + DistanceX) / actualItemDisW);
    
    BOOL isColumnMajor = self.isColumnMajor;
    
    NSUInteger itemsNum = ((isColumnMajor)?(ColumnItemNum+2) * RowItemNum :(RowItemNum+2) * ColumnItemNum);
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    
    UIView* newItem;
    itemData = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    NSUInteger counter = 0;
    for (UIView *subView in itemArray) {
        subView.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        [tempArray addObject:subView];
        [itemData addObject:[NSNumber numberWithInt:-1]];
        
        counter++;
        
        if (counter >= itemsNum) {
            break;
        }
    }
    
    while (counter < itemsNum) {
        newItem = [self.controlDelegate onIPaListScrollViewNewItem:self withItemIndex:counter];
        [self addSubview:newItem];
        
        newItem.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        
        [tempArray addObject:newItem];
        [itemData addObject:[NSNumber numberWithInt:-1]];
        counter++;
    }
    
    
    itemArray = [[NSArray alloc] initWithArray:tempArray];
    
    
    
}
-(void)setControlDelegate:(id<IPaListScrollViewDelegate>)controlDelegate
{
    
    if (_controlDelegate != nil) {
        _controlDelegate = controlDelegate;
        [self RefreshItemViews];
        return;
    }
    _controlDelegate = controlDelegate;
    _lastCurrentPage = 0;
    self.delegate = self;
    
    workingScrollingAnim = NONE_ANIM;
    
    float itemWidth = [controlDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [controlDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    CGFloat contentSizeX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetX:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetX:self]:0;
    CGFloat contentSizeY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetY:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetY:self]:0;
    
    RowItemNum = ceil((self.bounds.size.height - offsetY - contentSizeY) / actualItemDisH);
    ColumnItemNum = ceil((self.bounds.size.width - offsetX - contentSizeX) / actualItemDisW);
    
    
    BOOL isColumnMajor = self.isColumnMajor;
    // NSUInteger itemsNum = ((isColumnMajor)?(columnNum+2) * rowNum :(rowNum+2) * columnNum);
    NSUInteger itemsNum = ((isColumnMajor)?(ColumnItemNum+2) * RowItemNum :(RowItemNum+2) * ColumnItemNum);
    NSUInteger allItemsNum = [controlDelegate IPaListScrollViewTotalItemsNum:self];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    
    
    BOOL isLoop = self.isLoop;
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    [self _RefreshContentSize:totalColumnItemNum
              totalRowItemNum:totalRowItemNum
               actualItemDisW:actualItemDisW
               actualItemDisH:actualItemDisH
                      offsetX:offsetX
                      offsetY:offsetY
                    DistanceX:DistanceX
                    DistanceY:DistanceY
                       isLoop:isLoop
                isColumnMajor:isColumnMajor];
    
    UIView* newItem;
    
    
    [self _ScrollingDoLoopConfigure:totalColumnItemNum
                    totalRowItemNum:totalRowItemNum
                     actualItemDisW:actualItemDisW
                     actualItemDisH:actualItemDisH
                            offsetX:offsetX
                            offsetY:offsetY
                             isLoop:isLoop
                      isColumnMajor:isColumnMajor];
    
    
    //refresh content size
    
    itemData = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    for (int idx = 0; idx < itemsNum; idx++) {
        
        newItem = [controlDelegate onIPaListScrollViewNewItem:self withItemIndex:idx];
        [self addSubview:newItem];
        
        newItem.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        
        [tempArray addObject:newItem];
        [itemData addObject:[NSNumber numberWithInt:-1]];
    }
    
    
    
    itemArray = [[NSArray alloc] initWithArray:tempArray];
    
    
    [self RefreshScrollView];
}
-(void)ReloadContent
{
    if (self.controlDelegate == nil) {
        return;
    }
    NSInteger itemNum = itemData.count;
    [itemData removeAllObjects];
    
    for (int idx = 0; idx < itemNum; idx++) {
        [itemData addObject:[NSNumber numberWithInt:-1]];
    }
    [self RefreshContentSize];
    [self RefreshScrollView];
}
-(UIView*) getItemWithIndex:(NSInteger)index

{
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    BOOL isLoop = self.isLoop;
    NSInteger firstItem;
    NSInteger firstRealItem;
    
    [self getFirstItemIndexWithCurrentPage:currentPage isColumnMajor:isColumnMajor allItemsNum:allItemsNum actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH isLoop:isLoop FirstItem:&firstItem FirstRealItem:&firstRealItem];
    
    
    NSUInteger itemsNum = [itemArray count];
    if (index < firstItem) {
        if (isLoop) {
            
            //if all item number is more than item number left in list,then there is loop item need to present
            
            NSInteger temp = allItemsNum - firstItem;
            if (itemsNum > temp) {
                temp = index + temp + firstRealItem;
                if (temp >= itemsNum) {
                    temp -= itemsNum;
                }
                
                return (temp >= itemsNum)?nil:[itemArray objectAtIndex:temp];
            }
        }
        
        return nil;
        
    }
    else if (index >= firstItem + itemsNum) {
        
        return nil;
    }
    else
    {
        NSInteger temp = index - firstItem + firstRealItem;
        if (temp >= itemsNum) {
            temp -= itemsNum;
        }
        
        return [itemArray objectAtIndex:temp];
        
    }
    return nil;
    
}
-(void) scrollToItemWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    if (index >= allItemsNum ) {
        return;
    }
    
    BOOL isColumnMajor = self.isColumnMajor;
    
    
    NSUInteger locatePage = index / ((isColumnMajor)?RowItemNum:ColumnItemNum);
    NSUInteger offset = ((isColumnMajor)?ColumnItemNum:RowItemNum);
    
    
    NSUInteger currentPage = [self getCurrentPage];
    
    
    if (currentPage < locatePage) {
        if (locatePage - currentPage < offset) {
            //it's already presented ,no need to scroll
            return;
        }
        [self setPage:locatePage animated:animated];
    }
    else if (currentPage >= locatePage) {
        NSUInteger gotoPage = MAX(0, ((NSInteger)locatePage - (NSInteger)offset + 1));
        [self setPage:gotoPage animated:animated];
    }
}
-(void) setPage:(NSInteger)page
{
    [self setPage:page animated:NO];
}
-(void) setPage:(NSInteger)page animated:(BOOL)animated
{
    
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    
    {
        NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                       actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
        if (!self.isLoop) {
            if (page < 0) {
                do {
                    page += allItemsNum;
                } while (page < 0);
            }
            else {
                if (allItemsNum > 0) {
                    page = page %allItemsNum;
                }
                
            }
            
            if (currentPage < 0) {
                NSInteger temp = currentPage;
                NSInteger counter = 1;
                if (allItemsNum > 0) {
                    do {
                        temp += allItemsNum;
                        counter++;
                    } while (temp < 0);
                    
                }
                else {
                    temp = 0;
                    currentPage = 0;
                }
                
                page = currentPage + page - temp;
            }
            else {
                
                NSInteger temp = (allItemsNum > 0)? currentPage % allItemsNum:currentPage;
                page = currentPage + page - temp;
            }
        }
        
    }
    if (animated) {
        workingScrollingAnim = SET_PAGE_ANIM;
    }
    if (isColumnMajor) {
        CGFloat targetPos = page * actualItemDisW + offsetX;
        [self setContentOffset:CGPointMake(targetPos, self.contentOffset.y) animated:animated];
        
    }
    else {
        CGFloat targetPos = page * actualItemDisH + offsetY;
        [self setContentOffset:CGPointMake( self.contentOffset.x,targetPos) animated:animated];
    }
    
    
}


-(void)_DoEndScrollingStuff:(CGFloat)actualItemDisW
             actualItemDisH:(CGFloat)actualItemDisH
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
                  DistanceX:(CGFloat)DistanceX
                  DistanceY:(CGFloat)DistanceY
              isColumnMajor:(BOOL)isColumnMajor;
{
    
    BOOL isPaging = [self.controlDelegate respondsToSelector:@selector(isIPaListScrollViewUseItemPaging:)]?
    [self.controlDelegate isIPaListScrollViewUseItemPaging:self]:NO;
    if (!isPaging) {
        if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewStopOnItemPage:withPage:)]) {
            //we need to recompute page for callback
            
            NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                           actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
            //we need to transform current page to normal page,because when turn loop mode
            //page number may look strange
            NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
            
            NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
            NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
            
            while (currentPage < 0) {
                currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
            }
            currentPage =  currentPage % ((isColumnMajor)?totalColumnItemNum:totalRowItemNum);
            [self.controlDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];
        }
        return;
    }
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    NSInteger targetPage = currentPage;
    
    
    
    
    workingScrollingAnim = END_SCROLL_TO_PAGE_ANIM;
    //set page at the end,if there is a page edited in callback,then the code below will not work
    //(UIKit can only do one animation at the same time)
    if (isColumnMajor) {
        CGFloat targetPos = targetPage * actualItemDisW;
        [self setContentOffset:CGPointMake(targetPos, self.contentOffset.y) animated:YES];
        
    }
    else {
        CGFloat targetPos = targetPage * actualItemDisH;
        [self setContentOffset:CGPointMake( self.contentOffset.x,targetPos) animated:YES];
    }
    
    
}
-(void)DoEndScrollingStuff
{
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    
    
    [self _DoEndScrollingStuff:actualItemDisW
                actualItemDisH:actualItemDisH
                       offsetX:offsetX
                       offsetY:offsetY
                     DistanceX:DistanceX
                     DistanceY:DistanceY
                 isColumnMajor:isColumnMajor];
}
//when turn on loop mode,every time you stop ,it will scroll to middle part of uiscrollview (no animation)
-(void)_ScrollingDoLoopConfigure:(NSUInteger)totalColumnItemNum
                 totalRowItemNum:(NSUInteger)totalRowItemNum
                  actualItemDisW:(CGFloat)actualItemDisW
                  actualItemDisH:(CGFloat)actualItemDisH
                         offsetX:(CGFloat)offsetX
                         offsetY:(CGFloat)offsetY

                          isLoop:(BOOL)isLoop
                   isColumnMajor:(BOOL)isColumnMajor
{
    if (!isLoop) {
        return;
    }
    
    CGFloat width = totalColumnItemNum * actualItemDisW ;//  - DistanceX;
    CGFloat height = totalRowItemNum * actualItemDisH ;//  - DistanceY;
    
    
    if (isColumnMajor) {
        if (width > 0) {
            CGFloat checkPos = self.contentSize.width / 2;
            CGFloat currentPos = self.contentOffset.x;
            
            if (currentPos < checkPos) {
                
                do {
                    currentPos += width;
                } while (currentPos < checkPos);
                currentPos -= width;
                
                self.contentOffset = CGPointMake(currentPos, self.contentOffset.y);
            }
            else if (currentPos > checkPos)
            {
                do {
                    currentPos -= width;
                } while (currentPos > checkPos);
                currentPos += width;
                self.contentOffset = CGPointMake(currentPos, self.contentOffset.y);
            }
            
            
        }
        
    }
    else {
        if (height > 0) {
            CGFloat checkPos = self.contentSize.height / 2;
            CGFloat currentPos = self.contentOffset.y;
            
            if (currentPos < checkPos) {
                
                do {
                    currentPos += height;
                } while (currentPos < checkPos);
                currentPos -= height;
                self.contentOffset = CGPointMake(self.contentOffset.x,currentPos);
            }
            else if (currentPos > checkPos)
            {
                do {
                    currentPos -= height;
                } while (currentPos > checkPos);
                currentPos += height;
                
                self.contentOffset = CGPointMake(self.contentOffset.x,currentPos);
            }
            
        }
        
    }
}
-(void)ScrollingDoLoopConfigure
{
    
    BOOL isColumnMajor = self.isColumnMajor;
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    BOOL isLoop = self.isLoop;
    [self _ScrollingDoLoopConfigure:totalColumnItemNum
                    totalRowItemNum:totalRowItemNum
                     actualItemDisW:actualItemDisW
                     actualItemDisH:actualItemDisH
                            offsetX:offsetX
                            offsetY:offsetY
                             isLoop:isLoop
                      isColumnMajor:isColumnMajor];
}


-(void)_RefreshContentSize:(NSUInteger)totalColumnItemNum
           totalRowItemNum:(NSUInteger)totalRowItemNum
            actualItemDisW:(CGFloat)actualItemDisW
            actualItemDisH:(CGFloat)actualItemDisH
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
                 DistanceX:(CGFloat)DistanceX
                 DistanceY:(CGFloat)DistanceY
                    isLoop:(BOOL)isLoop
             isColumnMajor:(BOOL)isColumnMajor
{
    CGFloat contentSizeX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetX:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetX:self]:0;
    CGFloat contentSizeY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetY:)]?
    [self.controlDelegate IPaListScrollViewSizeOffsetY:self]:0;
    if (isLoop) {
        
        CGFloat width = totalColumnItemNum * actualItemDisW + offsetX - DistanceX;
        
        CGFloat height = totalRowItemNum * actualItemDisH + offsetY - DistanceY;
        
        if (isColumnMajor) {
            CGFloat needScrollSize = width * self.LoopSizeRatio;
            if (width > 0) {
                CGFloat size = width;
                
                
                while (width < needScrollSize)
                {
                    width += size;
                }
            }
            else {
                width = needScrollSize;
            }
            
        }
        else {
            CGFloat needScrollSize = height * self.LoopSizeRatio;
            if (height > 0) {
                CGFloat size = height;
                
                while (height < needScrollSize)
                {
                    height += size;
                }
                
            }
            else {
                height = needScrollSize;
            }
        }
        
        
        
        
        [self setContentSize:CGSizeMake(width + contentSizeX,height + contentSizeY)];
    }
    else {
        [self setContentSize:CGSizeMake(totalColumnItemNum * actualItemDisW + offsetX - DistanceX + contentSizeX, totalRowItemNum * actualItemDisH + offsetY - DistanceY + contentSizeY)];
        
    }
    
}
-(void)RefreshContentSize
{
    BOOL isColumnMajor = self.isColumnMajor;
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    BOOL isLoop = self.isLoop;
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    
    [self _RefreshContentSize:totalColumnItemNum
              totalRowItemNum:totalRowItemNum
               actualItemDisW:actualItemDisW
               actualItemDisH:actualItemDisH
                      offsetX:offsetX
                      offsetY:offsetY
                    DistanceX:DistanceX
                    DistanceY:DistanceY
                       isLoop:isLoop
                isColumnMajor:isColumnMajor];
}
-(NSInteger) _getCurrentPage:(BOOL)isColumnMajor
              actualItemDisW:(CGFloat)actualItemDisW
              actualItemDisH:(CGFloat)actualItemDisH
{
    self.lastCurrentPage = (isColumnMajor)?floor((self.contentOffset.x - actualItemDisW / 2) / actualItemDisW) + 1:
    floor((self.contentOffset.y -  actualItemDisH / 2) / actualItemDisH) + 1;
    return self.lastCurrentPage;
}
-(NSInteger) getCurrentPage
{
    BOOL isColumnMajor = self.isColumnMajor;
    CGFloat itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    CGFloat itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    
    NSUInteger totalRowItemNum = MAX(1, (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum));
    NSUInteger totalColumnItemNum = MAX(1, (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum);
    
    while (currentPage < 0) {
        currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
    }
    
    return currentPage % ((isColumnMajor)?totalColumnItemNum:totalRowItemNum);
    
    
    
    
}
-(void)ResetItemTransform
{
    for (UIView *Item in itemArray) {
        Item.transform = CGAffineTransformIdentity;
    }
}
-(BOOL)_checkPointIsFront:(CGPoint)a beforePoint:(CGPoint)b withIsColumnMajor:(BOOL)isColumnMajor
{
    
    return (isColumnMajor)?((a.x < b.x) || (a.x == b.x && a.y < b.y)):((a.y < b.y) || (a.y == b.y && a.x < b.x));
}

//get index of first visible item
-(void)getFirstItemIndexWithCurrentPage:(NSInteger)currentPage
                          isColumnMajor:(BOOL)isColumnMajor
                            allItemsNum:(NSUInteger)allItemsNum
                         actualItemDisW:(CGFloat)actualItemDisW
                         actualItemDisH:(CGFloat)actualItemDisH
                                 isLoop:(BOOL)isLoop
                              FirstItem:(NSInteger*)FirstItem
                          FirstRealItem:(NSInteger*)FirstRealItem;

{
    
    CGFloat startPos = (isColumnMajor)?currentPage * actualItemDisW - actualItemDisW:
    currentPage * actualItemDisH - actualItemDisH;
    
    if (!isLoop && startPos < 0) {
        *FirstItem = 0;
        *FirstRealItem = 0;
        return;
    }
    NSInteger itemIndex = 0;
    
    NSInteger temp = (isColumnMajor)?RowItemNum:ColumnItemNum;
    
    //first item of actual item,last page of current page
    if (allItemsNum > 0) {
        itemIndex = (currentPage-1) * temp;
        while (itemIndex < 0) {
            itemIndex += allItemsNum;
        }
        itemIndex = itemIndex % allItemsNum;
    }
    
    *FirstItem = itemIndex;
    NSUInteger itemsNum = [itemArray count];
    NSInteger realItemIndex = 0;
    if (itemsNum > 0) {
        realItemIndex = (currentPage*temp % itemsNum - temp);
        while (realItemIndex < 0) {
            realItemIndex = itemsNum+ realItemIndex;
        }
        
        
    }
    *FirstRealItem = realItemIndex;
    
}
-(void)_RefreshItem:(UIView*)item
      withItemIndex:(NSInteger)itemIndex
     withAllItemNum:(NSUInteger)allItemsNum
         withIsLoop:(BOOL)isLoop
       withStartPos:(CGFloat)startPos
    withCurrentItem:(NSInteger)currentItem
     withItemCenter:(CGPoint)itemCenter
  withIsColumnMajor:(BOOL)isColumnMajor
            offsetX:(CGFloat)offsetX
            offsetY:(CGFloat)offsetY
     actualItemDisW:(CGFloat)actualItemDisW
     actualItemDisH:(CGFloat)actualItemDisH

{
    [item setHidden:(!isLoop && ((itemIndex >= allItemsNum) || (startPos < 0)))];
    
    
    if (itemIndex != [[itemData objectAtIndex:currentItem] intValue]) {
        CGPoint center = CGPointApplyAffineTransform(itemCenter, (isColumnMajor)?CGAffineTransformMakeTranslation(startPos+offsetX,itemIndex%RowItemNum * actualItemDisH+offsetY):
                                                     CGAffineTransformMakeTranslation(itemIndex%ColumnItemNum * actualItemDisW + offsetX,startPos + offsetY));
        [item setCenter:center];
        [itemData removeObjectAtIndex:currentItem];
        [itemData insertObject:[NSNumber numberWithInteger:itemIndex] atIndex:currentItem];
        if (itemIndex < allItemsNum) {
            [self.controlDelegate configureIPaListScrollView:self withItem:item withIdx:itemIndex];
        }
    }
    else if (isLoop)
    {
        //if loop is turn on, we need to update position infomation everytime
        CGPoint center = CGPointApplyAffineTransform(itemCenter, (isColumnMajor)?CGAffineTransformMakeTranslation(startPos + offsetX,itemIndex%RowItemNum * actualItemDisH + offsetY):
                                                     CGAffineTransformMakeTranslation(itemIndex%ColumnItemNum * actualItemDisW + offsetX,startPos + offsetY));
        [item setCenter:center];
        
    }
    
}
-(void)RefreshScrollView
{
    BOOL isColumnMajor = self.isColumnMajor;
    NSUInteger itemsNum = [itemArray count];
    NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
    CGFloat itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
    CGFloat itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.controlDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;
    BOOL isLoop = self.isLoop;
    
    [self ScrollingDoLoopConfigure];
    
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    CGFloat startPos = (isColumnMajor)?currentPage * actualItemDisW - actualItemDisW:
    currentPage * actualItemDisH - actualItemDisH;
    if (!isLoop && startPos < 0) {
        startPos = 0;
    }
    
    
    //current item we r going to edit position
    NSInteger currentItem;
    //actual index of current edit item
    NSInteger itemIndex;
    
    [self getFirstItemIndexWithCurrentPage:currentPage isColumnMajor:isColumnMajor allItemsNum:allItemsNum actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH isLoop:isLoop FirstItem:&itemIndex FirstRealItem:&currentItem];
    
    
    CGPoint itemCenter = CGPointMake(itemWidth / 2, itemHeight / 2);
    
    
    
    for (NSInteger idx = 0; idx < itemsNum; idx++) {
        if (currentItem >= itemsNum ) {
            currentItem = 0;
        }
        UIView *item = [itemArray objectAtIndex:currentItem];
        
        if (idx > 0 && (idx % ((isColumnMajor)?RowItemNum:ColumnItemNum) == 0)) {
            startPos += ((isColumnMajor)?actualItemDisW:actualItemDisH);
        }
        if (isLoop && (itemIndex >= allItemsNum))
        {
            itemIndex = 0;
        }
        
        [self _RefreshItem:item
             withItemIndex:itemIndex
            withAllItemNum:allItemsNum
                withIsLoop:isLoop
              withStartPos:startPos
           withCurrentItem:currentItem
            withItemCenter:itemCenter
         withIsColumnMajor:isColumnMajor
                   offsetX:offsetX
                   offsetY:offsetY
            actualItemDisW:actualItemDisW
            actualItemDisH:actualItemDisH];
        item.transform = CGAffineTransformIdentity;
        
        itemIndex++;
        currentItem++;
    }
}

-(void)goNextPage
{
    BOOL isLoop = self.isLoop;    //    NSInteger currentPage = [self getCurrentPage];
    NSInteger currentPage = self.lastCurrentPage;
    if (isLoop) {
        [self setPage:currentPage + 1 animated:YES];
    }
    else {
        
        BOOL isColumnMajor = self.isColumnMajor;
        
        NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
        
        NSUInteger maxPageNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum) - ColumnItemNum:ceil((float)allItemsNum / ColumnItemNum) - RowItemNum;
        
        
        if (currentPage + 1 <= maxPageNum) {
            [self setPage:currentPage + 1 animated:YES];
        }
        
        
    }
    
}
-(void)backLastPage
{
    BOOL isLoop = self.isLoop;    //NSInteger currentPage = [self getCurrentPage];
    NSInteger currentPage = self.lastCurrentPage;
    if (isLoop || (currentPage > 0)) {
        [self setPage:currentPage - 1 animated:YES];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewWillBeginDragging:)]) {
        [self.controlDelegate IPaListScrollViewWillBeginDragging:self];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self RefreshScrollView];
    if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewDidScroll:)]) {
        [self.controlDelegate IPaListScrollViewDidScroll:self];
    }
    if (self.backgroundImg != nil) {
        [self setNeedsDisplay];
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self DoEndScrollingStuff];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self DoEndScrollingStuff];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    switch (workingScrollingAnim) {
        case SET_PAGE_ANIM:
            if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewDidSetPageAnim:)]) {
                [self.controlDelegate IPaListScrollViewDidSetPageAnim:self];
            }
            
            break;
        case END_SCROLL_TO_PAGE_ANIM:
        {
            
        }
        default:
            break;
    }
    if ([self.controlDelegate respondsToSelector:@selector(IPaListScrollViewStopOnItemPage:withPage:)]) {
        
        BOOL isColumnMajor = self.isColumnMajor;
        float itemWidth = [self.controlDelegate IPaListScrollViewItemWidth:self];
        float itemHeight = [self.controlDelegate IPaListScrollViewItemHeight:self];
        
        
        CGFloat DistanceX = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
        [self.controlDelegate IPaListScrollViewItemDistanceX:self]:0;
        CGFloat DistanceY = [self.controlDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
        [self.controlDelegate IPaListScrollViewItemDistanceY:self]:0;
        
        CGFloat actualItemDisW = DistanceX + itemWidth;
        CGFloat actualItemDisH = DistanceY + itemHeight;
        
        NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                       actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
        
        
        NSUInteger allItemsNum = [self.controlDelegate IPaListScrollViewTotalItemsNum:self];
        
        
        NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
        NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
        
        while (currentPage < 0) {
            currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
        }
        if (isColumnMajor) {
            if (totalColumnItemNum > 0) {
                currentPage = currentPage % totalColumnItemNum;
                [self.controlDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];
            }
            else {
                currentPage = 0;
            }
        }
        else {
            if (totalRowItemNum > 0) {
                currentPage = currentPage % totalRowItemNum;
                [self.controlDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];
            }
            else {
                currentPage = 0;
            }
        }
    }
    workingScrollingAnim = NONE_ANIM;
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return ([self.controlDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])?[self.controlDelegate viewForZoomingInScrollView:self]:nil;
}
@end
