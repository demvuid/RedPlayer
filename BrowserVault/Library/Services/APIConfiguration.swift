//
//  APIConfiguration.swift
//  Dating
//
//  Created by HaiLe on 11/20/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

protocol APIConfigurationType {
    var apiBaseURL: URL { get }
}

struct APIConfiguration: APIConfigurationType {
    public var apiBaseURL: URL
}

extension APIConfiguration {
    static var prod: APIConfiguration {
        return APIConfiguration(apiBaseURL: URL(string: "")!)
    }
    static var simulation: APIConfiguration {
        return APIConfiguration(apiBaseURL: URL(string: "")!)
    }
}

enum APIEnvironmentType {
    case prod
    case simulation
}

extension APIEnvironmentType {
    var apiConfig: APIConfiguration {
        switch self {
        case .prod: return APIConfiguration.prod
        case .simulation: return APIConfiguration.simulation
        }
    }
}
