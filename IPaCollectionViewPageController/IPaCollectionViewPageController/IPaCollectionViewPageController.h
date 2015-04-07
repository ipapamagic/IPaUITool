//
//  IPaCollectionViewPageController.h
//  IPaCollectionViewPageController
//
//  Created by IPa Chen on 2015/4/2.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@protocol IPaCollectionViewPageControllerDelegate;
@interface IPaCollectionViewPageController : NSObject <UICollectionViewDataSource>
-(id)dataWithIndex:(NSUInteger)index;
-(void)reloadAllData;
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath;
@property (nonatomic,weak) IBOutlet id <IPaCollectionViewPageControllerDelegate> delegate;
@end
@protocol IPaCollectionViewPageControllerDelegate <NSObject>

- (UICollectionView*)collectionViewForPageController:(IPaCollectionViewPageController*)pageController;
-(UICollectionViewCell*)pageController:(IPaCollectionViewPageController*)pageController createLoadingCellWithIndex:(NSIndexPath*)indexPath;
-(UICollectionViewCell*)pageController:(IPaCollectionViewPageController*)pageController createDataCellWithIndex:(NSIndexPath*)indexPath;
-(void)pageController:(IPaCollectionViewPageController*)pageController  loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback;
-(void)pageController:(IPaCollectionViewPageController*)pageController  configureCell:(UICollectionViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withData:(id)data;

-(void)pageController:(IPaCollectionViewPageController*)pageController  configureLoadingCell:(UICollectionViewCell*)cell withIndexPath:(NSIndexPath*)indexPath;



@end