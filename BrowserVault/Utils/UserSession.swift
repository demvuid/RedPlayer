//
//  UserSession.swift
//  LifeSite iOS
//
//  Created by Nang Nguyen on 5/10/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import Foundation
import KeychainAccess

fileprivate let PASSWORD_KEY = "password"
fileprivate let PASSWORD_SALT_KEY = "passwordSalt"
fileprivate let PASSWORD_IV_KEY = "passwordIV"
fileprivate let USERNAME_KEY = "username"

fileprivate let ACCESS_TOKEN_KEY = "accessToken"
fileprivate let REFRESH_TOKEN_KEY = "refreshToken"
fileprivate let TOKEN_TYPE_KEY = "tokenType"
fileprivate let EXPIRES_IN_KEY = "expiresIn"
fileprivate let SCOPE_KEY = "scope"

fileprivate let PASSCODE_SALT_KEY = "passcodeSalt"
fileprivate let PASSCODE_IV_KEY = "passcodeIV"
fileprivate let PASSCODE_KEY = "passcode"
fileprivate let ENABLE_PASSCODE_KEY = "enablePasscode"
fileprivate let ENABLE_TOUCHID_KEY = "enableTouchdId"

fileprivate let defaultPIN = "cdapanh123nfhtl1gacp154(@98431nr"

fileprivate let UPGRADE_VERSION_KEY = "com.amplayer.browservault_upgradeVersion"

fileprivate let NUMBER_PLAY_VIDEO_KEY = "NumberPlayVideo"
fileprivate let NUMBER_DETAIL_FOLDER_KEY = "NumberDetailFolder"
fileprivate let DEVICE_ID_KEY = "device_id"

class UserSession {
    static let shared = UserSession()
    
    private var keyChainStore: Keychain!
    
    private init() {
        let service = "com.amplayer.browservault.keychain"
        self.keyChainStore = Keychain(service: service)
    }
    
    var countPlayVideo: Int {
        set {
            do {
                try self.keyChainStore.set("\(newValue)", key: NUMBER_PLAY_VIDEO_KEY)
            } catch let error {
                Logger.debug("Error: \(error.localizedDescription)")
            }
        }
        get {
            guard let numberPlay = try? self.keyChainStore.getString(NUMBER_PLAY_VIDEO_KEY), numberPlay != nil, let number = Int(numberPlay!) else {
                return 0
            }
            return number
        }
    }
    
    var countDetailFolder: Int {
        set {
            do {
                try self.keyChainStore.set("\(newValue)", key: NUMBER_DETAIL_FOLDER_KEY)
            } catch let error {
                Logger.debug("Error: \(error.localizedDescription)")
            }
        }
        get {
            guard let numberDetailFolder = try? self.keyChainStore.getString(NUMBER_DETAIL_FOLDER_KEY), numberDetailFolder != nil, let number = Int(numberDetailFolder!) else {
                return 0
            }
            return number
        }
    }
    
    func decryptedPassword(pin: String = defaultPIN) -> String? {
        guard let encryptedPassword = try? self.keyChainStore.getData(PASSWORD_KEY) else {
            return nil
        }
        
        let salt = try? self.keyChainStore.getData(PASSWORD_SALT_KEY)!
        let iv = try? self.keyChainStore.getData(PASSWORD_IV_KEY)!
        let decryptedData = decryptUsingAES256(encryptedPassword,
                                               generateAES256KeyForString(pin, salt),
                                               iv, nil)!
        return String.init(data: decryptedData, encoding: String.Encoding.utf8)
    }
    
