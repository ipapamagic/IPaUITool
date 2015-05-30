//
//  IPaPTRTableViewController.m
//  IPaPTRTableViewController
//
//  Created by IPaPa on 13/9/4.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import "IPaPTRTableViewController.h"
#import "IPaPTRTableController.h"

#define IPA_PTR_REFRESH_HEADER_HEIGHT 52.0f
#define IPA_PTR_RELEASE_TO_REFRESH @"Release to refresh..."
#define IPA_PTR_PULL_TO_REFRESH @"Pull down to refresh..."
#define IPA_PTR_LOADING @"Loading..."
@interface IPaPTRTableViewController() <IPaPTRTableControllerDelegate>
@end
@implementation IPaPTRTableViewController
{

    IPaPTRTableController *tableController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    tableController = [[IPaPTRTableController alloc] initWithTableView:self.tableView delegate:self];
}

// ** doRefresh
//overwrite this function to do your refresh function when subclass this class
- (void)doRefresh
{
    
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [tableController scrollViewWillBeginDragging];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [tableController scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [tableController scrollViewDidEndDragging];
}
#pragma mark - IPaPTRTableControllerDelegate <NSObject>

- (UIView*)headerViewForIPaPTRTableController:(IPaPTRTableController*)controller
{
    UIView *refreshingHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, IPA_PTR_REFRESH_HEADER_HEIGHT)];
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
    return refreshingHeaderView;
}
- (void)onRefreshingWithIPaPTRTableController:(IPaPTRTableController*)controller
{
    
}

-(void)tableController:(IPaPTRTableController*)controller  willReleaseHeaderView:(UIView*)headerView
{
    UILabel *refreshLabel = (UILabel*)[headerView viewWithTag:1];
    refreshLabel.text = IPA_PTR_RELEASE_TO_REFRESH;

}

-(void)tableController:(IPaPTRTableController*)controller  willPullHeaderView:(UIView*)headerView
{
    UILabel *refreshLabel = (UILabel*)[headerView viewWithTag:1];
    refreshLabel.text = IPA_PTR_PULL_TO_REFRESH;
    //    UIImageView *refreshArrow = (UIImageView*)[refreshingHeaderView viewWithTag:2];
    //    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    UIActivityIndicatorView *refreshSpinner = (UIActivityIndicatorView *)[headerView viewWithTag:3];
    [refreshSpinner stopAnimating];
}

-(void)tableController:(IPaPTRTableController*)controller  willLoadingHeaderView:(UIView*)headerView
{
    UILabel *refreshLabel = (UILabel*)[headerView viewWithTag:1];
    refreshLabel.text = IPA_PTR_LOADING;
    //        refreshArrow.hidden = YES;
    
    UIActivityIndicatorView *refreshSpinner = (UIActivityIndicatorView *)[headerView viewWithTag:3];
    [refreshSpinner startAnimating];
}

-(void)tableController:(IPaPTRTableController*)controller  didLoadingDoneHeaderView:(UIView*)headerView
{
    
}

@end
