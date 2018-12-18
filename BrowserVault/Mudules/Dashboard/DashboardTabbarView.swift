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
        
        let vc3 = AppModules.settings.build().view
        let nv3 = UINavigationController(rootViewController: vc3)
        nv3.tabBarItem.image = Asset.Tabbar.iconSettings.image
        nv3.tabBarItem.title = L10n.Settings.title
        
        self.viewControllers = [nv1, nv2, nv3]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
