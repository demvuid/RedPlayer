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
    
    func parseVideoById(_ videoId: String, duration: String = "", handler: @escaping (String?, Error?) -> ()) {
        provider.extractInfo(for: .id(videoId), success: { (info) in
            var urlString: String? = nil
            if duration != "" {
                let durationTime = duration.parseISO8601Time()
                if durationTime.years > 0 || durationTime.months > 0 || durationTime.weeks > 0 || durationTime.days > 0 || durationTime.hours > 2 {
                    let urls = info.rawInfo.compactMap { $0["url"] }
                    if urls.count > 1 {
                        urlString = urls[1]
                    } else {
                        urlString = urls.last
                    }
                } else {
                    let urls = info.rawInfo.compactMap { $0["url"] }
                    urlString = urls.first
                }
            } else {
                let urls = info.rawInfo.compactMap { $0["url"] }
                urlString = urls.first
            }
            handler(urlString, nil)
        }) { (error) in
            handler(nil, error)
        }
    }
}
