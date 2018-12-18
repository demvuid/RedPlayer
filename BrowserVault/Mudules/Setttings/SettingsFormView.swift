//
//  SettingsFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Eureka
import RxSwift

enum SettingsFormFields: String {
    case defaultURL
    case lock
    case review
    case share
    case email
    case about
    case upgrade
    case restore
}

class SettingsFormView: BaseFormViewController {
    private var observerSelected: AnyObserver<SettingsFormFields>!
    
    convenience init(observerSelected: AnyObserver<SettingsFormFields>) {
        self.init(nibName: nil, bundle: nil)
        self.observerSelected = observerSelected
    }
    
    override func setupFormView() {
        form = Form()
            +++ Section(L10n.Settings.title)
            <<< LabelRow() {
                $0.title = L10n.Settings.Browser.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .disclosureIndicator
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.defaultURL)
                })
            <<< LabelRow() {
                $0.title = L10n.Settings.Lock.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .disclosureIndicator
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.lock)
                })
            
            +++ Section(L10n.Settings.Version.title)
            <<< LabelRow() {
                $0.title = L10n.Settings.Version.upgrade
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.upgrade)
                })
            <<< LabelRow() {
                $0.title = L10n.Settings.Version.restore
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.restore)
                })
            
            +++ Section(L10n.Settings.Help.title)
            <<< LabelRow() {
                $0.title = L10n.Settings.Review.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.review)
                })
            <<< LabelRow() {
                $0.title = L10n.Settings.Share.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.share)
                })
            <<< LabelRow() {
                $0.title = L10n.Settings.Email.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.email)
                })
            <<< LabelRow() {
                $0.title = L10n.Settings.About.title
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .disclosureIndicator
                }).onCellSelection({[weak self] (_, _) in
                    self?.observerSelected.onNext(.about)
                })
    }

}
