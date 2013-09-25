//
//  IPaViewController.m
//  IPaPTRTableViewControllerSample
//
//  Created by IPaPa on 13/9/5.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface IPaViewController ()

@end

@implementation IPaViewController
{
    NSMutableArray *items;
    UIImageView *refreshArrow;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    items = [@[] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addItem {
    // Add a new time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    [items insertObject:[NSString stringWithFormat:@"%@", now] atIndex:0];
    
    [self.tableView reloadData];
    
    [self endRefreshing];
}
#pragma mark - IPaPTRTableViewController
- (void)doRefresh
{
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

// ** createRefreshingHeaderView
//overwrite this function to create your own refreshing header view when subclass this class
-(void)createRefreshingHeaderView
{
    [super createRefreshingHeaderView];
    
    if (refreshArrow == nil) {
        refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
        refreshArrow.frame = CGRectMake(floorf((refreshingHeaderView.frame.size.height - 27) / 2),(floorf(refreshingHeaderView.frame.size.height - 44) / 2),27, 44);
        [refreshingHeaderView addSubview:refreshArrow];
    }


}

-(void)configReleaseRefreshingHeaderView
{
    [super configReleaseRefreshingHeaderView];
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
}

-(void)configPullRefreshingHeaderView
{
    [super configPullRefreshingHeaderView];
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    refreshArrow.hidden = NO;
}

-(void)configLoadingRefreshingHeaderView
{
    [super configLoadingRefreshingHeaderView];
    refreshArrow.hidden = YES;
}

-(void)configLoadingDoneRefreshingHeaderView
{
    [super configLoadingDoneRefreshingHeaderView];
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
}
/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return 0;
 }*/
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
@end
