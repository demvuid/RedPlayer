//
//  UIApplication.swift
//  VideoPlayer
//
//  Created by Hai Le on 3/21/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif
import AppTrackingTransparency
import AdSupport

@objc extension UIApplication {
    
    class func configGoogleAdmob() {
        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        self.requestIDFA()
        #endif
    }
    
    class func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads here.
                // loadAd()
            })
        }
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    class func topNavigationController() -> UINavigationController? {
        let topViewController: UIViewController? = UIApplication.topViewController()
        if let nav = topViewController as? UINavigationController {
            return nav
        }
        if let tab = topViewController as? UITabBarController {
            if let selected = tab.selectedViewController as? UINavigationController {
                return selected
            }
            return tab.selectedViewController?.navigationController
        }
        return topViewController?.navigationController
    }
}
