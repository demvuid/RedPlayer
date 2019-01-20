//
//  DownloadPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class DownloadPresenter: Presenter {
    var observableURL: AnyObserver<URL?> {
        return AnyObserver<URL?>(eventHandler: { [weak self] event in
            switch event {
            case .next(let url):
                if let url = url, url.absoluteString.isValidURL {
                    
                } else {
                    self?._view.showAlertWith(title: L10n.Generic.Error.Alert.title, messsage: L10n.Settings.Browser.Url.required)
                }
            default: break
            }
        })
    }
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
    
    override func setupView(data: Any) {
        
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadPresenter {
    var view: DownloadViewInterface {
        return _view as! DownloadViewInterface
    }
    var interactor: DownloadInteractor {
        return _interactor as! DownloadInteractor
    }
    var router: DownloadRouter {
        return _router as! DownloadRouter
    }
}
