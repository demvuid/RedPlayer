//
//  YouTubeResult.swift
//  DeciMaker
//
//  Created by Hai Le on 3/31/16.
//  Copyright © 2016 CCentral. All rights reserved.
//

import UIKit
import RealmSwift



class YoutubeItem: BaseModel, Decodable {
    @objc dynamic var itemId: String = ""
    @objc dynamic var channelId: String = ""
    @objc dynamic var channelTitle: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var thumnailDefaultUrl: String = ""
    @objc dynamic var thumnailMediumUrl: String = ""
    @objc dynamic var thumnailHighUrl: String = ""
    @objc dynamic var youtubeDescription: String = ""
    @objc dynamic var youtubeId: String = ""
    @objc dynamic var duration: String = ""
    @objc dynamic var  views: String = ""
    @objc dynamic var  likes: String = ""
    @objc dynamic var  disLikes: String = ""
    
    enum CodingKeys: String, CodingKey {
        case itemId = "id"
        case snippet
        case contentDetails
        case statistics
    }
    
    enum Snippet: String {
        case channelId
        case channelTitle
        case title
        case thumnailDefaultUrl = "thumbnails.default.url"
        case thumnailMediumUrl = "thumbnails.medium.url"
        case thumnailHighUrl = "thumbnails.high.url"
        case youtubeDescription = "description"
    }
    
    enum Statistics: String {
        case views = "viewCount"
        case likes = "likeCount"
        case disLikes = "dislikeCount"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let videoItem = try? container.decodeIfPresent([String: Any].self, forKey: .itemId) {
                self.itemId = (videoItem["videoId"] as? String) ?? ""
            } else if let itemId = try? container.decodeIfPresent(String.self, forKey: .itemId) {
                self.itemId = itemId ?? ""
            }
            do {
                let content = try container.decode([String: String].self, forKey: .contentDetails)
                if let videoId = content["videoId"] {
                    self.itemId = videoId
                }
                if let duration = content["duration"] {
                    self.duration = duration
                }
            } catch {
                
            }
            if let snippet = try? container.decodeIfPresent([String: Any].self, forKey: .snippet) {
                if let channelId = snippet[Snippet.channelId.rawValue] as? String {
                    self.channelId = channelId
                }
                if let channelTitle = snippet[Snippet.channelTitle.rawValue] as? String {
                    self.channelTitle = channelTitle
                }
                if let title = snippet[Snippet.title.rawValue] as? String {
                    self.title = title
                }
                if let thumnailDefaultUrl = (snippet as NSDictionary?)?.value(forKeyPath: Snippet.thumnailDefaultUrl.rawValue) as? String {
                    self.thumnailDefaultUrl = thumnailDefaultUrl
                }
                if let thumnailMediumUrl = (snippet as NSDictionary?)?.value(forKeyPath: Snippet.thumnailMediumUrl.rawValue) as? String {
                    self.thumnailMediumUrl = thumnailMediumUrl
                }
                if let thumnailHighUrl = (snippet as NSDictionary?)?.value(forKeyPath: Snippet.thumnailHighUrl.rawValue) as? String {
                    self.thumnailHighUrl = thumnailHighUrl
                }
                if let youtubeDescription = snippet[Snippet.youtubeDescription.rawValue] as? String {
                    self.youtubeDescription = youtubeDescription
                }
            }
            if let statistics = try? container.decodeIfPresent([String: Any].self, forKey: .statistics) {
                if let views = statistics[Statistics.views.rawValue] as? String {
                    self.views = views
                }
                if let likes = statistics[Statistics.likes.rawValue] as? String {
                    self.likes = likes
                }
                if let disLikes = statistics[Statistics.disLikes.rawValue] as? String {
                    self.disLikes = disLikes
                }
            }
        } catch let error {
            debugPrint(error)
        }
    }
}

class PageInfo: BaseModel, Decodable {
    @objc dynamic var totalResults: Int = 0
    @objc dynamic var resultsPerPage: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case totalResults = "totalResults"
        case resultsPerPage = "resultsPerPage"
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults)
        let resultsPerPage = try container.decodeIfPresent(Int.self, forKey: .resultsPerPage)
        self.init()
        self.totalResults = totalResults ?? 0
        self.resultsPerPage = resultsPerPage ?? 0
    }
}

class YouTubeResult: BaseModel, Decodable {
    @objc dynamic var dataId: String = ""
    @objc dynamic var tokenRequestNextPage: String = ""
    @objc dynamic var regionCode: String = ""
    @objc dynamic var pageInfo: PageInfo!
    var items = List<YoutubeItem>()
    
    enum CodingKeys: String, CodingKey {
        case dataId = "kind"
        case tokenRequestNextPage = "nextPageToken"
        case regionCode = "regionCode"
        case pageInfo = "pageInfo"
        case items = "items"
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataId = try container.decodeIfPresent(String.self, forKey: .dataId)
        let tokenRequestNextPage = try container.decodeIfPresent(String.self, forKey: .tokenRequestNextPage)
        let regionCode = try container.decodeIfPresent(String.self, forKey: .regionCode)
        let pageInfo = try container.decodeIfPresent(PageInfo.self, forKey: .pageInfo)
        let items = try container.decodeIfPresent([YoutubeItem].self, forKey: .items)
        self.init()
        if let dataId = dataId {
            self.dataId = dataId
        }
        if let tokenRequestNextPage = tokenRequestNextPage {
            self.tokenRequestNextPage = tokenRequestNextPage
        }
        if let regionCode = regionCode {
            self.regionCode = regionCode
        }
        if let pageInfo = pageInfo {
            self.pageInfo = pageInfo
        }
        if let items = items {
            self.items.append(objectsIn: items)
        }
    }
    
    func hasNextToken() -> Bool {
        return tokenRequestNextPage != ""
    }
    
    func youtubeIds() -> String {
        var ids: String = ""
        for index in 0..<self.items.count {
            let item = self.items[index]
            if index == self.items.count - 1 {
                ids = "\(ids)\(item.itemId)"
            } else {
                ids = "\(ids)\(item.itemId),"
            }
        }
        return ids
    }
}
