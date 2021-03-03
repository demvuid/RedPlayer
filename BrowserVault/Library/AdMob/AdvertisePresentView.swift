//
//  AdvertisePresentView.swift
//  BrowserVault
//
//  Created by HaiLe on 1/19/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

let GOOGLE_AdPresentUnitID = "ca-app-pub-9119259386159657/3994234495"

#if canImport(GoogleMobileAds)
extension GADInterstitialAd {
    class func createAndLoadInterstitial(adPresentUnitID: String = GOOGLE_AdPresentUnitID, completionHandler: @escaping (GADInterstitialAd?, Error?) -> Void) {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adPresentUnitID, request: request, completionHandler: completionHandler)
    }
}
#endif

protocol AdvertisePresentProtocol {
    func createAndLoadAdvertise()
    func presentAdverstive(topViewController: UIViewController?)
}
