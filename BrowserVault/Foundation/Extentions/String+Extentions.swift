//
//  String+Extentions.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import AVFoundation

enum RegExprPattern: String {
    case emailAddress = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
    case url = "((https|http|ftp)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+([/?#]\\S*)?"
    case containsNumber = ".*\\d.*"
    case containsCapital = "^.*?[A-Z].*?$"
    case containsLowercase = "^.*?[a-z].*?$"
}

extension String {
    static func isValid(value: String?, regExpr: RegExprPattern) -> Bool {
        if let value = value, !value.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regExpr.rawValue)
            guard predicate.evaluate(with: value) else {
                return false
            }
            return true
        }
        return false
    }
    
    func validURLString() -> Bool {
        return String.isValid(value: self, regExpr: .url)
    }
    
    func queryComponents() -> [String: String] {
        var pairs: [String: String] = [:]
        
        for pair in self.components(separatedBy: "&") {
            let pairArr = pair.components(separatedBy: "=")
            
            guard pairArr.count == 2,
                let key = pairArr.first?.decodedFromUrl(),
                let value = pairArr.last?.decodedFromUrl() else {
                    continue
            }
            
            pairs[key] = value
        }
        
        return pairs
    }
    
    func decodedFromUrl() -> String? {
        return self.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
    }
    
    public struct VideoInfo {
        
        /** Raw info for each video quality. Elements are sorted by video quality with first being the highest quality. */
        public let rawInfo: [[String: String]]
        
        public var highestQualityPlayableLink: String? {
            let urls = rawInfo.compactMap { $0["url"] }
            return firstPlayable(from: urls)
        }
        
        public var lowestQualityPlayableLink: String? {
            let urls = rawInfo.reversed().compactMap { $0["url"] }
            return firstPlayable(from: urls)
        }
        
        private func firstPlayable(from urls: [String]) -> String? {
            for urlString in urls {
                guard let url = URL(string: urlString) else {
                    continue
                }
                let asset = AVAsset(url: url)
                if asset.isPlayable {
                    return urlString
                }
            }
            
            return nil
        }
    }
    
    func extractInfoGoogleDriverLink() -> String? {
        let pairs = self.queryComponents()
        
        guard let fmtStreamMap = pairs["url_encoded_fmt_stream_map"],
            !fmtStreamMap.isEmpty else {
                return nil
        }
        let fmtStreamMapComponents = fmtStreamMap.components(separatedBy: ",")
        
        let infoPerPreset = fmtStreamMapComponents.map { $0.queryComponents() }
        let video = VideoInfo(rawInfo: infoPerPreset)
        return video.highestQualityPlayableLink
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.encodedOffset
        } else {
            return false
        }
    }
}
