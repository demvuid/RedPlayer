//
//  NavigationManager+Advertisement.swift
//  BrowserVault
//
//  Created by HaiLe on 2/13/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

extension NavigationManager {
    
    struct ExportKeys {
        static fileprivate var presentView: UInt8 = 0
        static fileprivate var handlerDismissAdvertisement: UInt8 = 0
        static var banner: UInt8 = 0
        static var timerAdv: UInt8 = 0
    }
    #if canImport(GoogleMobileAds)
    var presentView: GADInterstitialAd? {
        get { return objc_getAssociatedObject(self, &ExportKeys.presentView) as? GADInterstitialAd }
        set { objc_setAssociatedObject(self, &ExportKeys.presentView, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    #endif
    var handlerDismissAdvertisement: (() -> ())? {
        get { return objc_getAssociatedObject(self, &ExportKeys.handlerDismissAdvertisement) as? () -> () }
        set { objc_setAssociatedObject(self, &ExportKeys.handlerDismissAdvertisement, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var timerAdv: Timer? {
        get { return objc_getAssociatedObject(self, &ExportKeys.timerAdv) as? Timer }
        set { objc_setAssociatedObject(self, &ExportKeys.timerAdv, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func createAndLoadAdvertise() {
        #if canImport(GoogleMobileAds)
        if !UserSession.shared.isUpgradedVersion() && (self.presentView == nil) {
            GADInterstitialAd.createAndLoadInterstitial(completionHandler: { [weak self] (ad, error) in
                self?.presentView = ad
                ad?.fullScreenContentDelegate = self
            })
            self.startTimer()
        }
        #endif
    }
    
    func presentAdverstive(topViewController: UIViewController? = nil) {
        self.stopTimer()
        #if canImport(GoogleMobileAds)
        let topViewController = topViewController ?? UIApplication.topViewController()
        if let topViewController = topViewController, !UserSession.shared.isUpgradedVersion() {
            presentView?.present(fromRootViewController: topViewController)
        } else {
            Logger.debug("Ad wasn't ready")
            self.handlerDismissAdvertisement?()
            self.handlerDismissAdvertisement = nil
        }
        #endif
    }
    
    @objc func presentAdvertisement() {
        self.handlerDismissAdvertisement = {[weak self] in
            self?.startTimer()
        }
        self.presentAdverstive()
    }
    
    func startTimer() {
        if self.timerAdv == nil {
            var timeInterval = SystemService.sharedInstance.timeIntervalAdv
            if timeInterval < 5.0 {
                timeInterval = 5.0
            }
            self.timerAdv = Timer.scheduledTimer(timeInterval: timeInterval * 60, target: self, selector: #selector(self.presentAdvertisement), userInfo: nil, repeats: false)
        }
    }
    
    func stopTimer() {
        if timerAdv != nil {
            timerAdv?.invalidate()
            timerAdv = nil
        }
    }
}

#if canImport(GoogleMobileAds)
extension NavigationManager: GADFullScreenContentDelegate, AdvertisePresentProtocol {
    
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.createAndLoadAdvertise()
        self.handlerDismissAdvertisement?()
        self.handlerDismissAdvertisement = nil
      }

      /// Tells the delegate that the ad presented full screen content.
      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.createAndLoadAdvertise()
        self.handlerDismissAdvertisement?()
        self.handlerDismissAdvertisement = nil
      }
}
#endif
