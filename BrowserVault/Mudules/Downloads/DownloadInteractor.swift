//
//  DownloadInteractor.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class DownloadInteractor: Interactor {
    func importedMedias(_ medias: [Media], inFolder folder: FolderModel? = nil, completionBlock: @escaping ([Media]) -> ()) {
        ModelManager.shared.subscriberAddMedias(medias, inFolder: folder, handler: completionBlock)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadInteractor {
    var presenter: DownloadPresenter {
        return _presenter as! DownloadPresenter
    }
}
