//
//  IPaCollectionViewPageController.m
//  IPaCollectionViewPageController
//
//  Created by IPa Chen on 2015/4/2.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//


#import "IPaCollectionViewPageController.h"

@interface IPaCollectionViewPageController() 
@end
@implementation IPaCollectionViewPageController
{
    NSInteger totalPageNum;
    NSInteger currentPage;
    NSInteger currentLoadingPage;
    NSMutableArray *datas;
}
- (instancetype)init
{
    self = [super init];
    totalPageNum = 1;
    currentPage = 0;
    currentLoadingPage = -1;
    datas = [@[] mutableCopy];
    return self;
}
-(id)dataWithIndex:(NSUInteger)index
{
    return (index < [datas count])?datas[index]:nil;
}
-(void)reloadAllData
{
    totalPageNum = 1;
    currentPage = 0;
    currentLoadingPage = -1;
    datas = [@[] mutableCopy];
    [[self.delegate collectionViewForPageController:self] reloadData];
}
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath
{
    return (indexPath.row == datas.count);
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (currentPage == totalPageNum) {
        return datas.count;
    }
    return datas.count + 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if (indexPath.row == datas.count) {
        cell = [self.delegate pageController:self createLoadingCellWithIndex:indexPath];
        
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            
            [self.delegate pageController:self loadDataWithPage:currentLoadingPage callback:^(NSArray* newDatas,NSUInteger totalPage){
                totalPageNum = totalPage;
                currentPage = currentLoadingPage;
                currentLoadingPage = -1;
                
                UICollectionView *collectionView = [self.delegate collectionViewForPageController:self];

                [collectionView performBatchUpdates:^(){
                    NSMutableArray *indexList = [@[] mutableCopy];
                    NSUInteger startRow = datas.count;
                    for (NSInteger idx = 0; idx < newDatas.count; idx++) {
                        [indexList addObject:[NSIndexPath indexPathForRow:startRow + idx inSection:0]];

                        
                    }
                    [datas addObjectsFromArray:newDatas];
                    [collectionView insertItemsAtIndexPaths:indexList];
                    if (currentPage == totalPageNum) {
                        [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:startRow inSection:0]]];
                    }
                }completion:^(BOOL finished){
                    
                }];
            }];
            
        }
        [self.delegate pageController:self configureLoadingCell:cell withIndexPath:indexPath];
    }
    
    else {
        cell = [self.delegate pageController:self createDataCellWithIndex:indexPath];
        [self.delegate pageController:self configureCell:cell withIndexPath:indexPath withData:datas[indexPath.row]];
    }
    return cell;
}


@end