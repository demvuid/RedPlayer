//
//  SystemService.swift
//  Entertainment
//
//  Created by Hai Le on 9/7/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit
//https://www.dropbox.com/s/17xhj2zbfc93egt/tubemate.json?dl=0

class SystemService {
    static var sharedInstance = SystemService()
    var timeIntervalAdv: Double = 5.0
    func categoriesMenuWithCompletionBlock(_ handler: @escaping (MenuCategories?, Error?) -> ()) {
        let serviceParams = ServiceParams(baseURL: URL(string: "https://dl.dropboxusercontent.com")!, pathURL: "s/7yu1cr7d00ndupw/category.json")
        serviceParams.requestMethod = .get
        serviceParams.requestHeader = RequestHeader()
        BaseService.shared.request(serviceParams: serviceParams, mapJsonAt: "response") { (categories: MenuCategories?, error: Error?) in
            handler(categories, error)
        }
    }
    
    func groupMenuWithCompletionBlock(_ handler: @escaping (MenuGroup?, Error?) -> ()) {
        let serviceParams = ServiceParams(baseURL: URL(string: "https://dl.dropboxusercontent.com")!, pathURL: "s/17xhj2zbfc93egt/tubemate.json")
        serviceParams.requestMethod = .get
        serviceParams.requestHeader = RequestHeader()
        BaseService.shared.request(serviceParams: serviceParams) { (categories: MenuGroup?, error: Error?) in
            handler(categories, error)
        }
    }
    
    func suggestQuery(_ query: String, completion: @escaping ([Suggestion]?, Error?) -> ()) {
        let params: [String: Any] = ["q": query]
        let serviceParams = ServiceParams(baseURL: URL(string: "https://duckduckgo.com")!, pathURL: "ac", task: .requestParameters(parameters: params))
        serviceParams.requestMethod = .get
        serviceParams.requestHeader = RequestHeader()
        let parseJson = { (jsonArray: [[String: Any]]) -> ([Suggestion]?, Error?) in
            let array = jsonArray.compactMap({ (json) -> Suggestion? in
                if let key = json.keys.first {
                    return Suggestion(type: key, suggestion: json[key] as? String)
                }
                return nil
            })
            return (array, nil)
        }
        BaseService.shared.requestArray(serviceParams: serviceParams, parseJson: parseJson) { (suggestions: [Suggestion]?, error: Error?) in
            completion(suggestions, error)
        }
    }
}
