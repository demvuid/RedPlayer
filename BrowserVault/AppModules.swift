//
//  AppModules.swift
//  Dating iOS
//
//  Created by HaiLe on 5/10/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Viperit

enum AppModules: String, ViperitModule {
    case passcode
    case dashboard
    case browser
    case settings
    case defaultURL
    case settingLock
    case files
    case folder
    
    var viewType: ViperitViewType {
        switch self {
        default:
            return .storyboard
        }        
    }
}
