//
//  ConfigApp.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation

let fileManger = FileManager.default
let documentURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents")
let myFolderString = "Library"
let DefaultFolderURL = documentURL.appendingPathComponent(myFolderString)

let BrowserDefaultURLKey = "DefaultURLKey"
let BrowserDefaultURL = "https://google.com"

