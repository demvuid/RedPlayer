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
    private var saveableMedias = [Media]()
    var isAddFile: Bool {
        return self.saveableMedias.count > 0
    }
    
    var folderSubject = PublishSubject<FolderModel>()
    private var bag = DisposeBag()
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.configSubscriber()
    }
    
    func configSubscriber() {
        self.folderSubject.subscribe(onNext: {[weak self] (folder) in
            self?.interactor.saveMedias(self!.saveableMedias, inFolder: folder)
            self?.cancelScreen()
        }).disposed(by: self.bag)
    }
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
    
    override func setupView(data: Any) {
        if let medias = data as? [Media] {
            self.saveableMedias.append(contentsOf: medias)
        }
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
