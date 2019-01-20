//
//  ImportFilesView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/23/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol ImportFilesViewInterface {
}

//MARK: ImportFilesView Class
final class ImportFilesView: UserInterface {
}

//MARK: - Public interface
extension ImportFilesView: ImportFilesViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension ImportFilesView {
    var presenter: ImportFilesPresenter {
        return _presenter as! ImportFilesPresenter
    }
    var displayData: ImportFilesDisplayData {
        return _displayData as! ImportFilesDisplayData
    }
}
