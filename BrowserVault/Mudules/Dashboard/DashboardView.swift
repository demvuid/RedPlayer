//
//  DashboardView.swift
//  Dating
//
//  Created by HaiLe on 10/29/18.
//Copyright © 2018 Astraler. All rights reserved.
//

import UIKit
import Viperit
import ReviewKit

//MARK: - Public Interface Protocol
protocol DashboardViewInterface {
}

//MARK: DashboardView Class
final class DashboardView: UserInterface {
    private var tabBarView = DashboardTabbarView()
    lazy var isUpgradedPro = false
    var upgradeHeaderView: UpgradePlusView? = {
        let headerView = Bundle.main.loadNibNamed("UpgradePlusView", owner: nil, options: nil)?.first as? UpgradePlusView
        headerView?.layer.borderWidth = 1
        headerView?.layer.borderColor = UIColor.lightGray.cgColor
        headerView?.layer.cornerRadius = 5.0
        
        return headerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(tabBarView)
        view.addSubview(tabBarView.view)
        self.tabBarView.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        self.setupObserver()
        self.startCheckingReceipt()
        
        // Request to rate or/and write a review on 3rd, 20th app launches & repeat for every 100th app launch
        let appLaunchInterval = RequestInterval(first: 3, second: 10, repeatEvery: 100)
        let appLaunchRule = RequestReviewRule(ruleType: .appLaunches, requestInterval: appLaunchInterval)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(3))) {
            ReviewManager.default.requestReview(for: appLaunchRule)
        }
    }
    
    func addUpgradeView(_ headerView: UpgradePlusView) {
        if headerView.superview == nil {
            headerView.removeFromSuperview()
            self.tabBarView.view.removeFromSuperview()
            self.tabBarView.removeFromParent()
            self.addChild(tabBarView)
            view.addSubview(tabBarView.view)
            self.tabBarView.view.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
            }
            self.view.addSubview(headerView)
            headerView.snp.makeConstraints { (make) in
                make.leadingMargin.equalTo(5)
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.view.safeAreaLayoutGuide).offset(2)
                } else {
                    make.top.equalToSuperview().offset(2)
                }
                make.height.equalTo(35)
                make.bottom.equalTo(self.tabBarView.view.snp.top).offset(-2)
                make.trailingMargin.equalTo(-5)
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(getInfoReceipt))
        tapGesture.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tapGesture)
    }
    
    func removeUpgradeView() {
        if self.upgradeHeaderView?.superview != nil {
            self.tabBarView.view.removeConstraints(self.tabBarView.view.constraints)
            self.tabBarView.view.snp.makeConstraints { (make) in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
            self.upgradeHeaderView?.removeFromSuperview()
        }
    }
    
    func setupObserver() {
        PurchaseManager.shared.observerUpgradeVersion {[weak self] in
            if UserSession.shared.getSubscriptionFlag() == 1 {
                self?.removeUpgradeView()
            }
        }
        
        PurchaseManager.shared.observerGettingSubscription {
            if UserSession.shared.getSubscriptionFlag() != 1 {
                if let headerView = self.upgradeHeaderView {
                    self.addUpgradeView(headerView)
                    headerView.showUpgradeVersion()
                }
            }
        }
    }
    
    func startCheckingReceipt() {
        if UserSession.shared.getSubscriptionFlag() == 1 {
            PurchaseManager.shared.verifyAccountPro { (_, _) in
                if UserSession.shared.getSubscriptionFlag() != 1, let headerView = self.upgradeHeaderView {
                    self.addUpgradeView(headerView)
                    headerView.showUpgradeVersion()
                }
            }
        } else if let headerView = upgradeHeaderView  {
            self.addUpgradeView(headerView)
            self.startActivityLoading()
            PurchaseManager.shared.verifyAccountPro { (_, _) in
                DispatchQueue.main.async {[weak self] in
                    self?.stopActivityLoading()
                    if UserSession.shared.getSubscriptionFlag() != 1 {
                        headerView.showUpgradeVersion()
                    } else {
                        self?.removeUpgradeView()
                    }
                }
            }
        } else {
            self.getInfoReceipt()
        }
    }
    
    @objc func getInfoReceipt() {
        self.startActivityLoading()
        PurchaseManager.shared.verifyAccountPro { [weak self] (isPurchased, error) in
            DispatchQueue.main.async {[weak self] in
                self?.stopActivityLoading()
                let controller = SubscriptionViewController()
                controller.modalPresentationStyle = .fullScreen
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Public interface
extension DashboardView: DashboardViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DashboardView {
    var presenter: DashboardPresenter {
        return _presenter as! DashboardPresenter
    }
    var displayData: DashboardDisplayData {
        return _displayData as! DashboardDisplayData
    }
}
