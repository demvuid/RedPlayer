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

private let reviewAppStoreURLFormat = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%d&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
class SettingsPresenter: Presenter {
    var observerSelected: AnyObserver<SettingsFormFields> {
        return AnyObserver<SettingsFormFields>(eventHandler: { [weak self] event in
            switch event {
            case .next(let field):
                switch field {
                case .defaultURL:
                    self?.router.settingsDefaultURL()
                case .lock:
                    self?.router.settingLock()
                case .share:
                    self?.openSharingApp()
                case .email:
                    self?.openEmailAttached()
                case .review:
                    self?.openReview()
                default: break
                }
            default: break
            }
        })
    }
    
    func openSharingApp() {
        let textToShare = "AMPlayer by Hai Le"
        let urlStore = URL(string: "https://itunes.apple.com/us/app/amplayer/id1378163173?ls=1&mt=8")
        let objectToShare: [Any] = [textToShare, urlStore!]
        let activityController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        self._view.present(activityController, animated: true, completion: nil)
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
        let appStoreId = 1378163173
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
        mailCompose.setSubject("[\(appName!) \(appVersion!)] Suggestion")
        mailCompose.setMessageBody("Suggestion for \(appName!)", isHTML: true)
        mailCompose.setToRecipients(["amplayer.mobi@gmail.com"])
        return mailCompose
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
