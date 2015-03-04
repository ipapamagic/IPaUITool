//
//  IPaPageControlTableViewController.m
//  IPaPageControlTableViewController
//
//  Created by IPaPa on 13/9/25.
//  Copyright (c) 2013年 IPaPa. All rights reserved.
//

#import "IPaPageControlTableViewController.h"
#import "IPaTableViewPageController.h"
@interface IPaPageControlTableViewController () <IPaTableViewPageControllerDelegate>

@end

@implementation IPaPageControlTableViewController
{
    IPaTableViewPageController *pageController;

}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    pageController = [[IPaTableViewPageController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(id)dataWithIndex:(NSUInteger)index
{
    return [pageController dataWithIndex:index];

}
-(void)reloadAllData
{
    [pageController reloadAllData];
}
- (UITableView*)tableViewForPageController:(IPaTableViewPageController*)pageController
{
    return self.tableView;
}
-(UITableViewCell*)createLoadingCellWithIndex:(NSIndexPath*)indexPath
{
    NSAssert(NO, @"createLoadingCell need to be overwrited");
    return nil;
}
-(UITableViewCell*)createDataCellWithIndex:(NSIndexPath*)indexPath
{
    NSAssert(NO, @"createDataCellWithIndex need to be overwrited");
    return nil;
}

-(void)loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback
{
    NSAssert(NO, @"loadDataWithPage:callback: need to be overwrited");
}
-(void)configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withData:(id)data
{
    NSAssert(NO, @"configureCell:withIndexPath:withData: need to be overwrited");
}
-(void)configureLoadingCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    
}
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath
{
    return [pageController isLoadingCell:indexPath];
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
    if (currentPage == totalPageNum) {
        return datas.count;
    }
    return datas.count + 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == datas.count) {
        return [self createLoadingCellWithIndex:indexPath];
    }
    
    else {
        return [self createDataCellWithIndex:indexPath];
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == datas.count) {
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            
            [self loadDataWithPage:currentLoadingPage callback:^(NSArray* newDatas,NSUInteger totalPage){
                totalPageNum = totalPage;
                currentPage = currentLoadingPage;
                currentLoadingPage = -1;
                NSMutableArray *indexList = [@[] mutableCopy];
                NSUInteger startRow = datas.count;
                for (NSInteger idx = 0; idx < newDatas.count; idx++) {
                    [indexList addObject:[NSIndexPath indexPathForRow:startRow + idx inSection:0]];
                }
                [datas addObjectsFromArray:newDatas];
                [self.tableView beginUpdates];
                if (currentPage == totalPageNum) {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
                [self.tableView insertRowsAtIndexPaths:indexList withRowAnimation:UITableViewRowAnimationAutomatic];
                
                
                [self.tableView endUpdates];
            }];

        }
        [self configureLoadingCell:cell withIndexPath:indexPath];
    }
    else {
        [self configureCell:cell withIndexPath:indexPath withData:datas[indexPath.row]];
    }
}
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
