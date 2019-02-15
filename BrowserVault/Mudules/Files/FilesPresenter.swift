//
//  FilesPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class FilesPresenter: Presenter {
    private var saveableMedias = [Media]()
    private var saveableFolder: FolderModel!
    private var countDetailFiles: Int = UserSession.shared.countDetailFolder
    var isAddFile: Bool {
        return self.saveableMedias.count > 0
    }
    let bag = DisposeBag()
    let folderSubject = PublishSubject<FolderModel>()
    
    lazy var handlerDeleteFolder = {[weak self] (folder: FolderModel) -> Void in
        self?.interactor.deleteFolder(folder)
    }
    
    
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.configSubscriber()
    }
    
    func configSubscriber() {
        folderSubject.subscribe(onNext: {[weak self] (folder) in
            guard let self = self else { return }
            if self.countDetailFiles >= 3 {
                self.countDetailFiles = 0
            } else {
                self.countDetailFiles += 1
            }
            UserSession.shared.countDetailFolder = self.countDetailFiles
            let handlerSelectFolder = {[weak self] in
                guard let self = self else {
                    return
                }
                self.saveableFolder = folder
                if self.saveableMedias.count > 0 {
                    for media in self.saveableMedias {
                        media.folder = folder
                    }
                    if self.saveableMedias.first?.temporaryPath != nil {
                        self.interactor.importedMedias(self.saveableMedias, inFolder: self.saveableFolder, completionBlock: { [weak self] (_) in
                            self?.view.reloadView()
                            self?.cancelScreen()
                        })
                    } else {
                        self.interactor.saveMedias(self.saveableMedias)
                        self.cancelScreen()
                    }
                } else if folder.medias.count > 0 {
                    self.openMediasByFolder(folder)
                } else {
                    var items = self.actionItemsAddFiles()
                    let item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
                    items.append(item)
                    self._view.showActionSheet(items: items)
                }
            }
            if !UserSession.shared.isUpgradedVersion() && self.countDetailFiles == 0 {
                NavigationManager.shared.handlerDismissAdvertisement = handlerSelectFolder
                self.view.showAdverstive()
            } else {
                handlerSelectFolder()
            }
        }).disposed(by: self.bag)
    }
    
    
    func actionItemsAddFiles() -> [AlertActionItem] {
        var items = [AlertActionItem]()
        var item = AlertActionItem(title: L10n.Folder.Download.File.library, style: .default, handler: {[weak self] (_) in
            self?.router.importFiles(completion: {[weak self] (result) in
                if self?.saveableFolder != nil {
                    self?.interactor.importedMedias(result, inFolder: self!.saveableFolder, completionBlock: { [weak self] (_) in
                        self?.view.reloadView()
                        self?.cancelScreen()
                        self?.openMediasByFolder(self!.saveableFolder)
                        self?.saveableFolder = nil
                    })
                } else {
                    self?.router.saveMedias(result)
                }
            })
        })
        items.append(item)
        item = AlertActionItem(title: L10n.Folder.Download.File.network, style: .default, handler: {[weak self] (_) in
            guard let self = self else { return }
            let module = AppModules.download.build()
            module.router.show(from: self._view, embedInNavController: true, setupData: self.saveableFolder)
        })
        items.append(item)
        return items
    }
    
    @objc func addFolder() {
        saveableFolder = nil
        var items = self.actionItemsAddFiles()
        var item = AlertActionItem(title: L10n.Folder.Browse.File.network, style: .default, handler: {[weak self] (_) in
            guard let self = self else { return }
            let module = AppModules.download.build()
            if let displayData = module.displayData as? DownloadDisplayData {
                displayData.browseType = .play
            }
            module.router.show(from: self._view, embedInNavController: true)
        })
        items.append(item)
        item = AlertActionItem(title: L10n.Folder.Add.folder, style: .default, handler: {[weak self] (_) in
            self?.router.addFolder()
        })
        items.append(item)
        
        item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
        items.append(item)
        self._view.showActionSheet(items: items)
    }
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
    
    func getListFolders() -> [FolderModel] {
        return self.interactor.getListFolders()
    }
    
    func openMediasByFolder(_ folder: FolderModel) {
        if folder.enablePasscode {
            self.router.openPasscodeWithCompletionBlock { finished in
                if finished {
                    DispatchQueue.main.async {[unowned self] in
                        self.router.openFolder(folder)
                    }
                }
            }
        } else {
            self.router.openFolder(folder)
        }
    }
    
    override func setupView(data: Any) {
        if let medias = data as? [Media] {
            self.saveableMedias.append(contentsOf: medias)
        }
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
