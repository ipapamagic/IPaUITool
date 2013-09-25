//
//  IPaPTRTableViewController.h
//  IPaPTRTableViewController
//
//  Created by IPaPa on 13/9/4.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaPTRTableViewController : UITableViewController
{
    UIView *refreshingHeaderView;
}
@property (nonatomic,readonly) BOOL isRefreshing;
- (void)startRefreshing;
- (void)endRefreshing;

// ** doRefresh
//overwrite this function to do your refresh function when subclass this class
- (void)doRefresh;

// ** createRefreshingHeaderView
//overwrite this function to create your own refreshing header view when subclass this class
-(void)createRefreshingHeaderView;
// ** configReleaseRefreshingHeaderView
//overwrite this function to modify your own refreshing header view when release drag tableView
-(void)configReleaseRefreshingHeaderView;
// ** configPullRefreshingHeaderView
//overwrite this function to modify your own refreshing header view when Pull tableView
-(void)configPullRefreshingHeaderView;
// ** configLoadingRefreshingHeaderView
//overwrite this function to modify your own refreshing header view when Loading
-(void)configLoadingRefreshingHeaderView;
// ** configLoadingDoneRefreshingHeaderView
//overwrite this function to modify your own refreshing header view when Loading done
-(void)configLoadingDoneRefreshingHeaderView;

@end
