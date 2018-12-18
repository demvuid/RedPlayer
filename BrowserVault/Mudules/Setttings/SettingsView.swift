//
//  SettingsView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import MessageUI

enum SettingsViewSections: Int
{
    case setting = 0
    case about
    case numberSections
}
enum SettingsViewRows: Int {
    case review = 0
    case share
    case email
    case about
}

//MARK: - Public Interface Protocol
protocol SettingsViewInterface {
}

//MARK: SettingsView Class
final class SettingsView: BaseUserInterface {
    
    lazy var settingForm: SettingsFormView = {
        var form = SettingsFormView(observerSelected: self.presenter.observerSelected)
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.title
        self.view.addSubview(self.settingForm.view)
        self.addChild(self.settingForm)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            self.showAlertWith(title: "Success", messsage: "The email has been sent successfully.")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
//MARK: - Public interface
extension SettingsView: SettingsViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingsView {
    var presenter: SettingsPresenter {
        return _presenter as! SettingsPresenter
    }
    var displayData: SettingsDisplayData {
        return _displayData as! SettingsDisplayData
    }
}
