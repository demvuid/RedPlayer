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
    var authenticatePassSubject: PublishSubject<((Bool)->())>!
    
    convenience init(changePassSubject: PublishSubject<()>) {
        self.init(nibName: nil, bundle: nil)
        self.changePassSubject = changePassSubject
    }
    
    override func setupFormView() {
        form = Form()
        let section = Section()
        section <<< self.enablePasscodeRow()
        if UserSession.shared.enabledPasscode() {
            section <<< self.changePassRow()
        }
        form +++ section
    }
    
    private func enablePasscodeRow() -> SwitchRow {
        let session = UserSession.shared
        return SwitchRow() {
            $0.tag = L10n.Settings.Lock.Passcode.active
            $0.title = L10n.Settings.Lock.Passcode.active
            $0.value = session.enabledPasscode()
            }.cellUpdate({ (cell, _) in
                cell.switchControl?.onTintColor = ColorName.mainColor
                cell.switchControl?.tintColor = ColorName.mainColor
            }).onChange({[unowned self] (row) in
                let disablePasscodeBlock = { (finished: Bool) in
                    if finished {
                        session.clearPasscode()
                        session.enablePasscode(false)
                        if let index = row.indexPath?.row, row.section!.count > index + 1 {
                            row.section?.remove(at: index + 1)
                        }
                    } else {
                        row.section?.replaceSubrange(row.indexPath!.row..<row.indexPath!.row+1, with: [self.enablePasscodeRow()])
                    }
                }
                let enablePasscodeBlock = { (finished: Bool) in
                    if finished {
                        session.enablePasscode(true)
                        if let index = row.indexPath?.row, row.section!.count == index + 1 {
                            row.section?.insert(self.changePassRow(), at: index + 1)
                        }
                    } else {
                        row.section?.replaceSubrange(row.indexPath!.row..<row.indexPath!.row+1, with: [self.enablePasscodeRow()])
                    }
                }
                if row.value == false {
                    if session.enabledPasscode() == true {
                        self.authenticatePassSubject.onNext(disablePasscodeBlock)
                    } else {
                        disablePasscodeBlock(false)
                    }
                } else {
                    if session.enabledPasscode() == true {
                        enablePasscodeBlock(false)
                    } else {
                        self.authenticatePassSubject.onNext(enablePasscodeBlock)
                    }
                }
            })
    }
    
    private func changePassRow() -> LabelRow {
        return LabelRow() {
                $0.tag = L10n.Settings.Lock.Passcode.change
                $0.title = L10n.Settings.Lock.Passcode.change
            }.onCellSelection({[weak self] (_, _) in
                self?.changePassSubject.onNext(())
            })
    }

}
