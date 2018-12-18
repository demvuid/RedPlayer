//
//  FilesPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class FilesPresenter: Presenter {
    @objc func addFolder() {
        self.router.addFolder()
    }
    
    func getListFolders() -> [FolderModel] {
        return self.interactor.getListFolders()
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesPresenter {
    var view: FilesViewInterface {
        return _view as! FilesViewInterface
    }
    var interactor: FilesInteractor {
        return _interactor as! FilesInteractor
    }
    var router: FilesRouter {
        return _router as! FilesRouter
    }
}
