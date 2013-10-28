//
//  IPaPageControlTableViewController.h
//  IPaPageControlTableViewController
//
//  Created by IPaPa on 13/9/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaPageControlTableViewController : UITableViewController
{

}
-(id)dataWithIndex:(NSUInteger)index;
#pragma mark - should be overwrite
-(UITableViewCell*)createLoadingCellWithIndex:(NSIndexPath*)indexPath;
-(UITableViewCell*)createDataCellWithIndex:(NSIndexPath*)indexPath;
-(void)loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback;
-(void)configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withData:(id)data;

-(void)configureLoadingCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath;
-(void)reloadAllData;
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath;
@end
