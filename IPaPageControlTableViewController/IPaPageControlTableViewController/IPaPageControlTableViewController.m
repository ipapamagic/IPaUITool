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
    pageController.delegate = self;
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
    return [pageController numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pageController tableView:tableView numberOfRowsInSection:section];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [pageController tableView:tableView cellForRowAtIndexPath:indexPath];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - IPaTableViewPageControllerDelegate

- (UITableView*)tableViewForPageController:(IPaTableViewPageController*)pageController
{
    return self.tableView;
}
-(UITableViewCell*)pageController:(IPaTableViewPageController*)pageController createLoadingCellWithIndex:(NSIndexPath*)indexPath
{
    return [self createLoadingCellWithIndex:indexPath];
}
-(UITableViewCell*)pageController:(IPaTableViewPageController*)pageController createDataCellWithIndex:(NSIndexPath*)indexPath
{
    return [self createDataCellWithIndex:indexPath];
}
-(void)pageController:(IPaTableViewPageController*)pageController  loadDataWithPage:(NSUInteger)page callback:(void (^)(NSArray*,NSUInteger))callback
{
    [self loadDataWithPage:page callback:callback];
}
-(void)pageController:(IPaTableViewPageController*)pageController  configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath withData:(id)data
{
    return [self configureCell:cell withIndexPath:indexPath withData:data];
}

-(void)pageController:(IPaTableViewPageController*)pageController  configureLoadingCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    return [self configureLoadingCell:cell withIndexPath:indexPath];
}
@end
