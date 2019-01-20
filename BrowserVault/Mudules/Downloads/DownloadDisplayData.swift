//
//  DownloadDisplayData.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

enum BrowseFileType {
    case download
    case play
}

class DownloadDisplayData: DisplayData {
    var browseType: BrowseFileType = .download
}
