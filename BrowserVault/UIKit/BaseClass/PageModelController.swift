//
//  PageModelController.swift
//  Entertainment
//
//  Created by Hai Le on 8/21/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit

protocol PageModelControllerDelegate {
    func viewControllerWithItem(_ item: PageItem) -> PageViewController!;
}

class PageModelController: NSObject, UIPageViewControllerDataSource {
    
    var pageItems: [PageItem]!
    var dataSourceDelegate: PageModelControllerDelegate?
    
    
    func viewControllerAtIndex(_ index: Int) -> PageViewController! {
        // Return the data view controller for the given index.
        if (self.pageItems.count == 0) || (index >= self.pageItems.count) {
            return nil
        }
        
        if self.dataSourceDelegate != nil {
            let item = self.pageItems[index]
            return self.dataSourceDelegate?.viewControllerWithItem(item)
        }
        return nil
    }
    
    func indexOfViewController(_ controller: PageViewController) -> Int! {
        return self.pageItems.index(where: { (item) -> Bool in
            return controller.pageItem.itemId == item.itemId
        }) ?? NSNotFound
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PageViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index = index! - 1
        return self.viewControllerAtIndex(index!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PageViewController)
        if index == NSNotFound {
            return nil
        }
        
        index = index! + 1
        if index == self.pageItems.count {
            return nil
        }
        return self.viewControllerAtIndex(index!)
    }
}
