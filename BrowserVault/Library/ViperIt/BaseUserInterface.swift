//
//  BaseViewController.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/10/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Viperit
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

class BaseUserInterface: UserInterface {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    func setupUI() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onOrientationChanged() {
        
    }
    
    func statusBarHeight() -> CGFloat {
        if #available(iOS 11.0, *), let height = UIApplication.shared.keyWindow?.safeAreaInsets.top, height > 0 {
            return height
        }
        return UIApplication.shared.statusBarFrame.height
    }
    
    #if canImport(GoogleMobileAds)
    func showBannerView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        self.updateConstraintBannerView(bannerView)
    }
    #endif
}

#if canImport(GoogleMobileAds)
extension BaseUserInterface: BannerViewDelegate {
    
}
#endif
