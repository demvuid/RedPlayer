//
//  YoutubeView.swift
//  BrowserVault
//
//  Created by HaiLe on 2/18/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import SnapKit
import GoogleMobileAds

//MARK: - Public Interface Protocol
protocol YoutubeViewInterface: class {
    func currentGroupYoutube() -> GroupYoutube?
    func selectGroupYoutube(_ groupYoutube: GroupYoutube)
    func listGroupYoutube() -> [GroupYoutube]
}

//MARK: YoutubeView Class
final class YoutubeView: BaseUserInterface {
    @IBOutlet weak var categories: BaseMenuCategoriesView!
    lazy var menuItems = [MenuCategory]()
    var groupYoutube: GroupYoutube!
    var listGroup = [GroupYoutube]()
    var pageViewController: BasePageViewController!
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.Youtube.icFilterVariant.image, style: .plain, target: self.presenter, action: #selector(self.presenter.changeCategories))
        self.title = L10n.Youtube.Tvshows.title
    }
    
    override func setupUI() {
        self.showBanner()
        self.currentPage = 0
        self.categories.categoryDelegate = self
        self.setupPageView()
        self.reloadCategories()
    }
    
    func setupPageView() {
        self.pageViewController = BasePageViewController(nibName: "BasePageViewController", bundle: Bundle.main)
        self.addChild(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController?.view?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.categories.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).priority(ConstraintPriority.low)
        })
        self.pageViewController.dataSourceDelegate = self
    }
    
    func reloadCategories() {
        self.listCategory {[weak self] in
            guard let self = self else { return }
            self.menuItems.removeAll()
            if let groupYoutube = self.groupYoutube {
                self.menuItems.append(contentsOf: groupYoutube.categories.map({$0}))
            }
            let dataSources = self.menuItems.map({ MenuItem(name: $0.name, iconName: nil, iconUrl: nil) })
            
            self.categories.loadMenuItems(dataSources)
            self.categories.scrollCategoryToIndex(self.currentPage)
            
            var dataPages = Array<PageYoutubeItem>()
            for item in self.menuItems {
                dataPages.append(PageYoutubeItem(category: item))
            }
            
            self.pageViewController.pageItems = dataPages
        }
    }
    
    func listCategory(_ block: @escaping () -> ()) {
        if self.listGroup.count > 0 {
            block()
        } else {
            SystemService.sharedInstance.groupMenuWithCompletionBlock { [weak self] (menuGroup, error) in
                if let menuGroup = menuGroup {
                    self?.listGroup.removeAll()
                    self?.listGroup.append(contentsOf: menuGroup.groups.map({$0}))
                    self?.groupYoutube = self?.listGroup.first
                }
                block()
            }
        }
    }
    
    override func showBannerView(_ bannerView: GADBannerView) {
        self.view.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.pageViewController.view.snp.bottom)
            make.height.equalTo(bannerView.frame.height)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }
}

extension YoutubeView: BaseMenuCategoriesViewDelegate {
    func menuCategorySwipeToPage(_ page: Int) {
        self.currentPage = page
        self.pageViewController.currentIndex = page
    }
}

extension YoutubeView: BasePageViewControllerDelegate {
    func pageViewControllerSwipeToPage(_ index: Int) {
        self.currentPage = index
        self.categories.scrollCategoryToIndex(index)
    }
    
    func viewControllerWithItem(_ item: PageItem) -> PageViewController! {
        let youtubeController = self.storyboard?.instantiateViewController(withIdentifier: "YoutubeViewController") as! YoutubeViewController
        youtubeController.pageItem = item
        youtubeController.delegate = self
        return youtubeController
    }
    
    func currentPageYoutubeController() -> YoutubeViewController? {
        if let viewControllers = self.pageViewController.pageViewController.viewControllers {
            return viewControllers.last as? YoutubeViewController
        }
        return nil
    }
}

extension YoutubeView: YoutubeViewControllerDelegate {
    func playYoutubeItem(_ item: YoutubeItem) {
        self.presenter.playVideoById(item.itemId, duration: item.duration)
    }
}
//MARK: - Public interface
extension YoutubeView: YoutubeViewInterface {
    func currentGroupYoutube() -> GroupYoutube? {
        return self.groupYoutube
    }
    func selectGroupYoutube(_ groupYoutube: GroupYoutube) {
        self.groupYoutube = groupYoutube
        self.title = groupYoutube.name
        self.currentPage = 0
        self.reloadCategories()
        self.navigationController?.popViewController(animated: true)
    }
    
    func listGroupYoutube() -> [GroupYoutube] {
        return listGroup
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension YoutubeView {
    var presenter: YoutubePresenter {
        return _presenter as! YoutubePresenter
    }
    var displayData: YoutubeDisplayData {
        return _displayData as! YoutubeDisplayData
    }
}
