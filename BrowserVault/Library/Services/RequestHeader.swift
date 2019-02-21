//
//  RequestHeader.swift
//  Dating
//
//  Created by Hai Le on 5/24/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

let HeaderAuthorizationPrefix = "Bearer ";
let HeaderParamAuthorization = "Authorization"

class RequestHeader {
    var headers: [String: String] {
        get {
            return [String: String]()
        }
    }
}

class CustomHeader: RequestHeader {
    var paramHeaders: [String: String]!
    override var headers: [String: String] {
        get {
            var headers = super.headers
            if let params = self.paramHeaders {
                params.keys.forEach { (key) in
                    headers[key] = params[key]
                }
            }
            return headers
        }
    }
}

class SecurityHeader: RequestHeader {
    var accessToken: String
    
    var accessTokenForHeader: String {
        get {
            return HeaderAuthorizationPrefix + self.accessToken
        }
    }
    
    override var headers: [String: String] {
        get {
            var headers = super.headers
            headers[HeaderParamAuthorization] = self.accessTokenForHeader
            return headers
        }
    }
    
    init(accessToken: String = "") {
        self.accessToken = accessToken
    }
}
