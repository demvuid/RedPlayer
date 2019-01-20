//
//  UIDevice.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/22/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import Foundation

extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }
        
        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static var hasExternalDisplay: Bool {
        return false
//        return UIScreen.screens.count > 1
    }
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isLandscape: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
}
