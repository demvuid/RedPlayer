//
//  AppEnvironment.swift
//  Dating
//
//  Created by HaiLe on 11/20/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

struct AppEnvironment {
    private static var type = APIEnvironmentType.prod
    static var domainURL: URL {
        return type.apiConfig.apiBaseURL
    }
}
