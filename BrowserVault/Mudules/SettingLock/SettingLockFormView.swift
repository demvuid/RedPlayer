//
//  SettingLockFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Eureka
import RxSwift

class SettingLockFormView: BaseFormViewController {
    private var changePassSubject: PublishSubject<()>!
    
    convenience init(changePassSubject: PublishSubject<()>) {
        self.init(nibName: nil, bundle: nil)
        self.changePassSubject = changePassSubject
    }
    
    override func setupFormView() {
        form = Form()
        let section = Section()
        section <<< SwitchRow() {
                    $0.title = L10n.Settings.Lock.Passcode.active
                    $0.value = UserSession.shared.enabledPasscode()
                }.onChange({[unowned self] (row) in
                    UserSession.shared.enablePasscode(row.value ?? true)
                    let clearChangePassRow = {
                        if let index = row.indexPath?.row, row.section!.count > index + 1 {
                            row.section?.remove(at: index + 1)
                        }
                    }
                    clearChangePassRow()
                    if UserSession.shared.enabledPasscode(), let index = row.indexPath?.row {
                        row.section?.insert(self.changePassRow(), at: index + 1)
                    }
                })
        
        if UserSession.shared.enabledPasscode() {
            section <<< self.changePassRow()
        }
        form +++ section
    }
    
    private func changePassRow() -> LabelRow {
        return LabelRow() {
                $0.title = L10n.Settings.Lock.Passcode.change
            }.onCellSelection({[weak self] (_, _) in
                self?.changePassSubject.onNext(())
            })
    }

}
