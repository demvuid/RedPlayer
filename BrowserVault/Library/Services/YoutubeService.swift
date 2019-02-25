//
//  YoutubeService.swift
//  5sOnlineOffice
//
//  Created by Hai Le on 7/8/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit
import RealmSwift

let YoutubeDomain = "https://www.googleapis.com/youtube/v3"
let APIYoutubeChannels = "channels"
let APIYoutubeTVShows = "search"
let APIYoutubeEntertainment = "playlistItems"
let APIYoutubeVideos = "videos"
let GOOGLE_YOUTUBE_API_KEY = "AIzaSyCorqsUlnR3CAmdTnGrtaLxV3W8M9aP-Qo"

let MaxItemsRequest = 30

typealias HandlerYoutubeAPI = (YouTubeResult?, Error?) -> ()
class YoutubeService {
    static var sharedInstance = YoutubeService()
    
    func serviceParam(path: String, parameters: [String: Any] = [:]) -> ServiceParams {
        var params = parameters
        if params.count > 0 {
            params["key"] = GOOGLE_YOUTUBE_API_KEY
        }
        
        let serviceParams = ServiceParams(baseURL: URL(string: YoutubeDomain)!, pathURL: path, task: .requestParameters(parameters: params))
        serviceParams.requestMethod = .get
        serviceParams.requestHeader = RequestHeader()
        return serviceParams
    }
    
    func listYoutubeByIds(_ youtubeIds: String, region: String, completionBlock handler: @escaping HandlerYoutubeAPI) {
        var params: [String: Any] = ["part": "id,snippet,contentDetails,statistics",
                                     "id": youtubeIds,
                                     "maxResults": MaxItemsRequest,
                                     "type": "video"]
        if region != "" {
            params["regionCode"] = region
        }
        let serviceParams = self.serviceParam(path: APIYoutubeVideos, parameters: params)
        
        BaseService.shared.request(serviceParams: serviceParams) { (result: YouTubeResult?, error: Error?) in
            handler(result, error)
        }
    }
    
    func listYoutubeByChannelId(_ categoryId: String, nextToken pageToken: String, withCompletionBlock handler: @escaping HandlerYoutubeAPI) {
        var params: [String: Any] = ["channelId": categoryId,
                                     "part": "snippet",
                                     "order": "date",
                                     "maxResults": MaxItemsRequest,
                                     "type": "video",
                                     "regionCode": "US"]
        if pageToken != "" {
            params["pageToken"] = pageToken
        }
        let serviceParams = self.serviceParam(path: APIYoutubeTVShows, parameters: params)
        BaseService.shared.request(serviceParams: serviceParams) { (result: YouTubeResult?, error: Error?) in
            if let youtubeResult = result {
                self.listYoutubeByIds(youtubeResult.youtubeIds(), region: "US", completionBlock: { (result, error) in
                    youtubeResult.items.append(objectsIn: result?.items.map({$0}) ?? [])
                    handler(youtubeResult, error)
                })
            } else {
                handler(nil, error)
            }
        }
    }
    
    func listYoutubeByPlaylistId(_ playlistId: String, nextToken pageToken: String, withCompletionBlock handler: @escaping HandlerYoutubeAPI) {
        var params: [String: Any] = ["playlistId": playlistId,
                                     "part": "snippet,contentDetails",
                                     "maxResults": MaxItemsRequest,
                                     "type": "video"]
        if pageToken != "" {
            params["pageToken"] = pageToken
        }
        let serviceParams = self.serviceParam(path: APIYoutubeEntertainment, parameters: params)
        
        BaseService.shared.request(serviceParams: serviceParams) { (result: YouTubeResult?, error: Error?) in
            if let youtubeResult = result {
                self.listYoutubeByIds(youtubeResult.youtubeIds(), region: "", completionBlock: { (result, error) in
                    youtubeResult.items.append(objectsIn: result?.items.map({$0}) ?? [])
                    handler(youtubeResult, error)
                })
            } else {
                handler(nil, error)
            }
        }
        
    }
    
    func listYoutubeChannelByUser(_ user: String, completionBlock handler: @escaping (YoutubeChannels?, Error?) -> ()) {
        let params: [String: Any] = ["part": "contentDetails",
                                     "forUsername": user,
                                     "maxResults": MaxItemsRequest,
                                     "type": "video"]
        let serviceParams = self.serviceParam(path: APIYoutubeChannels, parameters: params)
        BaseService.shared.request(serviceParams: serviceParams) { (channel: YoutubeChannels?, error: Error?) in
            handler(channel, error)
        }
    }
    
    func listYoutubeByUser(_ user: String, nextToken pageToken: String, handler: @escaping HandlerYoutubeAPI) {
        self.listYoutubeChannelByUser(user) { (channel, error) in
            if let channel = channel?.channels.first {
                self.listYoutubeByChannelId(channel.channelId, nextToken: pageToken, withCompletionBlock: { (result, error) in
                    handler(result, error)
                })
            } else {
                handler(nil, error)
            }
        }
    }
    
    func listYoutubeByCategory(_ category: MenuCategory, nextToken pageToken: String, withCompletionBlock handler: @escaping HandlerYoutubeAPI) {
        if category.categoryType == MenuCategoryType.channel.rawValue {
            self.listYoutubeByChannelId(category.categoryId, nextToken: pageToken, withCompletionBlock: handler)
        } else if category.categoryType == MenuCategoryType.playlist.rawValue {
            self.listYoutubeByPlaylistId(category.categoryId, nextToken: pageToken, withCompletionBlock: handler)
        } else {
            self.listYoutubeByUser(category.categoryId, nextToken: pageToken, handler: handler)
        }
    }

}
