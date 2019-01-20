//
//  AdvertisePresentView.swift
//  BrowserVault
//
//  Created by HaiLe on 1/19/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
import GoogleMobileAds

let GOOGLE_AdPresentUnitID = "ca-app-pub-9119259386159657/3994234495"

class AdvertisePresentView: GADInterstitial {
    class func createAndLoadInterstitial() -> AdvertisePresentView {
        let interstitial = AdvertisePresentView(adUnitID: GOOGLE_AdPresentUnitID)
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
}

protocol AdvertisePresentProtocol {
    func createAndLoadAdvertise()
    func presentAdverstive()
}

extension AdvertisePresentProtocol where Self: BaseUserInterface {
    func createAndLoadAdvertise() {
        self.interstitial = AdvertisePresentView.createAndLoadInterstitial()
        self.updateDelegate()
    }
    
    func presentAdverstive() {
        if !UserSession.shared.isUpgradedVersion() && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            Logger.debug("Ad wasn't ready")
            self.handlerPlayerVideo?()
            self.handlerPlayerVideo = nil
        }
    }
}

extension BaseUserInterface: GADInterstitialDelegate, AdvertisePresentProtocol {
    func updateDelegate() {
        self.interstitial.delegate = self
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.createAndLoadAdvertise()
        self.handlerPlayerVideo?()
        self.handlerPlayerVideo = nil
    }
}
