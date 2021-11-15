//
//  SettingsPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift
import MessageUI
import StoreKit

private let reviewAppStoreURLFormat = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%d&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
class SettingsPresenter: Presenter {
    override func viewHasLoaded() {
        super.viewHasLoaded()
//        PurchaseManager.shared.observerFallback {
//
//        }
    }
    var observerSelected: AnyObserver<SettingsFormFields> {
        return AnyObserver<SettingsFormFields>(eventHandler: { [weak self] event in
            switch event {
            case .next(let field):
                switch field {
                case .defaultURL:
                    self?.router.settingsDefaultURL()
                case .lock:
                    self?.router.settingLock()
                case .touchID:
                    UserSession.shared.enableTouchID(!UserSession.shared.enabledTouchID())
                case .share:
                    self?.openSharingApp()
                case .email:
                    self?.openEmailAttached()
                case .review:
                    self?.openReview()
                case .upgrade:
                    self?._view.startActivityLoading()
                    self?.interactor.purchaseApp()
                case .restore:
                    self?._view.startActivityLoading()
                    self?.interactor.restoreApp()
                case .about:
                    self?._view.performSegue(withIdentifier: "about_app", sender: nil)
                case .manageSubscriptions:
                    self?.getSubscriptions()
                case .privacy:
                    self?.openTermsAndPrivacy()
                case .moreapp:
                    self?.openMoreApp()
                }
            default: break
            }
        })
    }
    
    func openSharingApp() {
        let textToShare = "BrowserVault by Hai Le"
        let urlStore = URL(string: "https://itunes.apple.com/us/app/browservault/id1450071905?ls=1&mt=8")
        let objectToShare: [Any] = [textToShare, urlStore!]
        let activityController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        self._view.present(activityController, animated: true, completion: nil)
    }
    
    func openMoreApp() {
        let storeProduct = SKStoreProductViewController()
        storeProduct.delegate = self._view as? SKStoreProductViewControllerDelegate
        storeProduct.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: "910797320"], completionBlock: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(storeProduct, animated: true, completion: nil)
    }
    
    func openEmailAttached() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = self.configuredMailComposeViewController()
            self._view.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self._view.showAlertWith(title: "Could not send email", messsage: "Your device could not send e-email. Please check e-mail configuration and try again.")
        }
    }
    
    func openReview() {
        let appStoreId = 1450071905
        let reviewAppStorePath: String = String(format: reviewAppStoreURLFormat, appStoreId)
        let application = UIApplication.shared
        if let urlAppStore = URL(string: reviewAppStorePath), (application.canOpenURL(urlAppStore)) {
            if #available(iOS 10.0, *) {
                application.open(urlAppStore, options: [:], completionHandler: nil)
            } else {
                application.openURL(urlAppStore)
            }
        } else {
            self._view.showAlertWith(errorString: "Cannot open the reviewing URL \(reviewAppStorePath)")
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailCompose = MFMailComposeViewController()
        if let delegate = self._view as? SettingsView {
            mailCompose.mailComposeDelegate = delegate
        }
        let appName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let device_id = UserSession.shared.getDeviceId()
        mailCompose.setSubject("[\(appName!) \(appVersion!) ][\(device_id.lowercased())][Vip \(UserSession.shared.getSubscriptionFlag())] Suggestion")
        mailCompose.setToRecipients(["browservault.help@gmail.com"])
        return mailCompose
    }
    
    func alertError(_ error: Error) {
        self._view.stopActivityLoading()
        self._view.showAlertWith(errorString: error.localizedDescription)
//        if !PurchaseManager.shared.ignoreError(error) {
//            self._view.showAlertWith(errorString: error.localizedDescription)
//        }
    }
    
    func purchasedApp() {
        self._view.stopActivityLoading()
        self._view.showAlertWith(title: L10n.Generic.success, messsage: L10n.Purchase.Store.sucesss)
    }
    
    func restorePurchasedApp() {
        self._view.stopActivityLoading()
        self._view.showAlertWith(title: L10n.Generic.success, messsage: L10n.Restore.Purchase.sucesss)
    }
    
    func getSubscriptions() {
        self._view.startActivityLoading()
        PurchaseManager.shared.verifyAccountPro { [weak self] (isPurchased, error) in
            DispatchQueue.main.async {[weak self] in
                self?._view.stopActivityLoading()
                let controller = SubscriptionViewController()
                controller.modalPresentationStyle = .fullScreen
                self?._view.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func openTermsAndPrivacy() {
        let path = Bundle.main.url(forResource: "index", withExtension: "html")
        guard let url = path else {
            return
        }
        let controller = WebViewController(localURL: url)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        self._view.present(navController, animated: true, completion: nil)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingsPresenter {
    var view: SettingsViewInterface {
        return _view as! SettingsViewInterface
    }
    var interactor: SettingsInteractor {
        return _interactor as! SettingsInteractor
    }
    var router: SettingsRouter {
        return _router as! SettingsRouter
    }
}
