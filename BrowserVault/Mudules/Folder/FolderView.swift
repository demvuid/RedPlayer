//
//  FolderView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol FolderViewInterface {
}

//MARK: FolderView Class
final class FolderView: UserInterface {
    lazy var settingForm: FolderFormView = {
        var form = FolderFormView(folderSubject: self.presenter.folderSubject)
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Folder.Create.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
        self.view.addSubview(self.settingForm.view)
        self.addChild(self.settingForm)
    }
}

//MARK: - Public interface
extension FolderView: FolderViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FolderView {
    var presenter: FolderPresenter {
        return _presenter as! FolderPresenter
    }
    var displayData: FolderDisplayData {
        return _displayData as! FolderDisplayData
    }
}
