//
//  PlayerMediaView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/26/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol PlayerMediaViewInterface {
    func updatePlayerURL(_ url: String)
    func playMediaURL()
}

//MARK: PlayerMediaView Class
final class PlayerMediaView: UserInterface {
    @IBOutlet weak var movieView: DLCBaseVideoView!
    var mediaURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.movieView.shouldAutoPlay = true
        self.movieView.closeButton.addTarget(self, action: #selector(closeView(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func closeView(_ sender: Any) {
        let completion = self.movieView.showAdv == true ? self.displayData.dismissBlock : nil
        self.dismiss(animated: true, completion: completion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

//MARK: - Public interface
extension PlayerMediaView: PlayerMediaViewInterface {
    func updatePlayerURL(_ url: String) {
        self.mediaURL = url
    }
    
    func playMediaURL() {
        self.movieView.mediaURL = mediaURL
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PlayerMediaView {
    var presenter: PlayerMediaPresenter {
        return _presenter as! PlayerMediaPresenter
    }
    var displayData: PlayerMediaDisplayData {
        return _displayData as! PlayerMediaDisplayData
    }
}
