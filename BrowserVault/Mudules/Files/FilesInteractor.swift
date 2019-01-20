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
    
    func getMediasByFolder(_ folder: FolderModel) -> [Media] {
        return ModelManager.shared.fetchList(Media.self).filter({$0.folder?.id == folder.id})
    }
    
    func saveMedia(_ media: Media) {
        if !media.isVideo, let image = media.image {
            DocumentManager.shared.saveImage(image: image, to: media.photoURL!)
        }
        ModelManager.shared.addObject(media)
    }
    
    func deleteFolder(_ folder: FolderModel) {
        let medias = ModelManager.shared.fetchList(Media.self).filter({$0.folder?.id == folder.id})
        ModelManager.shared.deleteObjects(medias)
        DocumentManager.shared.deleteFolder(folder)
        ModelManager.shared.deleteObject(folder)
    }
    
    func importedMedias(_ medias: [Media], urls: [URL], inFolder folder: FolderModel? = nil, completionBlock: @escaping ([Media]) -> ()) {
        ModelManager.shared.subscriberAddMedias(medias, urls: urls, inFolder: folder, handler: completionBlock)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesInteractor {
    var presenter: FilesPresenter {
        return _presenter as! FilesPresenter
    }
}
