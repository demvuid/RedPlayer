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
    lazy var provider = YoutubeDirectLinkExtractor()
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
    
    
    func getVideoIDFromDriveGoogleURL(_ url: String, completion: @escaping (String?, [HTTPCookie]) -> Void) {
        guard url.contains("drive.google.com"), let range = url.range(of: "file/d/"), let videoId = String(url[range.upperBound..<url.endIndex]).split(separator: "/").first else {
            completion(nil, [])
            return
        }
        let videoIdString = String(videoId)
        completion(videoIdString, [])
    }
    
    func getVideoURLFromVideoId(_ videoId: String, completion: @escaping (String?, [HTTPCookie]) -> Void) {
        let urlVideoInfo = "https://drive.google.com/get_video_info?docid=" + videoId
        let downloadTask = URLSession.shared.dataTask(with: URL(string: urlVideoInfo)!) { (data, response, error) in
            if let data = data,
               let string = String(data: data, encoding: .utf8)?.removingPercentEncoding {
                if let firstRange = string.range(of: "fmt_stream_map"), let secondRange = string.range(of: "url_encoded_fmt_stream_map") {
                    if let videoString = string[firstRange.upperBound..<secondRange.lowerBound].split(separator: ",").first?.split(separator: "|").last {
                        let videoURL = String(videoString)
                        if let httpResponse = response as? HTTPURLResponse, let responseUrl = httpResponse.url, let allHttpHeaders = httpResponse.allHeaderFields as? [String: String] {
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
                            completion(videoURL, cookies)
                        } else {
                            completion(videoURL, [])
                        }
                    } else {
                        completion(nil, [])
                    }
                }
            } else {
                completion(nil, [])
            }
        }
        downloadTask.resume()
    }
}
