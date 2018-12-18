//
//  AuthenticationManager.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import LocalAuthentication

class AuthenticationManager {
    static var shared = AuthenticationManager()
    let authenticationContext = LAContext()
    
    var isDeviceSupportBiometry: String? {
        var error: NSError?
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return error?.localizedDescription ?? L10n.Passcode.Biometry.unavaiable
        }
        return nil
    }
    
    var biometryType: LABiometryType {
        return authenticationContext.biometryType
    }
    
    func authenticate(completion: @escaping (Bool, Error?) -> ()) {
        let reason = L10n.Passcode.Biometry.reason(Bundle.main.displayName)
        authenticationContext.localizedFallbackTitle = L10n.Passcode.Enter.pin
        authenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
            if success {
                completion(success, nil)
            } else {
                completion(success, error ?? CustomError.message(L10n.Passcode.Biometry.Authenticate.failed))
            }
        }

    }
    
}
