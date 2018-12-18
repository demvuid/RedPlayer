//
//  String+Extentions.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
enum RegExprPattern: String {
    case emailAddress = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
    case url = "((https|http|ftp)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+([/?#]\\S*)?"
    case containsNumber = ".*\\d.*"
    case containsCapital = "^.*?[A-Z].*?$"
    case containsLowercase = "^.*?[a-z].*?$"
}

extension String {
    static func isValid(value: String?, regExpr: RegExprPattern) -> Bool {
        if let value = value, !value.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regExpr.rawValue)
            guard predicate.evaluate(with: value) else {
                return false
            }
            return true
        }
        return false
    }
    
    func validURLString() -> Bool {
        return String.isValid(value: self, regExpr: .url)
    }
}
