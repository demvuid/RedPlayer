//
//  UpgradePlusView.swift
//  BrowserVault
//
//  Created by Hai Le on 09/03/2021.
//  Copyright © 2021 GreenSolution. All rights reserved.
//

import UIKit

class UpgradePlusView: UIView {

    @IBOutlet weak var upgradeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        let upgradeText = PurchaseManager.shared.shouldGettingVersion() ? "Getting Subscription" : "Upgrade now to Plus"
        self.upgradeLabel.text = upgradeText
    }
    
    func showUpgradeVersion() {
        self.upgradeLabel.text = "Upgrade now to Plus"
    }

}
