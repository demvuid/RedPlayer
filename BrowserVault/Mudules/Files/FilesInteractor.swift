//
//  FilesInteractor.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class FilesInteractor: Interactor {
    func getListFolders() -> [FolderModel] {
        return ModelManager.shared.fetchList(FolderModel.self)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesInteractor {
    var presenter: FilesPresenter {
        return _presenter as! FilesPresenter
    }
}
