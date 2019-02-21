//
//  NavigationManager.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/13/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import AVKit

class NavigationManager: NSObject {
    static var shared = NavigationManager()
    
    func showMediaPlayerURL(_ url: String, dismissBlock: (() -> ())? = nil) {
        if let topViewController = UIApplication.topViewController() {
            let module = AppModules.playerMedia.build()
            if let dipslayData = module.displayData as? PlayerMediaDisplayData {
                dipslayData.dismissBlock = dismissBlock
            }
            module.router.show(from: topViewController, embedInNavController: true, setupData: url)
        }
    }
    
    func showVideoGoogleDriverURL(_ url: String, cookies: [HTTPCookie]? = nil) {
        var cookiesArray = [HTTPCookie]()
        if let cookies = cookies {
            for cookie in cookies {
                if let _ = cookie.domain.range(of: "google.com") {
                    cookiesArray.append(cookie)
                }
            }
        }
        let videoURL = URL(string: url)
        let values = HTTPCookie.requestHeaderFields(with: cookiesArray)
        let cookieArrayOptions = ["AVURLAssetHTTPHeaderFieldsKey": values]
        let assets = AVURLAsset(url:  videoURL!, options: cookieArrayOptions)
        let item = AVPlayerItem(asset: assets)
        let videoPlayer = AVPlayer(playerItem: item)
        
        NavigationManager.shared.createAndLoadAdvertise()
        
        let playerViewController = PlayerViewController()
        playerViewController.player = videoPlayer
        UIApplication.topViewController()?.present(playerViewController, animated: true) {
            NavigationManager.shared.presentAdverstive(topViewController: playerViewController)
        }
        NavigationManager.shared.handlerDismissAdvertisement = {[weak playerViewController] in
            playerViewController?.player?.play()
        }
        playerViewController.dismissBlock = {
            NavigationManager.shared.presentAdverstive(topViewController: UIApplication.shared.keyWindow?.rootViewController)
        }
    }
}
