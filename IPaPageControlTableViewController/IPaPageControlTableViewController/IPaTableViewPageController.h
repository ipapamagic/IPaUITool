//
//  IPaTableViewPageController.h
//  IPaPageControlTableViewController
//
//  Created by IPa Chen on 2015/3/3.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@protocol IPaTableViewPageControllerDelegate;
@interface IPaTableViewPageController : NSObject
-(id)dataWithIndex:(NSUInteger)index;
-(void)reloadAllData;
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath;
@property (nonatomic,weak) IBOutlet id <IPaTableViewPageControllerDelegate> delegate;
@end
@protocol IPaTableViewPageControllerDelegate <NSObject>

- (UITableView*)tableViewForPageController:(IPaTableViewPageController*)pageController;
-(UITableViewCell*)pageController:(IPaTableViewPageController*)pageController createLoadingCellWithIndex:(NSIndexPath*)indexPath;
-(UITableViewCell*)pageController:(IPaTableViewPageController*)pageController createDataCellWithIndex:(NSIndexPath*)indexPath;
-(void)pageController:(IPaTableViewPageController*)pageController  loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback;
-(void)pageController:(IPaTableViewPageController*)pageController  configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withData:(id)data;

-(void)pageController:(IPaTableViewPageController*)pageController  configureLoadingCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath;



@end
