//
//  UIViewController+Extensions.swift
//  LifeSite
//
//  Created by Hai Le on 6/5/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import IQKeyboardManagerSwift

typealias BlockVoid =  (_ action: UIAlertAction?) -> Void

extension UIViewController {
    func showAlertWith(errorString: String) {
        self.showAlertWith(title: L10n.Generic.Error.Alert.title, message: errorString, cancelTitle: L10n.Generic.Button.Title.ok, cancelBlock: nil, actionTitle: nil, actionBlock: nil, destrucionTitle: nil, destructionBlock: nil)
    }
    
    func showAlertWith(title: String, messsage: String) {
        self.showAlertWith(title: title, message: messsage, cancelTitle: L10n.Generic.Button.Title.ok, cancelBlock: nil, actionTitle: nil, actionBlock: nil, destrucionTitle: nil, destructionBlock: nil)
    }
    
    func showAlertWith(title: String? = nil, message: String? = nil, cancelTitle: String! = nil, cancelBlock: BlockVoid! = nil, actionTitle: String! = L10n.Generic.Button.Title.ok, actionBlock: BlockVoid! = nil, destrucionTitle: String! = nil, destructionBlock: BlockVoid! = nil)  {
        var cancelAction: UIAlertAction!
        var actionAction: UIAlertAction!
        var destructiveAction: UIAlertAction!
        
        let confirmAlertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelBlock)
            confirmAlertController.addAction(cancelAction)
        }
        
        if actionTitle != nil {
            actionAction = UIAlertAction(title: actionTitle, style: .`default`, handler: actionBlock)
            confirmAlertController.addAction(actionAction)
        }
        
        if destrucionTitle != nil {
            destructiveAction = UIAlertAction(title: destrucionTitle, style: .destructive, handler: destructionBlock)
            confirmAlertController.addAction(destructiveAction)
        }
        
        self .present(confirmAlertController, animated: true, completion: nil)
    }
    
    func showActionWith(title: String?, message: String?, cancelTitle: String! = nil, cancelBlock: BlockVoid! = nil, actionTitle: String! = nil, actionBlock: BlockVoid! = nil, destrucionTitle: String! = nil, destructionBlock: BlockVoid! = nil)  {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.showAlertWith(title: title, message: message, cancelTitle: cancelTitle, cancelBlock: cancelBlock, actionTitle: actionTitle, actionBlock: actionBlock, destrucionTitle: destrucionTitle, destructionBlock: destructionBlock)
            return
        }
        var cancelAction: UIAlertAction!
        var actionAction: UIAlertAction!
        var destructiveAction: UIAlertAction!
        
        let confirmAlertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelBlock)
            confirmAlertController.addAction(cancelAction)
        }
        
        if actionTitle != nil {
            actionAction = UIAlertAction(title: actionTitle, style: .`default`, handler: actionBlock)
            confirmAlertController.addAction(actionAction)
        }
        
        if destrucionTitle != nil {
            destructiveAction = UIAlertAction(title: destrucionTitle, style: .destructive, handler: destructionBlock)
            confirmAlertController.addAction(destructiveAction)
        }
        confirmAlertController.view.tintColor = ColorName.iconTintColor
        self.present(confirmAlertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    var defaultURLString: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: BrowserDefaultURLKey)
            UserDefaults.standard.synchronize()
        }
        get {
            var defaultURLString = UserDefaults.standard.value(forKey: BrowserDefaultURLKey) as? String
            if defaultURLString == nil {
                defaultURLString = BrowserDefaultURL
                UserDefaults.standard.set(defaultURLString, forKey: BrowserDefaultURLKey)
                UserDefaults.standard.synchronize()
            }
            return defaultURLString
        }
    }
    func startActivityLoading() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = .indeterminate
    }
    
    func stopActivityLoading() {
        self.stopActivityLoading(true)
    }
    
    func stopActivityLoading(_ animated: Bool) {
        MBProgressHUD.hide(for: self.view, animated: animated)
    }
    
    func enableManagementKeyboard(_ enable: Bool) {
        IQKeyboardManager.shared.enable = enable
    }
}
