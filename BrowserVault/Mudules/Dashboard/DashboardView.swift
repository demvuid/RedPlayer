//
//  DashboardView.swift
//  Dating
//
//  Created by HaiLe on 10/29/18.
//Copyright © 2018 Astraler. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol DashboardViewInterface {
}

//MARK: DashboardView Class
final class DashboardView: UserInterface {
    private var tabBarView = DashboardTabbarView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(tabBarView)
        view.addSubview(tabBarView.view)
    }
}

//MARK: - Public interface
extension DashboardView: DashboardViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DashboardView {
    var presenter: DashboardPresenter {
        return _presenter as! DashboardPresenter
    }
    var displayData: DashboardDisplayData {
        return _displayData as! DashboardDisplayData
    }
}
