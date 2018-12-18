//
//  FolderPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class FolderPresenter: Presenter {
    var folderSubject = PublishSubject<FolderModel>()
    private var bag = DisposeBag()
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.configSubscriber()
    }
    
    func configSubscriber() {
        self.folderSubject.subscribe(onNext: {[weak self] (folder) in
            self?.interactor.addFolder(folder)
            self?.cancelScreen()
        }).disposed(by: self.bag)
    }
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FolderPresenter {
    var view: FolderViewInterface {
        return _view as! FolderViewInterface
    }
    var interactor: FolderInteractor {
        return _interactor as! FolderInteractor
    }
    var router: FolderRouter {
        return _router as! FolderRouter
    }
}
