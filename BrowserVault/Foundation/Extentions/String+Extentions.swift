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
    func fileExtension() -> String {
        var fileExtension = NSURL(fileURLWithPath: self).pathExtension
        if fileExtension == nil {
            fileExtension = ""
        }
        return  fileExtension!
    }
    
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

private let LinkURLSupportedFileMediaExtensions = "\\.(3g2|3gp|3gp2|3gpp|amv|asf|avi|bik|bin|crf|divx|drc|dv|evo|f4v|flv|gvi|gxf|iso|m1v|m2v|m2t|m2ts|m4v|mkv|mov|mp2|mp2v|mp4|mp4v|mpe|mpeg|mpeg1|mpeg2|mpeg4|mpg|mpv2|mts|mtv|mxf|mxg|nsv|nuv|ogg|ogm|ogv|ogx|ps|rec|rm|rmvb|rpl|thp|tod|ts|tts|txd|vlc|vob|vro|webm|wm|wmv|wtv|xesc)$"
private let linkURLSupportedFileImageExtensions = "\\.(jpg|jpeg|png|gif|bmp|tiff)$"

private let linkURLSupportedAudioFileExtensions = "\\.(3ga|669|a52|aac|ac3|adt|adts|aif|aifc|aiff|amb|amr|aob|ape|au|awb|caf|dts|flac|it|kar|m4a|m4b|m4p|m5p|mid|mka|mlp|mod|mpa|mp1|mp2|mp3|mpc|mpga|mus|oga|ogg|oma|opus|qcp|ra|rmi|s3m|sid|spx|tak|thd|tta|voc|vqf|w64|wav|wma|wv|xa|xm)$"


extension String {
    var isMediaFileExtension: Bool {
        return self.range(of: LinkURLSupportedFileMediaExtensions, options: [.regularExpression, .caseInsensitive]) != nil || self.range(of: linkURLSupportedAudioFileExtensions, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    var isImageFileExtension: Bool {
        return self.range(of: linkURLSupportedFileImageExtensions, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
