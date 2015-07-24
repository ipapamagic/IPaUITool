//
//  IPaTableViewPageController.swift
//  IPaPageControlTableViewController
//
//  Created by IPa Chen on 2015/7/24.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import UIKit

protocol IPaTableViewPageControllerDelegate {
    func tableViewForPageController(pageController:IPaTableViewPageController) -> UITableView
    func createLoading(pageController:IPaTableViewPageController, indexPath:NSIndexPath) -> UITableViewCell
    func createDataCell(pageController:IPaTableViewPageController, indexPath:NSIndexPath) -> UITableViewCell
    func loadData(pageController:IPaTableViewPageController,  page:Int, complete:([AnyObject],Int)->())
    func configureCell(pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:NSIndexPath,data:AnyObject)
    func configureLoadingCell(pageController:IPaTableViewPageController,cell:UITableViewCell,indexPath:NSIndexPath)
}

public class IPaTableViewPageController {
    var totalPageNum = 1
    var currentPage = 0
    var currentLoadingPage = -1
    var datas = [AnyObject]()
    var delegate:IPaTableViewPageControllerDelegate?
    public func getData(index:Int) -> AnyObject? {
        return (datas.count <= index) ? nil : datas[index]
    }
    public func reloadAllData() {
        totalPageNum = 1;
        currentPage = 0;
        currentLoadingPage = -1;
        datas.removeAll(keepCapacity: true)
        if let tableView = delegate?.tableViewForPageController(self) {
            tableView.reloadData()
        }
    }
    func isLoadingCell(indexPath:NSIndexPath) -> Bool {
        return Bool(indexPath.row == datas.count)
    }
    // MARK:Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentPage == totalPageNum {
            return datas.count
        }
        return datas.count + 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let delegate = self.delegate {
            if isLoadingCell(indexPath) {
                cell = delegate.createLoading(self, indexPath: indexPath)
                if (currentLoadingPage != currentPage + 1) {
                    currentLoadingPage = currentPage + 1;
                    delegate.loadData(self, page: currentLoadingPage, complete: {
                        newDatas,totalPage in
                        self.totalPageNum = totalPage
                        self.currentPage = self.currentLoadingPage
                        self.currentLoadingPage = -1
                        var indexList = [NSIndexPath]()
                        let startRow = self.datas.count
                        for idx in 0..< newDatas.count {
                            indexList.append(NSIndexPath(forRow: startRow + idx, inSection: indexPath.section))
                        }
                        self.datas = self.datas + newDatas
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let tableView = delegate.tableViewForPageController(self)
                            tableView.beginUpdates()
                            if self.currentPage == self.totalPageNum {
                                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: startRow, inSection: indexPath.section)], withRowAnimation: .Automatic)
                            }
                            if indexList.count > 0 {
                                tableView.insertRowsAtIndexPaths(indexList, withRowAnimation: .Automatic)
                            }
                            tableView.endUpdates()
                            if self.currentPage != self.totalPageNum {
                                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.datas.count, inSection: indexPath.section)], withRowAnimation: .Automatic)
                            }
                        })
                    })
                    
                }
                delegate.configureLoadingCell(self, cell: cell, indexPath: indexPath)
            }
            else {
                cell = delegate.createDataCell(self, indexPath: indexPath)
                delegate.configureCell(self, cell: cell, indexPath: indexPath, data: datas[indexPath.row])
                
            }
        }
        return cell;
    }
    
}
