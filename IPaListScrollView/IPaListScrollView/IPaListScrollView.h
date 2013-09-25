//
//  IPaListScrollView.h
//  IPaListScrollView
//
//  Created by IPaPa on 11/10/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//IPaListScrollView will be replace by UICollectionView in ios 6

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol IPaListScrollViewDelegate;
@interface IPaListScrollView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic,readonly) BOOL isColumnMajor;
//background image
@property (nonatomic,strong)  UIImage *backgroundImg;
//when you turn on loop function,I create a larger sceen for scrolling
//LoopScreenSizeRatio means how many multiples of current Scrren are there in actual screen size
-(NSUInteger) LoopSizeRatio;
-(BOOL) isLoop;
//current page need to compute,this is the last result of current page computed
@property (nonatomic,readonly) NSInteger lastCurrentPage;
@property (nonatomic,weak) id<IPaListScrollViewDelegate> controlDelegate;
//recompute all item position
-(void)RefreshScrollView;
//recompute content size
-(void)RefreshContentSize;
//reload all data,and then it will do RefreshScrollView and RefreshScrollView
-(void)ReloadContent;
//get current page (the index of first item )
-(NSInteger) getCurrentPage;
-(void) setPage:(NSInteger)page;
-(void) setPage:(NSInteger)page animated:(BOOL)animated;
//get item with index, if return nil ,then the Itme is not exist(maybe it's just not appear)
-(UIView*) getItemWithIndex:(NSInteger)index;
-(void) scrollToItemWithIndex:(NSUInteger)index animated:(BOOL)animated;
//go to next page,if the loop is not on,then it will stop on last page
-(void)goNextPage;
//back to last page,if the loop is not on,then it will stop on first page
-(void)backLastPage;
//refresh items that need to be created
-(void)RefreshItemViews;
@end


@protocol IPaListScrollViewDelegate <NSObject>

-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView;
//get item size
-(CGFloat) IPaListScrollViewItemHeight:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemWidth:(IPaListScrollView*)scrollView;

//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index;
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index;

@optional
//if item column major (up->down -> left->right) return no for row major(left->right -> up->down)
-(BOOL) isIPaListScrollViewColumnMajor:(IPaListScrollView*)scrollView;
//left-up corner offset
-(CGFloat) IPaListScrollViewItemOffsetX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemOffsetY:(IPaListScrollView*)scrollView;
//distance between items
-(CGFloat) IPaListScrollViewItemDistanceX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemDistanceY:(IPaListScrollView*)scrollView;
//if turn on loop,scroll to end ,then restart from first item
-(BOOL) isIPaListScrollViewLoopShow:(IPaListScrollView*)scrollView;
//when stop scroll ,scrollview will scroll to nearest item
-(BOOL) isIPaListScrollViewUseItemPaging:(IPaListScrollView*)scrollView;
//stop scrolling callback
-(void) IPaListScrollViewStopOnItemPage:(IPaListScrollView*)scrollView withPage:(NSInteger)page;
-(void) IPaListScrollViewDidScroll:(IPaListScrollView*)scrollView;
-(void) IPaListScrollViewDidSetPageAnim:(IPaListScrollView*)scrollView;
//if you need edit content size,used size offset to modify
-(CGFloat) IPaListScrollViewSizeOffsetX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewSizeOffsetY:(IPaListScrollView*)scrollView;

//begin dragging callback
-(void) IPaListScrollViewWillBeginDragging:(IPaListScrollView*)scrollView;
//scrollview zooming callback
-(UIView*)viewForZoomingInScrollView:(IPaListScrollView *)scrollView;
//background image size
-(CGSize)IPaListScrollViewBackgroundImgSize:(IPaListScrollView *)scrollView;
//with turn on loop mode,you can set the multiple of actual scroll view content size in visible view
//you need to set large content size to avoid stopping when scrolling
//default value is 5
-(NSUInteger)IPaListScrollViewLoopSizeRatio:(IPaListScrollView *)scrollView;
@end