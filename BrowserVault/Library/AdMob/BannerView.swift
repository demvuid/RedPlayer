//
//  BannerView.swift
//  Entertainment
//
//  Created by Hai Le on 8/28/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

let GOOGLE_Admob_ID = "ca-app-pub-9119259386159657~6928176134"
let GOOGLE_AdUnitID = "ca-app-pub-9119259386159657/3047150181"

#if canImport(GoogleMobileAds)
protocol BannerViewDelegate {
    func bannerDidShow(_ banner: GADBannerView)
    func bannerLoadFailed(_ banner: GADBannerView)
}



extension GADBannerView {
    
    class func instance() -> GADBannerView {
        var banner: GADBannerView!
        if UIDevice.current.userInterfaceIdiom == .pad {
            banner = GADBannerView(adSize: kGADAdSizeLeaderboard)
        } else {
            banner = GADBannerView(adSize: kGADAdSizeBanner)
        }
        return banner
    }
    
    func showBannerFromController(_ controller: BaseUserInterface, adUnitID: String = GOOGLE_AdUnitID) {
        self.adUnitID = adUnitID
        self.rootViewController = controller
        self.delegate = controller
        self.loadRequest()
    }
    
    func loadRequest() {
        let request = GADRequest()
        self.load(request)
    }

}

#endif
extension BaseUserInterface {
    private struct ExportKeys {
        static fileprivate var bannerView: UInt8 = 0
    }

    #if canImport(GoogleMobileAds)
    var bannerView: GADBannerView? {
        get { return objc_getAssociatedObject(self, &ExportKeys.bannerView) as? GADBannerView }
        set { objc_setAssociatedObject(self, &ExportKeys.bannerView, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    #endif
    
    func showBanner(adUnitID: String = GOOGLE_AdUnitID) {
        guard UserSession.shared.isUpgradedVersion() == false else {
            return
        }
        #if canImport(GoogleMobileAds)
        self.bannerView = GADBannerView.instance()
        self.bannerView?.showBannerFromController(self, adUnitID: adUnitID)
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension BannerViewDelegate where Self: BaseUserInterface {
    
    func bannerDidShow(_ banner: GADBannerView) {
        self.showBannerView(banner)
    }
    
    func bannerLoadFailed(_ banner: GADBannerView) {
        
    }
    
    func removeBannerFromSupperView() {
        if let banner = self.bannerView {
            banner.removeFromSuperview()
        }
    }
    
    func updateConstraintBannerView(_ bannerView: GADBannerView) {
        if #available(iOS 11.0, *) {
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: view.safeAreaLayoutGuide,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        } else {
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: bottomLayoutGuide,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
    }
}

extension BaseUserInterface: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerDidShow(bannerView)
    }
    
    /// Tells the delegate an ad request failed.
    func bannerView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: Error) {
        self.bannerLoadFailed(bannerView)
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    }
}

#endif
