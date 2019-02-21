//
//  ServiceFilter.swift
//  Dating
//
//  Created by Hai Le on 5/24/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

struct ServiceFilter<ModelType> {
    var cachedPolicy: CachePolicyEnum
    var modelType: ModelType.Type
    var predicate: NSPredicate?
    init(cachedPolicy: CachePolicyEnum = .cachePolicyNWOnly, modelType: ModelType.Type = ModelType.self,
        predicate: NSPredicate? = nil) {
        self.cachedPolicy = cachedPolicy
        self.modelType = modelType
        self.predicate = predicate
    }

}
