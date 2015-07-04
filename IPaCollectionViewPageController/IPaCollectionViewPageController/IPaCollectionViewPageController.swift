//
//  IPaCollectionViewPageController.swift
//  IPaCollectionViewPageController
//
//  Created by IPa Chen on 2015/7/3.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import Foundation
import UIKit
@objc protocol IPaCollectionViewPageControllerDelegate : AnyObject {
    func collectionViewForPageController(pageController:IPaCollectionViewPageController) -> UICollectionView
    func createLoadingCell(pageController:IPaCollectionViewPageController, indexPath:NSIndexPath) -> UICollectionViewCell
    func createDataCell(pageController:IPaCollectionViewPageController, indexPath:NSIndexPath) -> UICollectionViewCell
    func loadPageData(pageController:IPaCollectionViewPageController,page:UInt,complete:(newDatas:[AnyObject],totalPage:UInt) -> Void)
    func configureCell(pageController:IPaCollectionViewPageController,cell:UICollectionViewCell,indexPath:NSIndexPath,data:AnyObject)
    func configureLoadingCell(pageController:IPaCollectionViewPageController,cell:UICollectionViewCell,indexPath:NSIndexPath)
}
public class IPaCollectionViewPageController:NSObject,UICollectionViewDataSource {
    
    var totalPageNum:UInt = 1
    var currentPage:UInt = 0
    var currentLoadingPage:Int = -1
    var datas = [AnyObject]()
    weak var delegate:IPaCollectionViewPageControllerDelegate? = nil
    public func dataWithIndex(index:Int) -> AnyObject? {
        return (index < datas.count) ? datas[index] : nil
    }
    public func reloadAllData() {
        totalPageNum = 1
        currentPage = 0
        currentLoadingPage = -1

    }
    public func isLoadingCell(indexPath:NSIndexPath) -> Bool {
        return Bool(indexPath.item == datas.count)
    }
//MARK: UICollectionViewDataSource
    @objc public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    // Return the number of rows in the section.
        if (currentPage == totalPageNum) {
            return datas.count;
        }
        return datas.count + 1;
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @objc public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var retCell:UICollectionViewCell?
        if isLoadingCell(indexPath) {
            if let delegate = delegate {
                let cell = delegate.createLoadingCell(self, indexPath: indexPath)

                if currentLoadingPage != Int(currentPage + 1) {
                    currentLoadingPage = Int(currentPage + 1)
                    
                    delegate.loadPageData(self, page: UInt(currentLoadingPage), complete: {
                        (newDatas,totalPage) in
                        self.totalPageNum = totalPage
                        self.currentPage = UInt(self.currentLoadingPage)
                        self.currentLoadingPage = -1
                        let collectionView = delegate.collectionViewForPageController(self)
                        collectionView.performBatchUpdates({
                            var indexList = [NSIndexPath]()
                            let startItem = self.datas.count
                            for idx in 0..<newDatas.count {
                                indexList.append(NSIndexPath(forItem: startItem + idx, inSection: indexPath.section))
                            }
                            self.datas += newDatas
                            collectionView.insertItemsAtIndexPaths(indexList)
                            if self.currentPage == self.totalPageNum {
                                collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: startItem, inSection: indexPath.section)])
                            }
                        },completion: nil)
                            
                    })
                }
                
                
                
                delegate.configureLoadingCell(self, cell: cell, indexPath: indexPath)
                retCell = cell
            }


        }

        else {
            if let delegate = delegate {
                let cell = delegate.createDataCell(self, indexPath: indexPath)
                delegate.configureCell(self, cell: cell, indexPath: indexPath, data: datas[indexPath.item])
                retCell = cell
            }
        }
        return retCell!
    }

}
