//
//  IPaPTRTableViewController.m
//  IPaPTRTableViewController
//
//  Created by IPaPa on 13/9/4.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import "IPaPTRTableViewController.h"
#define IPA_PTR_REFRESH_HEADER_HEIGHT 52.0f
#define IPA_PTR_RELEASE_TO_REFRESH @"Release to refresh..."
#define IPA_PTR_PULL_TO_REFRESH @"Pull down to refresh..."
#define IPA_PTR_LOADING @"Loading..."
@interface IPaPTRTableViewController()
@property (nonatomic,readwrite) BOOL isRefreshing;
@end
@implementation IPaPTRTableViewController
{

    BOOL isDragging;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createRefreshingHeaderView];
}


- (void)startRefreshing
{
    self.isRefreshing = YES;
    
    [self configLoadingRefreshingHeaderView];
    
    // Refresh action!
    [self doRefresh];
}
- (void)endRefreshing
{
    self.isRefreshing = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        [self configLoadingDoneRefreshingHeaderView];
    } completion:^(BOOL finished) {
        [self configPullRefreshingHeaderView];
    }];
}
-(CGFloat)refreshingHeaderHeight
{
    return refreshingHeaderView.frame.size.height;
}

// ** doRefresh
//overwrite this function to do your refresh function when subclass this class
- (void)doRefresh
{
    
}

#pragma mark - config RefreshingHeaderView
-(void)createRefreshingHeaderView
{
    refreshingHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - IPA_PTR_REFRESH_HEADER_HEIGHT, self.view.frame.size.width, IPA_PTR_REFRESH_HEADER_HEIGHT)];
    refreshingHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, IPA_PTR_REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.tag = 1;
//    UIImageView *refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
//    refreshArrow.frame = CGRectMake(floorf((IPA_PTR_REFRESH_HEADER_HEIGHT - 27) / 2),
//                                    (floorf(IPA_PTR_REFRESH_HEADER_HEIGHT - 44) / 2),
//                                    27, 44);
//    refreshArrow.tag = 2;
    UIActivityIndicatorView *refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(IPA_PTR_REFRESH_HEADER_HEIGHT - 20) / 2), floorf((IPA_PTR_REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    refreshSpinner.tag = 3;
    
    [refreshingHeaderView addSubview:refreshLabel];
//    [refreshingHeaderView addSubview:refreshArrow];
    [refreshingHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshingHeaderView];

}
-(void)configReleaseRefreshingHeaderView
{
    UILabel *refreshLabel = (UILabel*)[refreshingHeaderView viewWithTag:1];
    refreshLabel.text = IPA_PTR_RELEASE_TO_REFRESH;
//    UIImageView *refreshArrow = (UIImageView*)[refreshingHeaderView viewWithTag:2];
//    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    
}
// ** configPullRefreshingHeaderView
//overwrite this function to modify your own refreshing header view when Pull tableView
-(void)configPullRefreshingHeaderView
{
    UILabel *refreshLabel = (UILabel*)[refreshingHeaderView viewWithTag:1];
    refreshLabel.text = IPA_PTR_PULL_TO_REFRESH;
//    UIImageView *refreshArrow = (UIImageView*)[refreshingHeaderView viewWithTag:2];
//    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    UIActivityIndicatorView *refreshSpinner = (UIActivityIndicatorView *)[refreshingHeaderView viewWithTag:3];
    [refreshSpinner stopAnimating];
}

-(void)configLoadingRefreshingHeaderView
{
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(self.refreshingHeaderHeight, 0, 0, 0);
        UILabel *refreshLabel = (UILabel*)[refreshingHeaderView viewWithTag:1];
        refreshLabel.text = IPA_PTR_LOADING;
        //        refreshArrow.hidden = YES;
        
        UIActivityIndicatorView *refreshSpinner = (UIActivityIndicatorView *)[refreshingHeaderView viewWithTag:3];
        [refreshSpinner startAnimating];
    }];
}
-(void)configLoadingDoneRefreshingHeaderView
{
//            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isRefreshing) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isRefreshing) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -self.refreshingHeaderHeight)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -self.refreshingHeaderHeight) {
                // User is scrolling above the header
                [self configReleaseRefreshingHeaderView];
            } else {
                // User is scrolling somewhere within the header
                [self configPullRefreshingHeaderView];
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isRefreshing) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -self.refreshingHeaderHeight) {
        // Released above the header
        [self startRefreshing];
    }
}


@end
