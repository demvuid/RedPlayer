//
//  FolderInteractor.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class FolderInteractor: Interactor {
    func addFolder(_ folder: FolderModel) {
        let url = DocumentManager.shared.saveCoverFolder(folder)
        folder.lastPathImage = url?.absoluteString.replacingOccurrences(of: documentPathURL.absoluteString, with: "")
        ModelManager.shared.addObject(folder)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FolderInteractor {
    var presenter: FolderPresenter {
        return _presenter as! FolderPresenter
    }
}
