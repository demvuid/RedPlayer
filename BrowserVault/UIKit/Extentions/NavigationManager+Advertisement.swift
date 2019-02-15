//
//  NavigationManager+Advertisement.swift
//  BrowserVault
//
//  Created by HaiLe on 2/13/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension NavigationManager {
    
    struct ExportKeys {
        static fileprivate var presentView: UInt8 = 0
        static fileprivate var handlerDismissAdvertisement: UInt8 = 0
        static var banner: UInt8 = 0
    }
    
    var presentView: GADInterstitial? {
        get { return objc_getAssociatedObject(self, &ExportKeys.presentView) as? GADInterstitial }
        set { objc_setAssociatedObject(self, &ExportKeys.presentView, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var handlerDismissAdvertisement: (() -> ())? {
        get { return objc_getAssociatedObject(self, &ExportKeys.handlerDismissAdvertisement) as? () -> () }
        set { objc_setAssociatedObject(self, &ExportKeys.handlerDismissAdvertisement, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func createAndLoadAdvertise() {
        if !UserSession.shared.isUpgradedVersion() && (self.presentView == nil || self.presentView?.isReady == false) {
            self.presentView = GADInterstitial.createAndLoadInterstitial()
            self.updateDelegate()
        }
    }
    
    func updateDelegate() {
        self.presentView?.delegate = self
    }
    
    func presentAdverstive() {
        if let topViewController = UIApplication.topViewController(), !UserSession.shared.isUpgradedVersion() && presentView?.isReady == true {
            presentView?.present(fromRootViewController: topViewController)
        } else {
            Logger.debug("Ad wasn't ready")
            self.handlerDismissAdvertisement?()
            self.handlerDismissAdvertisement = nil
        }
    }
}

extension NavigationManager: GADInterstitialDelegate, AdvertisePresentProtocol {
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.createAndLoadAdvertise()
        self.handlerDismissAdvertisement?()
        self.handlerDismissAdvertisement = nil
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        self.createAndLoadAdvertise()
        self.handlerDismissAdvertisement?()
        self.handlerDismissAdvertisement = nil
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.createAndLoadAdvertise()
        self.handlerDismissAdvertisement?()
        self.handlerDismissAdvertisement = nil
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
    }
}
