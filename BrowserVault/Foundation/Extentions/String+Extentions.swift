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

extension String {
    func widthOfString(usingFont font: UIFont = AppBranding.baseFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont = AppBranding.baseFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont = AppBranding.baseFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension String {
    public func parseISO8601Time() -> Duration {
        let nsISO8601 = NSString(string: self)
        var days = 0, hours = 0, minutes = 0, seconds: Float = 0, weeks = 0, months = 0, years = 0
        var i = 0
        var beforeT:Bool = true
        
        while i < nsISO8601.length  {
            var str = nsISO8601.substring(with: NSRange(location: i, length: nsISO8601.length - i))
            
            i += 1
            
            if str.hasPrefix("P") || str.hasPrefix("T") {
                beforeT = !str.hasPrefix("T")
                continue
            }
            
            let scanner = Scanner(string: str)
            var value: Float = 0
            
            if scanner.scanFloat(&value) {
                i += scanner.scanLocation - 1
                
                str = nsISO8601.substring(with: NSRange(location: i, length: nsISO8601.length - i))
                
                i += 1
                
                if str.hasPrefix("Y") {
                    years = Int(value)
                } else if str.hasPrefix("M") {
                    if beforeT{
                        months = Int(value)
                    }else{
                        minutes = Int(value)
                    }
                } else if str.hasPrefix("W") {
                    weeks = Int(value)
                } else if str.hasPrefix("D") {
                    days = Int(value)
                } else if str.hasPrefix("H") {
                    hours = Int(value)
                } else if str.hasPrefix("S") {
                    seconds = value
                }
            }
        }
        return Duration(years: years, months: months, weeks: weeks, days: days, hours: hours, minutes: minutes, seconds: seconds)
    }
}

public struct Duration {
    
    let daysInMonth: Int = 30
    let daysInYear: Int = 365
    
    var years: Int
    var months: Int
    var weeks: Int
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Float
    
    public func getMilliseconds() -> Int{
        return Int(round(seconds*1000)) + minutes*60*1000 + hours*60*60*1000 + days*24*60*60*1000 + weeks*7*24*60*60*1000 + months*daysInMonth*24*60*60*1000 + years*daysInYear*24*60*60*1000
    }
    
    public func getFormattedString() -> String{
        
        var formattedString = ""
        
        if years != 0 {
            formattedString.append("\(years)")
            formattedString.append(" ")
            formattedString.append(years == 1 ? "year" : "years")
            formattedString.append(" ")
        }
        
        if months != 0{
            formattedString.append("\(months)")
            formattedString.append(" ")
            formattedString.append(months == 1 ? "month" : "months")
            formattedString.append(" ")
        }
        
        if weeks != 0 {
            formattedString.append("\(weeks)")
            formattedString.append(" ")
            formattedString.append(weeks == 1 ? "week" : "weeks")
            formattedString.append(" ")
        }
        
        if days != 0 {
            formattedString.append("\(days)")
            formattedString.append(" ")
            formattedString.append(days == 1 ? "day" : "days")
            formattedString.append(" ")
        }
        
        if seconds != 0 {
            formattedString.append(String(format: "%02d:%02d:%.02f", hours, minutes, seconds))
        }else{
            formattedString.append(String(format: "%02d:%02d", hours, minutes))
        }
        
        return formattedString
    }
}

extension String {
    public func trimWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func length() -> Int {
        return count
    }
    
    public func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let matches = regex.matches(in: self, options: .anchored, range: NSRange(location: 0, length: count))
        return matches.count == 1
    }
    
    /// Useful if loaded from UserText, for example
    public func format(arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
    }
    
    public func dropPrefix(prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}
