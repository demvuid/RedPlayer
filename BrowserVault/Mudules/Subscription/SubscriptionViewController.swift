//
//  SubscriptionViewController.swift
//  BrowserVault
//
//  Created by Hai Le on 03/03/2021.
//  Copyright © 2021 GreenSolution. All rights reserved.
//

import UIKit
import SafariServices

let upgradeAccountDescription = """
Now upgrade to Plus by clicking Buy the "Plus Monthly" subscription. You will get more features and support from our team.
"""
let startTrialPeridText = """
You will not be charged until 1 month free trial expires. You can cancel your subscription at any time.
"""
class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet {
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var tutorial1: UIImageView!
    
    @IBOutlet weak var tutorial2: UIImageView!
    
    @IBOutlet weak var tutorial3: UIImageView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var subscriptionDescriptionLabel: UILabel!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var purchasedView: UIView!
    @IBOutlet weak var termsAndPrivacyButton: UIButton!
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupItemScrollView()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
        // Do any additional setup after loading the view.
        if UserSession.shared.getSubscriptionFlag() == 1 {
            self.purchasedView.isHidden = false
            if let validDate = PurchaseManager.shared.validDate {
                let dateFormmat = DateFormatter()
                dateFormmat.dateFormat = "MMM, dd YYYY"
                let dateString = dateFormmat.string(from: validDate)
                if PurchaseManager.shared.isTrialPeriod == true {
                    self.subscriptionDescriptionLabel.text = "Your subscription is in the free trial period.\nThe subscription is valid until \(dateString)"
                } else {
                    self.subscriptionDescriptionLabel.text = "Welcome to BrowserVault Plus.\nThe subscription is valid until \(dateString)"
                }
            }
            self.nextButton.setTitle("Done", for: .normal)
        } else {
            if let date = PurchaseManager.shared.expiredDate {
                let dateFormmat = DateFormatter()
                dateFormmat.dateFormat = "MMM, dd YYYY"
                let dateString = dateFormmat.string(from: date)
                let periodExpiredText = "Your subscription has expired since \(dateString)."
                self.subscriptionDescriptionLabel.text = "\(upgradeAccountDescription)\n\(periodExpiredText)"
            } else {
                self.subscriptionDescriptionLabel.text =  "\(upgradeAccountDescription)\n\(startTrialPeridText)"
            }
            self.subscribeButton.layer.borderColor = UIColor.gray.cgColor
            self.subscribeButton.layer.cornerRadius = 5.0
            self.subscribeButton.addTarget(self, action: #selector(upgradeProVersion), for: .touchUpInside)
            self.restorePurchaseButton.addTarget(self, action: #selector(restorePurchase), for: .touchUpInside)
            self.termsAndPrivacyButton.addTarget(self, action: #selector(openTermsAndPrivacy), for: .touchUpInside)
        }
        self.nextButton.addTarget(self, action: #selector(skipUpgradeProVersion), for: .touchUpInside)
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    func setupItemScrollView() {
        if let widthConstraint = self.tutorial1.constraints.first(where: {($0.firstItem as? UIView) == self.tutorial1 && $0.firstAttribute == NSLayoutConstraint.Attribute.width}) {
            self.tutorial1.removeConstraint(widthConstraint)
        }
        if let widthConstraint = self.tutorial2.constraints.first(where: {($0.firstItem as? UIView) == self.tutorial2 && $0.firstAttribute == NSLayoutConstraint.Attribute.width}) {
            self.tutorial2.removeConstraint(widthConstraint)
        }
        if let widthConstraint = self.tutorial3.constraints.first(where: {($0.firstItem as? UIView) == self.tutorial3 && $0.firstAttribute == NSLayoutConstraint.Attribute.width}) {
            self.tutorial3.removeConstraint(widthConstraint)
        }
        
        let width = UIScreen.main.bounds.width
        self.tutorial1.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        self.tutorial2.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        self.tutorial3.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
    }

    @objc func changePage() {
        let page = self.pageControl.currentPage
        let width = UIScreen.main.bounds.width
        let offset = CGPoint(x: CGFloat(page) * width, y: 0)
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func upgradeProVersion() {
        self.startActivityLoading()
        PurchaseManager.shared.upgradeToProVersion { (message) in
            DispatchQueue.main.async {[weak self] in
                self?.stopActivityLoading()
                if let message = message {
                    self?.showAlertWith(title: message.title, messsage: message.message)
                } else {
                    self?.skipUpgradeProVersion()
                    self?.showAlertWith(title: L10n.Generic.success, messsage: L10n.Purchase.Store.sucesss)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {[weak self] in
                        self?.skipUpgradeProVersion()
                    }
                }
            }
        }
    }
    
    @objc func skipUpgradeProVersion() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func restorePurchase() {
        self.startActivityLoading()
        PurchaseManager.shared.restorePurchases { [weak self] (success, message) in
            self?.stopActivityLoading()
            self?.showAlertWith(title: message.title, message: message.message, cancelTitle: L10n.Generic.Button.Title.ok, cancelBlock: { [weak self] (_) in
                self?.skipUpgradeProVersion()
            })
        }
    }
    
    @objc func openTermsAndPrivacy() {
        let path = Bundle.main.url(forResource: "index", withExtension: "html")
        guard let url = path else {
            return
        }
        let controller = WebViewController(localURL: url)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }

}

extension SubscriptionViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SubscriptionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
