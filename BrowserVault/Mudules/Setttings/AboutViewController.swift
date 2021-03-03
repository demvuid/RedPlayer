//
//  AboutViewController.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/24/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class AboutView: UIViewController {

    @IBOutlet weak var lblNameApplication: UILabel!
    
    @IBOutlet weak var lblVersion: UILabel!
    
    @IBOutlet weak var tvDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "About"
        let appName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.lblNameApplication.text = appName
        self.lblVersion.text = "Version: \(appVersion!)"
        self.tvDescription.isEditable = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
