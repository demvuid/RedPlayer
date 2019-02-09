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
        folder.lastPathImage = url?.lastPathComponent
        ModelManager.shared.addObject(folder)
    }
    
    func saveMedia(_ media: Media!, inFolder folder: FolderModel) {
        if let folder = ModelManager.shared.fetchObject(FolderModel.self, filter: NSPredicate(format: "id == %@", folder.id)) {
            media?.folder = folder
        } else {
            self.addFolder(folder)
            media?.folder = ModelManager.shared.fetchObject(FolderModel.self, filter: NSPredicate(format: "id == %@", folder.id))
        }
        
        if let media = media {
            if !media.isVideo, let image = media.image {
                DocumentManager.shared.saveImage(image: image, to: media.photoURL!)
            }
            ModelManager.shared.addObject(media)
        }
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FolderInteractor {
    var presenter: FolderPresenter {
        return _presenter as! FolderPresenter
    }
}
