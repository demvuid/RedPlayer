//
//  PasscodeView.swift
//  LifeSite
//
//  Created by Thanh Duong on 6/21/18.
//Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
import Viperit
import SnapKit

//MARK: - Public Interface Protocol
protocol PasscodeViewInterface {
    func configTextField(textField: PasscodelField, numberOfDigits: Int)
    func setupEnterPasscode()
    func setupCreatePasscode()
    func setupVerifyPasscode()
    func configUI()
    func updateConfigPass(data: Any)
}

//MARK: PasscodeView Class
final class PasscodeView: UserInterface {
    private var isChangePass: Bool = false
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var createField: PasscodelField!
    @IBOutlet weak var verifyField: PasscodelField!
    @IBOutlet weak var enterField: PasscodelField!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var enterView: UIView!
    @IBOutlet weak var changeDigitsButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var createPasscodeLabel: UILabel!
    @IBOutlet weak var createPasscodeDesLabel: UILabel!
    @IBOutlet weak var verifyPasscodeLabel: UILabel!
    @IBOutlet weak var enterPasscodeLabel: UILabel!
    private lazy var backgroundImage: UIImageView = UIImageView(frame: .zero)

    var numberOfDigits = 4 {
        didSet {
          presenter.configTextField(textField: createField, numberOfDigits: numberOfDigits)
            if numberOfDigits == 4 {
                changeDigitsButton.setTitle(L10n.Passcode.change6digit, for: .normal)
            } else {
                changeDigitsButton.setTitle(L10n.Passcode.change4digit, for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isChangePass {
            self.navigationItem.title = L10n.Settings.Lock.Passcode.change
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
        } else if self.presenter.completionBlock != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
            if UserSession.shared.decryptedPasscode() != nil {
                self.navigationItem.title = L10n.Passcode.Authenticate.passcode
            } else {
                self.navigationItem.title = L10n.Passcode.create
            }
        }
    }
    
    @IBAction func forgotPasscodeHandle(_ sender: Any) {
        presenter.authenticateUser()
    }
    
    @IBAction func changeDigitsHandle(_ sender: Any) {
        if numberOfDigits == 4 {
            numberOfDigits = 6
        } else {
            numberOfDigits = 4
        }
    }
    
    internal func configUI() {
        self.view.insertSubview(self.backgroundImage, at: 0)
        self.backgroundImage.snp.makeConstraints {[unowned self] (make) in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        self.backgroundImage.backgroundColor = ColorName.backgroundColorFirst
        self.createView.backgroundColor = .clear
        self.verifyView.backgroundColor = .clear
        self.enterView.backgroundColor = .clear
        
        self.createField.backgroundColor = .clear
        self.verifyField.backgroundColor = .clear
        self.enterField.backgroundColor = .clear
        
        if AuthenticationManager.shared.isDeviceSupportBiometry == nil {
            if AuthenticationManager.shared.isSupportFaceId {
                self.forgotButton.setTitle(L10n.Passcode.Biometry.faceid, for: .normal)
            } else {
                self.forgotButton.setTitle(L10n.Passcode.Biometry.touchid, for: .normal)
            }
            self.forgotButton.isHidden = !UserSession.shared.enabledTouchID()
        } else {
            self.forgotButton.isHidden = true
        }
        self.createPasscodeLabel.text = L10n.Passcode.create
        self.createPasscodeDesLabel.text = L10n.Passcode.Create.description(Bundle.main.displayName)
        self.verifyPasscodeLabel.text = L10n.Passcode.Create.verify
        self.enterPasscodeLabel.text = L10n.Passcode.Create.enter
        
        self.createPasscodeLabel.textColor = ColorName.whiteColor
        self.createPasscodeDesLabel.textColor = ColorName.whiteColor
        self.verifyPasscodeLabel.textColor = ColorName.whiteColor
        self.enterPasscodeLabel.textColor = ColorName.whiteColor
        
        let passcodeSave = presenter.getPasscode()
        if passcodeSave.count > 0 && self.isChangePass == false {
            self.numberOfDigits = passcodeSave.count
            presenter.setupEnterPasscode()
        } else {
            presenter.setupCreatePasscode()
        }
    }
}

//MARK: - Public interface
extension PasscodeView: PasscodeViewInterface, PasscodelFieldDelegate {
    func updateConfigPass(data: Any) {
        if let isChangePass = data as? Bool {
            self.isChangePass = isChangePass
        }
    }
    
    func configTextField(textField: PasscodelField, numberOfDigits: Int) {
        textField.isSecureTextEntry = true
        textField.numberOfDigits = numberOfDigits
        textField.becomeFirstResponder()
        textField.delegate = self
    }
    
    func setupCreatePasscode() {
        self.createView.isHidden = false
        self.verifyView.isHidden = true
        self.enterView.isHidden = true
        resetAllInput()
        self.configTextField(textField: self.createField, numberOfDigits: self.numberOfDigits)
    }
    
    func setupEnterPasscode() {
        self.createView.isHidden = true
        self.verifyView.isHidden = true
        self.enterView.isHidden = false
        resetAllInput()
        self.configTextField(textField: self.enterField, numberOfDigits: self.numberOfDigits)
    }
    
    func setupVerifyPasscode() {
        self.createView.isHidden = true
        self.verifyView.isHidden = false
        self.enterView.isHidden = true
        resetAllInput()
        self.configTextField(textField: self.verifyField, numberOfDigits: self.numberOfDigits)
    }
    
    func resetAllInput() {
        self.createField.resignFirstResponder()
        self.verifyField.resignFirstResponder()
        self.enterField.resignFirstResponder()
        self.createField.passcode = ""
        self.verifyField.passcode = ""
        self.enterField.passcode = ""
    }
    
    func didFullText(with textField: PasscodelField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if textField == self.createField {
                self.displayData.inputPasscode = textField.passcode
                self.setupVerifyPasscode()
            }
            
            if textField == self.verifyField {
                if textField.passcode == self.displayData.inputPasscode {
                    self.presenter.savePasscode(passcode: textField.passcode)
                    textField.resignFirstResponder()
                    self.presenter.verifiedPasscode()
                } else {
                    
                    self.createField.passcode = ""
                    self.showAlertWith(title: L10n.Generic.Error.Alert.title, message: L10n.Passcode.notmatch, cancelTitle: L10n.Generic.Button.Title.ok, cancelBlock: { (alertAction) in
                        self.setupCreatePasscode()
                    })
                }
            }
            if textField == self.enterField {
                let passcodeSave = self.presenter.getPasscode()
                if textField.passcode == passcodeSave {
                    textField.resignFirstResponder()
                    self.presenter.verifiedPasscode()
                } else {
                    self.presenter.presentAlert(title: L10n.Generic.Error.Alert.title, message: L10n.Passcode.notmatch)
                    textField.passcode = ""
                }
            }
        }
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PasscodeView {
    var presenter: PasscodePresenter {
        return _presenter as! PasscodePresenter
    }
    var displayData: PasscodeDisplayData {
        return _displayData as! PasscodeDisplayData
    }
}
