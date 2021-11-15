//
//  WebViewController.swift
//  BrowserVault
//
//  Created by Hai Le on 09/03/2021.
//  Copyright © 2021 GreenSolution. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    private var localURL: URL!
    @IBOutlet weak var myWebView: WKWebView!
    
    convenience init(localURL: URL) {
        self.init()
        self.localURL = localURL
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: localURL)
        myWebView.load(request)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.General.iconClose.image, style: .plain, target: self, action: #selector(dismissScreen))
    }

    @objc private func dismissScreen() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
