//
//  IPaPTRTableController.m
//  IPaPTRTableViewController
//
//  Created by IPa Chen on 2015/5/30.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import "IPaPTRTableController.h"
@interface IPaPTRTableController()
@property (nonatomic,readwrite) BOOL isRefreshing;
@end
@implementation IPaPTRTableController
{
    BOOL isDragging;
    UIView *refreshingHeaderView;
}
- (id)initWithTableView:(UITableView*)tableView delegate:(id <IPaPTRTableControllerDelegate>)delegate
{
    self = [super init];
    self.tableView = tableView;
    self.delegate = delegate;
    
    refreshingHeaderView = [self.delegate headerViewForIPaPTRTableController:self];
    CGFloat height = CGRectGetHeight(refreshingHeaderView.bounds);
    
    refreshingHeaderView.frame = (CGRect){
        .origin = CGPointMake(0, -height),
        .size = CGSizeMake(CGRectGetWidth(self.tableView.frame),height),
    };
    
    
    [self.tableView addSubview:refreshingHeaderView];
    
    return self;
}
-(CGFloat)refreshingHeaderHeight
{
    return CGRectGetHeight(refreshingHeaderView.frame);
}
- (void)startRefreshing
{
    // Released above the header
    self.isRefreshing = YES;
    [self.delegate tableController:self willLoadingHeaderView:refreshingHeaderView];
    
    [self.delegate onRefreshingWithIPaPTRTableController:self];

}
- (void)endRefreshing
{
    self.isRefreshing = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        [self.delegate tableController:self didLoadingDoneHeaderView:refreshingHeaderView];
    } completion:^(BOOL finished) {
        [self.delegate tableController:self willPullHeaderView:refreshingHeaderView];

    }];
}

-(void)configLoadingRefreshingHeaderView
{
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.refreshingHeaderHeight, 0, 0, 0);
        [self.delegate tableController:self willLoadingHeaderView:refreshingHeaderView];
    }];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isRefreshing)
        return;
    isDragging = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRefreshing) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (self.tableView.contentOffset.y >= -self.refreshingHeaderHeight)
            self.tableView.contentInset = UIEdgeInsetsMake(-self.tableView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -self.refreshingHeaderHeight) {
                // User is scrolling above the header
                [self.delegate tableController:self willReleaseHeaderView:refreshingHeaderView];
            } else {
                // User is scrolling somewhere within the header
                [self.delegate tableController:self willPullHeaderView:refreshingHeaderView];

            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (self.isRefreshing) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -self.refreshingHeaderHeight) {
        [self startRefreshing];

    }
}
@end
