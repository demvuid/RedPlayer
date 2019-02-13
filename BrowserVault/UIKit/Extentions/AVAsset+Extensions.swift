//
//  AVAsset+Extensions.swift
//  LifeSite
//
//  Created by Hai Le on 7/3/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
import MediaPlayer

extension AVAsset {
    var videoThumbnail: UIImage? {
        let assetImageGenerator = AVAssetImageGenerator(asset: self)
        assetImageGenerator.appliesPreferredTrackTransform = true
        var time = self.duration
        if time.value > 0 {
            time.value = time.value / 2
        }
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            return thumbNail
        } catch {
            return nil
        }
    }
}
