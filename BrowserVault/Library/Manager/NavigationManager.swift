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
            let videoPlayer = AVPlayer(url: URL(string: url)!)
            
            let playerViewController = PlayerViewController()
            playerViewController.player = videoPlayer
            topViewController.present(playerViewController, animated: true) {[weak playerViewController] in
                playerViewController?.player?.play()
            }
        }
    }
    
    func showVideoGoogleDriverURL(_ url: String, cookies: [HTTPCookie]? = nil, header: [String: String]? = nil) {
        var header = header ?? [:]
        if let cookies = cookies {
            var cookiesArray = [HTTPCookie]()
            for cookie in cookies {
                cookiesArray.append(cookie)
            }
            header = HTTPCookie.requestHeaderFields(with: cookiesArray)
        }
        let cookieArrayOptions = ["AVURLAssetHTTPHeaderFieldsKey": header]
        let videoURL = URL(string: url)
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
    
    func playRichFormatMovie(_ url: String, dismissBlock: (() -> ())? = nil) {
        if let topViewController = UIApplication.topViewController() {
            let module = AppModules.playerMedia.build()
            if let dipslayData = module.displayData as? PlayerMediaDisplayData {
                dipslayData.dismissBlock = dismissBlock
            }
            let controller = module.router.embedInNavigationController()
            controller.modalPresentationStyle = .fullScreen
            module.presenter.setupView(data: url)
            topViewController.present(controller, animated: true, completion: nil)
        }
    }
    
    func handlePlayURL(_ url: String) {
        if url.contains("googleapis.com") {
            self.playRichFormatMovie(url)
        } else {
            let controller = UIApplication.topViewController()
            controller?.startActivityLoading()
            ParseVideoManager.shared.getVideoIDFromDriveGoogleURL(url) { (videoId, cookies) in
                if let videoId = videoId {
                    var cookies: [HTTPCookie] = cookies
                    ParseVideoManager.shared.getVideoURLFromVideoId(videoId) { (videoURL, cookiesDrive) in
                        cookies.append(contentsOf: cookiesDrive)
                        if let cachedCookies = HTTPCookieStorage.shared.cookies {
                            for cookie in cachedCookies {
                                if cookie.domain.contains("drive.google.com") {
                                    cookies.append(cookie)
                                }
                            }
                        }
                        DispatchQueue.main.async {[weak controller] in
                            controller?.stopActivityLoading()
                            if let videoURL = videoURL {
                                var header: [String: String] = HTTPCookie.requestHeaderFields(with: cookies)
                                let urlComponents = URLComponents(string: url)
                                if let cookie = urlComponents?.queryItems?.first(where: {$0.name.uppercased() == "COOKIE"})?.value {
                                    if var valueCookie = header["Cookie"] {
                                        if valueCookie.contains(cookie) == false {
                                            valueCookie += "; \(cookie)"
                                            header["Cookie"] = valueCookie
                                        }
                                    } else {
                                        header["Cookie"] = cookie
                                    }
                                }
                                NavigationManager.shared.showVideoGoogleDriverURL(videoURL, header: header)
                            } else {
                                NavigationManager.shared.showMediaPlayerURL(url)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {[weak controller] in
                        controller?.stopActivityLoading()
                        NavigationManager.shared.showMediaPlayerURL(url)
                    }
                }
            }
        }
    }
}
