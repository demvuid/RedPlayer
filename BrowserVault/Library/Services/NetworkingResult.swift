//
//  NetworkingResult.swift
//  Dating
//
//  Created by Hai Le on 5/24/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

class NetworkingResult {
    var response: AnyObject!
    var error: Error!
    
    func isError() -> Bool {
        return self.error != nil
    }
    
    init(object: AnyObject!) {
        self.response = object
    }
}
