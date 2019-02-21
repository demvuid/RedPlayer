//
//  ServiceParams.swift
//  Dating
//
//  Created by Hai Le on 5/24/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Alamofire

typealias JSObject = [String: Any]
enum RequestMethod: Int {
    case get = 0
    case head
    case put
    case post
    case delete
}

enum ContentType: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
    case textPlan = "text/plain"
}

enum HTTPTask {
    /// A requests body set with parameters.
    case requestParameters(parameters: [String: Any])
    /// A requests body set with encoded parameters.
    case requestParametersEncoding(parameters: [String: Any], encoding: ParameterEncoding)
    /// A "multipart/form-data" upload task.
    case uploadMultipart([HTTPFormData])
}

class ServiceParams {
    private var baseURL: URL
    private var pathURL: String!
    
    var task: HTTPTask
    var requestHeader: RequestHeader = RequestHeader()
    var requestMethod: RequestMethod = RequestMethod(rawValue: 0)!
    var requestURL: URL {
        get {
            var requestURL: URL = self.baseURL
            if let path = pathURL {
                requestURL = requestURL.appendingPathComponent(path)
            }
            return requestURL
        }
    }
    
    var httpMethod: HTTPMethod {
        get {
            switch (requestMethod) {
            case .put:
                return HTTPMethod.put
            case .post:
                return HTTPMethod.post
            case .delete:
                return HTTPMethod.delete
            default:
                return HTTPMethod.get
            }
        }
    }
    
    var contentType: ContentType {
        get {
            return ContentType.json
        }
    }
    
    var progressHandler: ((Progress) -> ())? = nil
    
    init(baseURL: URL = AppEnvironment.domainURL, pathURL: String!, task: HTTPTask = .requestParameters(parameters: [:])) {
        self.baseURL = baseURL
        self.pathURL = pathURL
        self.task = task
    }
}