    func setPassword(password pwd: String, encryptedWithPIN pin: String = defaultPIN) {
        let passwordSalt = generateRandomData(32)!
        let passwordIV = generateRandomData(16)!
        
        let encryptedPassword = encryptUsingAES256(pwd.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
                                                   generateAES256KeyForString(pin, passwordSalt),
                                                   passwordIV)!
        
        do {
            try self.keyChainStore.set(encryptedPassword, key: PASSWORD_KEY)
            try self.keyChainStore.set(passwordSalt, key: PASSWORD_SALT_KEY)
            try self.keyChainStore.set(passwordIV, key: PASSWORD_IV_KEY)
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func decryptedPasscode(pin: String = defaultPIN) -> String? {
        guard let encryptedPasscode = try? self.keyChainStore.getData(PASSCODE_KEY) else {
            return nil
        }
        
        guard let salt = try? self.keyChainStore.getData(PASSCODE_SALT_KEY), let iv = try? self.keyChainStore.getData(PASSCODE_IV_KEY), salt != nil, iv != nil else {
            return nil
        }
        let decryptedData = decryptUsingAES256(encryptedPasscode,
                                               generateAES256KeyForString(pin, salt),
                                               iv, nil)!
        return String.init(data: decryptedData, encoding: String.Encoding.utf8)
    }
    
    func setPasscode(passcode: String, encryptedWithPIN pin: String = defaultPIN) {
        let passcodeSalt = generateRandomData(32)!
        let passcodeIV = generateRandomData(16)!
        let encryptedPasscode = encryptUsingAES256(passcode.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
                                                   generateAES256KeyForString(pin, passcodeSalt),
                                                   passcodeIV)!
        
        do {
            try self.keyChainStore.set(encryptedPasscode, key: PASSCODE_KEY)
            try self.keyChainStore.set(passcodeSalt, key: PASSCODE_SALT_KEY)
            try self.keyChainStore.set(passcodeIV, key: PASSCODE_IV_KEY)
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func clearCredentials() {
        do {
            try self.keyChainStore.removeAll()
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func clearPasscode() {
        do {
            try self.keyChainStore.remove(PASSCODE_KEY)
            try self.keyChainStore.remove(PASSCODE_SALT_KEY)
            try self.keyChainStore.remove(PASSCODE_IV_KEY)
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func enablePasscode(_ enable: Bool) {
        try? self.keyChainStore?.set(enable ? "Enable" : "Disable", key: ENABLE_PASSCODE_KEY)
    }
    
    func enableTouchID(_ enable: Bool) {
        try? self.keyChainStore?.set(enable ? "Enable" : "Disable", key: ENABLE_TOUCHID_KEY)
    }
    
    func enabledPasscode() -> Bool {
        if let enable = try? self.keyChainStore?.get(ENABLE_PASSCODE_KEY) {
            if enable == "Disable" {
                return false
            }
        }
        return true
    }
    
    func enabledTouchID() -> Bool {
        if let enable = try? self.keyChainStore?.get(ENABLE_TOUCHID_KEY) {
            if enable == "Disable" {
                return false
            }
            
        }
        return true
    }
    
    func upgradeVersion() {
        do {
            try self.keyChainStore.set("Enable", key: UPGRADE_VERSION_KEY)
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func disabledVersion() {
        do {
            try self.keyChainStore.set("Disable", key: UPGRADE_VERSION_KEY)
        } catch let error {
            Logger.debug("Error: \(error.localizedDescription)")
        }
    }
    
    func isUpgradedVersion() -> Bool {
        if let enable = try? self.keyChainStore?.get(UPGRADE_VERSION_KEY) {
            if enable == "Enable" {
                return true
            }

        }
        return false
    }
    
    /// Get the username
    func username() -> String? {
        return try! self.keyChainStore.getString(USERNAME_KEY)
    }
    
    /// Set the username / phone number / email
    func setUsername(_ username: String?) {
        guard username != nil else {
            return
        }
        try! self.keyChainStore.set(username!, key: USERNAME_KEY)
    }
    
    func setCredentials(username: String, password: String) {
        self.setUsername(username)
        self.setPassword(password: password)
    }
    
    func getDeviceId() -> String {
        if let store = self.keyChainStore, let deviceId = try? store.get(DEVICE_ID_KEY), let currentDeviceId = deviceId {
            return currentDeviceId
        }
        let currentDevice = UIDevice.current
        let deviceId = currentDevice.identifierForVendor?.uuidString ?? UUID().uuidString
        try? self.keyChainStore.set(deviceId, key: DEVICE_ID_KEY)
        return deviceId
    }
}
