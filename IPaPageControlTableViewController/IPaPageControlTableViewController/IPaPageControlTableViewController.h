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
-(void)reloadAllData;
-(BOOL)isLoadingCell:(NSIndexPath*)indexPath;

@end
