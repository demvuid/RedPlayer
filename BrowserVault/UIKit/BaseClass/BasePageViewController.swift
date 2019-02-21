//
//  BasePageViewController.swift
//  Entertainment
//
//  Created by Hai Le on 8/21/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit

class PageItem {
    var itemId: String!
}

class PageViewController: UIViewController {
    var pageItem: PageItem! = PageItem()
}

protocol BasePageViewControllerDelegate: PageModelControllerDelegate {
    func pageViewControllerSwipeToPage(_ index: Int)
}

class BasePageViewController: UIViewController {

    var pageViewController: UIPageViewController!
    var pendingIndex = NSNotFound
    var direction = UIPageViewController.NavigationDirection.forward
    
    var currentIndex: Int! {
        willSet {
            direction = .forward
            if currentIndex != nil && currentIndex > newValue {
                direction = .reverse
            }
        }
        didSet {
            if self.dataSourceDelegate != nil && self.pageItems != nil && pageItems.count > 0 {
                if let controller = modelController.viewControllerAtIndex(currentIndex) {
                    pageViewController.setViewControllers([controller], direction: direction, animated: true, completion: nil)
                }
            }
        }
    }
    
    var pageItems: [PageItem]! {
        didSet {
            modelController.pageItems = pageItems;
            self.currentIndex = 0
        }
    }
    var dataSourceDelegate: BasePageViewControllerDelegate! {
        didSet {
            modelController.dataSourceDelegate = dataSourceDelegate
            self.currentIndex = 0
        }
    }
    
    var modelController: PageModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = PageModelController()
        }
        return _modelController!
    }
    
    var _modelController: PageModelController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
    }
    
    func setupUI() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self;
        modelController.dataSourceDelegate = self.dataSourceDelegate
        modelController.pageItems = self.pageItems
        pageViewController.dataSource = modelController
        pageViewController.view.frame = self.view.bounds
        self.view .addSubview(pageViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BasePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = modelController.indexOfViewController(pendingViewControllers.last as! PageViewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed && pendingIndex != NSNotFound {
            if self.dataSourceDelegate != nil {
                self.dataSourceDelegate?.pageViewControllerSwipeToPage(pendingIndex)
            }
        }
    }
}
