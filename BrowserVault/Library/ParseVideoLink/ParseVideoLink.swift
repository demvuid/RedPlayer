//
//  ParseVideoLink.swift
//  BrowserVault
//
//  Created by HaiLe on 2/13/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import XCDYouTubeKit

class ParseVideoManager {
    static var shared = ParseVideoManager()
    private func videoId(from url: URL) -> String? {
        guard let host = url.host else {
            return nil
        }
        
        let components = url.pathComponents
        
        switch host {
            
        case _ where host.contains("youtu.be"):
            return components[1]
            
        case _ where host.contains("m.youtube.com"):
            return url.absoluteString.components(separatedBy: "?").last?.queryComponents()["v"]
            
        case _ where host.contains("youtube.com")
            && components[1] == "embed":
            return components[2]
            
        case _ where host.contains("youtube.com")
            && components[1] != "embed":
            return url.query?.queryComponents()["v"]
            
        default:
            return nil
        }
    }
    
    func parseVideoLinkURL(_ urlString: String, handler: @escaping (String?, Error?) -> ()) {
        guard let url = URL(string: urlString), let videoId = self.videoId(from: url) else {
            handler(nil, nil)
            return
        }
        
        self.parseVideoById(videoId, handler: handler)
    }
    
    func parseVideoById(_ videoId: String, duration: String = "", handler: @escaping (String?, Error?) -> ()) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { (video, error) in
            if let video = video {
                var videoURL: URL?
                if let url = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] {
                    videoURL = url
                } else if let url = video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] {
                    videoURL = url
                } else if let url = video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] {
                    videoURL = url
                } else if let url = video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] {
                    videoURL = url
                }
                handler(videoURL?.absoluteString, error)
            } else {
                handler(nil, error)
            }
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
               var string = String(data: data, encoding: .utf8)?.removingPercentEncoding {
                if let firstRange = string.range(of: "fmt_stream_map"), let secondRange = string.range(of: "url_encoded_fmt_stream_map") {
                    string = String(string[firstRange.upperBound..<secondRange.lowerBound])
                    if string.hasPrefix("=") {
                        string = String(string.dropFirst())
                    }
                    let urlArray = string.split(separator: ",")
                    let qualityItags = ["37|", "22|", "59|", "18|"]
                    
                    var videoURL: String? = nil
                    
                    for itag in qualityItags {
                        for url in urlArray {
                            if url.hasPrefix(itag) == true, let itagURL = url.split(separator: "|").last {
                                videoURL = String(itagURL)
                                break
                            }
                        }
                        if videoURL != nil {
                            break
                        }
                    }
                    if videoURL == nil, let itagURL = urlArray.last?.split(separator: "|").last {
                        videoURL = String(itagURL)
                    }
                    
                    
                    if let videoURL = videoURL {
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
