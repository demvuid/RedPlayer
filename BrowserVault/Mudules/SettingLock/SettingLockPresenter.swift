//
//  SettingLockPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class SettingLockPresenter: Presenter {
    var changePassSubject: PublishSubject<()> = PublishSubject<()>()
    var authenticateSubject: PublishSubject<((Bool)->())> = PublishSubject<((Bool)->())>()
    private var bag = DisposeBag()
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.configSubscriber()
    }
    
    func configSubscriber() {
        self.changePassSubject.subscribe(onNext: {[weak self] _ in
            self?.router.changePass()
        }).disposed(by: self.bag)
        
        self.authenticateSubject.subscribe(onNext: {[weak self] (block) in
            self?.router.authenticatePasscodeWithCompletionBlock(block)
        }).disposed(by: self.bag)
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingLockPresenter {
    var view: SettingLockViewInterface {
        return _view as! SettingLockViewInterface
    }
    var interactor: SettingLockInteractor {
        return _interactor as! SettingLockInteractor
    }
    var router: SettingLockRouter {
        return _router as! SettingLockRouter
    }
}
