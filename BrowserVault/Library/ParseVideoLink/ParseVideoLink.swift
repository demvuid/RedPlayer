//
//  ParseVideoLink.swift
//  BrowserVault
//
//  Created by HaiLe on 2/13/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import YoutubeDirectLinkExtractor

class ParseVideoManager {
    static var shared = ParseVideoManager()
    let provider = YoutubeDirectLinkExtractor()
    func parseVideoLinkURL(_ urlString: String, handler: @escaping (String?, Error?) -> ()) {
        provider.extractInfo(for: .urlString(urlString), success: { info in
            handler(info.highestQualityPlayableLink, nil)
        }) { error in
            handler(nil, error)
        }
    }
}
