//
//  BannerView.swift
//  Entertainment
//
//  Created by Hai Le on 8/28/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit
import GoogleMobileAds

let GOOGLE_Admob_ID = "ca-app-pub-1692212170080575~3603204569"
let GOOGLE_AdUnitID = "ca-app-pub-1692212170080575/1417569510"

protocol BannerViewDelegate {
    func bannerDidShow(_ banner: BannerView)
    func bannerLoadFailed(_ banner: BannerView)
}

class BannerView: GADBannerView {
    var bannerDelegate: BannerViewDelegate?
    
    convenience init() {
        self.init(adSize: (UIDevice.current.userInterfaceIdiom == .pad) ? kGADAdSizeLeaderboard : kGADAdSizeBanner)
    }
    
    func showBannerFromController(_ controller: BaseUserInterface) {
        self.adUnitID = GOOGLE_AdUnitID
        self.delegate = self
        self.rootViewController = controller
        self.bannerDelegate = controller
        self.loadRequest()
    }
    
    func loadRequest() {
        let request = GADRequest()
//        request.testDevices = ["cd76fa8449f7e425199435f191fa6fb2"]
        self.load(request)
    }

}

extension BannerView: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerDelegate?.bannerDidShow(self)
    }
    
    /// Tells the delegate an ad request failed.
    public func adView(_ bannerView: GADBannerView,
                       didFailToReceiveAdWithError error: GADRequestError) {
        if let banner = bannerView as? BannerView {
            self.bannerDelegate?.bannerLoadFailed(banner)
        }
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    }
}
