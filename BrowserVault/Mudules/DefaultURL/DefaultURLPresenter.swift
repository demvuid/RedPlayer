//
//  DefaultURLPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class DefaultURLPresenter: Presenter {
    var urlSubject = PublishSubject<String>()
    private var bag = DisposeBag()
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.configSubscriber()
    }
    
    func configSubscriber() {
        self.urlSubject.subscribe(onNext: {[weak self] (urlString) in
            var defaultURL: String = urlString.lowercased()
            if defaultURL.hasPrefix("http://") || defaultURL.hasPrefix("fpt://") || defaultURL.hasPrefix("https://") {
            } else {
                defaultURL = "http://\(defaultURL)"
            }
            if defaultURL.validURLString() {
                self?._view.defaultURLString = defaultURL
                self?._view.navigationController?.popViewController(animated: true)
            } else {
                self?._view.showAlertWith(title: L10n.Generic.Error.Alert.title, messsage: L10n.Settings.Browser.Url.required)
            }
        }).disposed(by: self.bag)
    }
    
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DefaultURLPresenter {
    var view: DefaultURLViewInterface {
        return _view as! DefaultURLViewInterface
    }
    var interactor: DefaultURLInteractor {
        return _interactor as! DefaultURLInteractor
    }
    var router: DefaultURLRouter {
        return _router as! DefaultURLRouter
    }
}
