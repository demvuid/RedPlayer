//
//  PlayerViewController.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/27/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import AVKit

class PlayerViewController: AVPlayerViewController {
    var dismissBlock: (() -> Void)? = nil
    /**
     Indicate whether the current played over 10 min and will show adv.
     */
    var showAdv: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoFinishedCallback),
            name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        if self.showAdv == true {
            self.dismissBlock?()
            self.dismissBlock = nil
        }
    }
    
    @objc func videoFinishedCallback(notification: NSNotification) {
        if !self.showAdv, let duration = player?.currentItem?.duration.value, duration >= 10 * 60 * 1000 {
            self.showAdv = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
