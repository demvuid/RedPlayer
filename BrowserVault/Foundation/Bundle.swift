//
//  Bundle.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation

extension Bundle {
    var displayName: String {
        return (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? "Browser Vault"
    }
}
