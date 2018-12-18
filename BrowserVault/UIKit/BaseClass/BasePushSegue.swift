//
//  BasePushSegue.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/24/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class BasePushSegue: UIStoryboardSegue {
    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: true)
    }
}
