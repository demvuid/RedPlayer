//
//  ConfigApp.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation

let myDownloadString = "My Downloads"
let fileManger = FileManager.default
let documentPathString = (NSHomeDirectory() as NSString).appendingPathComponent("Documents") as String
let documentPathURL = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first!
let myDownloadPathString = documentPathString + "/\(myDownloadString)"
let myDownloadPathURL = documentPathURL.appendingPathComponent(myDownloadString)

let BrowserDefaultURLKey = "DefaultURLKey"
let BrowserDefaultURL = "https://google.com"

