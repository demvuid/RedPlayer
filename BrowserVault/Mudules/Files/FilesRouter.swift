//
//  FilesRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import DKImagePickerController

class FilesRouter: Router {
    func addFolder() {
        let module = AppModules.folder.build()
        module.router.show(from: self._view, embedInNavController: true)
    }
    
    func importFiles(completion: @escaping (ImportMediasResult)->()) {
        CustomImagePickerController.presentPickerInTarget(self._view) { (result) in
            completion(result)
        }
    }
    
    func openPasscodeWithCompletionBlock(_ block: ((Bool)->())?) {
        if UserSession.shared.enabledPasscode() {
            let entryModule = AppModules.passcode.build()
            entryModule.router.show(from: self._view, embedInNavController: true, setupData: block)
        } else {
            block?(true)
        }
    }
    
    func cancelScreen() {
        self._view.dismiss(animated: true, completion: nil)
    }
    
    func openFolder(_ folder: FolderModel) {
        let displayActionButton = true
        let displaySelectionButtons = false
        let displayMediaNavigationArrows = true
        let enableGrid = true
        let startOnGrid = true
        let autoPlayOnAppear = false
        
        
        let browser = MediaBrowser(folder: folder)
        browser.displayActionButton = displayActionButton
        browser.displayMediaNavigationArrows = displayMediaNavigationArrows
        browser.displaySelectionButtons = displaySelectionButtons
        browser.alwaysShowControls = displaySelectionButtons
        browser.zoomPhotosToFill = true
        browser.enableGrid = enableGrid
        browser.startOnGrid = startOnGrid
        browser.enableSwipeToDismiss = true
        browser.autoPlayOnAppear = autoPlayOnAppear
        browser.cachingImageCount = 1
        browser.setCurrentIndex(at: 0)
        browser.navigationBarTintColor = ColorName.navigationBarColor
        browser.navigationBarTextColor = ColorName.navigationBarTitleColor
        self._view.navigationController?.pushViewController(browser, animated: true)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesRouter {
    var presenter: FilesPresenter {
        return _presenter as! FilesPresenter
    }
}
