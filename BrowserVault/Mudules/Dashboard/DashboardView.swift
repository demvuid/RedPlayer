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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(tabBarView)
        view.addSubview(tabBarView.view)
        self.startCheckingReceipt()
        
        // Request to rate or/and write a review on 3rd, 20th app launches & repeat for every 100th app launch
        let appLaunchInterval = RequestInterval(first: 3, second: 10, repeatEvery: 100)
        let appLaunchRule = RequestReviewRule(ruleType: .appLaunches, requestInterval: appLaunchInterval)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(3))) {
            ReviewManager.default.requestReview(for: appLaunchRule)
        }
    }
    
    func startCheckingReceipt() {
        if PurchaseManager.shared.isProVersion() == false {
            if let headerView = Bundle.main.loadNibNamed("UpgradePlusView", owner: nil, options: nil)?.first as? UpgradePlusView  {
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
                headerView.layer.borderWidth = 1
                headerView.layer.borderColor = UIColor.lightGray.cgColor
                headerView.layer.cornerRadius = 5.0
                
                self.tabBarView.view.snp.makeConstraints { (make) in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
                
                PurchaseManager.shared.observerUpgradeVersion {[weak self] in
                    if PurchaseManager.shared.isProVersion() == true {
                        guard let self = self else {
                            return
                        }
                        if self.isUpgradedPro == false {
                            self.isUpgradedPro = true
                            self.tabBarView.view.removeConstraints(self.tabBarView.view.constraints)
                            self.tabBarView.view.snp.makeConstraints { (make) in
                                make.leading.trailing.top.bottom.equalToSuperview()
                            }
                            headerView.removeFromSuperview()
                        }
                    }
                }
                
                PurchaseManager.shared.observerGettingSubscription {[weak headerView] in
                    if PurchaseManager.shared.isProVersion() == false {
                        headerView?.showUpgradeVersion()
                    }
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(getInfoReceipt))
                tapGesture.numberOfTapsRequired = 1
                headerView.addGestureRecognizer(tapGesture)
                
                if PurchaseManager.shared.shouldGettingVersion() == false {
                    self.startActivityLoading()
                    PurchaseManager.shared.verifyAccountPro { (_, _) in
                        DispatchQueue.main.async {[weak self] in
                            self?.stopActivityLoading()
                        }
                    }
                }
            } else {
                self.getInfoReceipt()
            }
        } else {
            self.startActivityLoading()
            PurchaseManager.shared.verifyAccountPro { (_, _) in
                DispatchQueue.main.async {[weak self] in
                    self?.stopActivityLoading()
                }
            }
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
