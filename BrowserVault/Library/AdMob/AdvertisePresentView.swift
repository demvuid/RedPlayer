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

extension GADInterstitial {
    class func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: GOOGLE_AdPresentUnitID)
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
}

protocol AdvertisePresentProtocol {
    func createAndLoadAdvertise()
    func presentAdverstive(topViewController: UIViewController?)
}
