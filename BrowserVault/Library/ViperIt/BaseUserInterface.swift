//
//  BaseViewController.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/10/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Viperit

class BaseUserInterface: UserInterface {
    var bannerView: BannerView!
    
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
    
    func showBanner() {
        self.bannerView = BannerView()
        self.bannerView.showBannerFromController(self)
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
    
    func showBannerView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        self.updateConstraintBannerView(bannerView)
    }
    
    func removeBannerFromSupperView() {
        if let banner = self.bannerView {
            banner.removeFromSuperview()
        }
    }
    
    func updateConstraintBannerView(_ bannerView: BannerView) {
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


extension BaseUserInterface: BannerViewDelegate {
    func bannerDidShow(_ banner: BannerView) {
        self.showBannerView(banner)
    }
    
    func bannerLoadFailed(_ banner: BannerView) {
        
    }
}
