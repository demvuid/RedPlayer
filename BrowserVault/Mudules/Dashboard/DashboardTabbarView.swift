//
//  DashboardTabbarView.swift
//  Dating
//
//  Created by HaiLe on 10/29/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import UIKit

class DashboardTabbarView: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.barTintColor = ColorName.tabBarTintColor
        self.tabBar.tintColor = ColorName.tabBarIconColor
        
        self.tabBar.barTintColor = ColorName.tabBarTintColor
        self.tabBar.tintColor = ColorName.tabBarIconColor
        
        let vc1 = AppModules.browser.build().view
        let nv1 = UINavigationController(rootViewController: vc1)
        nv1.tabBarItem.image = Asset.Tabbar.iconBrowser.image
        nv1.tabBarItem.title = L10n.Browser.title
        
        let vc2 = AppModules.files.build().view
        let nv2 = UINavigationController(rootViewController: vc2)
        nv2.tabBarItem.image = Asset.Tabbar.iconFolder.image
        nv2.tabBarItem.title = L10n.Folder.title
        
        
        let nv3 = UIViewController()
        nv3.tabBarItem.image = Asset.Tabbar.icFileDownload.image
        nv3.tabBarItem.title = L10n.Downloads.title
        
        let vc4 = AppModules.settings.build().view
        let nv4 = UINavigationController(rootViewController: vc4)
        nv4.tabBarItem.image = Asset.Tabbar.iconSettings.image
        nv4.tabBarItem.title = L10n.Settings.title
        
        self.viewControllers = [nv1, nv2, nv3, nv4]
        self.delegate = self
    }
}

extension DashboardTabbarView: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !(viewController is UINavigationController) else {
            return true
        }
        var items = [AlertActionItem]()
        var item = AlertActionItem(title: L10n.Folder.Download.File.library, style: .default, handler: {[weak self] (_) in
            CustomImagePickerController.presentPickerInTarget(self) { (result) in
                
            }
        })
        items.append(item)
        item = AlertActionItem(title: L10n.Folder.Download.File.network, style: .default, handler: {[weak self] (_) in
            guard let self = self else { return }
            let module = AppModules.download.build()
            module.router.show(from: self, embedInNavController: true)
        })
        items.append(item)
        item = AlertActionItem(title: L10n.Folder.Browse.File.network, style: .default, handler: {[weak self] (_) in
            guard let self = self else { return }
            let module = AppModules.download.build()
            if let displayData = module.displayData as? DownloadDisplayData {
                displayData.browseType = .play
            }
            module.router.show(from: self, embedInNavController: true)
        })
        items.append(item)
        item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
        items.append(item)
        self.showActionSheet(items: items)
        return false
    }
}
