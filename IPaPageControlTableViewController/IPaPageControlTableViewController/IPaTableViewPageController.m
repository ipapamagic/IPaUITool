//
//  IPaTableViewPageController.m
//  IPaPageControlTableViewController
//
//  Created by IPa Chen on 2015/3/3.
//  Copyright (c) 2015年 IPaPa. All rights reserved.
//

#import "IPaTableViewPageController.h"
@interface IPaTableViewPageController() 
@end
@implementation IPaTableViewPageController
{
    NSInteger totalPageNum;
    NSInteger currentPage;
    NSInteger currentLoadingPage;
    NSMutableArray *datas;
}
- (instancetype)init
{
    self = [super init];
    totalPageNum = 1;
    currentPage = 0;
    currentLoadingPage = -1;
    datas = [@[] mutableCopy];
    return self;
}
-(id)dataWithIndex:(NSUInteger)index
{
    return (index < [datas count])?datas[index]:nil;
}
-(void)reloadAllData
{
    totalPageNum = 1;
    currentPage = 0;
    currentLoadingPage = -1;
    datas = [@[] mutableCopy];
    [[self.delegate tableViewForPageController:self] reloadData];
}
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath
{
    return (indexPath.row == datas.count);
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
    UITableViewCell *cell;
    if ([self isLoadingCell:indexPath]) {
        cell = [self.delegate pageController:self createLoadingCellWithIndex:indexPath];
        if (currentLoadingPage != currentPage + 1) {
            currentLoadingPage = currentPage + 1;
            
            [self.delegate pageController:self loadDataWithPage:currentLoadingPage callback:^(NSArray* newDatas,NSUInteger totalPage){
                totalPageNum = totalPage;
                currentPage = currentLoadingPage;
                currentLoadingPage = -1;
                NSMutableArray *indexList = [@[] mutableCopy];
                NSUInteger startRow = datas.count;
                for (NSInteger idx = 0; idx < newDatas.count; idx++) {
                    [indexList addObject:[NSIndexPath indexPathForRow:startRow + idx inSection:0]];
                }
                [datas addObjectsFromArray:newDatas];
                UITableView *tableView = [self.delegate tableViewForPageController:self];
                [tableView beginUpdates];
                if (currentPage == totalPageNum) {
                    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:startRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
                [tableView insertRowsAtIndexPaths:indexList withRowAnimation:UITableViewRowAnimationAutomatic];
                
                
                [tableView endUpdates];
            }];
            
        }
        [self.delegate pageController:self configureLoadingCell:cell withIndexPath:indexPath];
    }
    
    else {
        cell = [self.delegate pageController:self createDataCellWithIndex:indexPath];
        [self.delegate pageController:self configureCell:cell withIndexPath:indexPath withData:datas[indexPath.row]];
    }
    return cell;
}

@end
