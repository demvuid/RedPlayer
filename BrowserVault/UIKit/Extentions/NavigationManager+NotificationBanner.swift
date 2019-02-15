//
//  NavigationManager+NotificationBanner.swift
//  BrowserVault
//
//  Created by HaiLe on 2/13/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import NotificationBannerSwift
extension NavigationManager {
    var banner: FloatGrowingNotificationBanner? {
        get { return objc_getAssociatedObject(self, &ExportKeys.banner) as? FloatGrowingNotificationBanner }
        set { objc_setAssociatedObject(self, &ExportKeys.banner, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var bannerRootController: UIViewController? {
        return UIApplication.topViewController()?.tabBarController ?? (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }
    
    var bannerPadding: CGFloat {
        return UIApplication.topViewController()?.tabBarController?.tabBar.frame.height ?? 50
    }
    
    func showBannerDownloadTitle(_ title: String, onControlller controller: UIViewController? = NavigationManager.shared.bannerRootController, padding: CGFloat = NavigationManager.shared.bannerPadding, handler: @escaping () -> ()) {
        if self.banner == nil {
            let leftView = UIImageView(image: Asset.General.info.image)
            let rightView = UIImageView(image: Asset.General.rightChevron.image)
            self.banner = FloatGrowingNotificationBanner(title: title, leftView: leftView, rightView: rightView, style: .info)
            self.banner?.bannerHeight = 50
            self.banner?.autoDismiss = false
            let edge = UIEdgeInsets(top: 0, left: 8, bottom: padding, right: 8)
            self.banner?.show(bannerPosition: .bottom, on: controller, edgeInsets: edge, cornerRadius: 10)
        } else {
            self.banner?.titleLabel?.text = title
        }
        self.banner?.onTap = {[weak self] in
            self?.banner?.dismiss()
            self?.banner = nil
            handler()
        }
    }
    
    func showBannerDownload(onController controller: UIViewController? = NavigationManager.shared.bannerRootController, padding: CGFloat = NavigationManager.shared.bannerPadding) {
        let items = DownloadManager.shared.numberItemsDownload()
        if items > 0 {
            let title = items > 1 ? "\(items) files" : "\(items) file"
            let titleDownload = "Downloading \(title)..."
            self.showBannerDownloadTitle(titleDownload, onControlller: controller, padding: padding) {[weak controller] in
                guard let controller = controller else { return }
                let module = AppModules.download.build()
                if let displayData = module.displayData as? DownloadDisplayData {
                    displayData.browseType = .currentDownload
                }
                module.router.show(from: controller, embedInNavController: true)
            }
        } else {
            self.dismissBanner()
        }
    }
    
    func updateStatusBanner() {
        self.showBannerDownload()
    }
    
    func dismissBanner() {
        self.banner?.dismiss()
    }
}
