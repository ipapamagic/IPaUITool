//
//  IPaPTRTableController.h
//  IPaPTRTableViewController
//
//  Created by IPa Chen on 2015/5/30.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@protocol IPaPTRTableControllerDelegate;
@interface IPaPTRTableController : NSObject
@property (nonatomic,weak) id <IPaPTRTableControllerDelegate> delegate;
@property (nonatomic,readonly) BOOL isRefreshing;
@property (nonatomic,weak) UITableView* tableView;
- (id)initWithTableView:(UITableView*)tableView delegate:(id <IPaPTRTableControllerDelegate>)delegate;
- (void)startRefreshing;
- (void)endRefreshing;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
@end

@protocol IPaPTRTableControllerDelegate <NSObject>

- (UIView*)headerViewForIPaPTRTableController:(IPaPTRTableController*)controller;
- (void)onRefreshingWithIPaPTRTableController:(IPaPTRTableController*)controller;

-(void)tableController:(IPaPTRTableController*)controller  willReleaseHeaderView:(UIView*)headerView;

-(void)tableController:(IPaPTRTableController*)controller  willPullHeaderView:(UIView*)headerView;

-(void)tableController:(IPaPTRTableController*)controller  willLoadingHeaderView:(UIView*)headerView;

-(void)tableController:(IPaPTRTableController*)controller  didLoadingDoneHeaderView:(UIView*)headerView;
@end
