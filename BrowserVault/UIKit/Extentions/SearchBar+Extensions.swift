//
//  UISearchBar.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/9/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    var textColor:UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.textColor = newValue
            }
        }
    }
    
    var textFont:UIFont? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.font
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.font = newValue
            }
        }
    }
    
    var textField:UITextField? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField
            } else {
                return nil
            }
        }
    }
}
