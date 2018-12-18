//
//  PlayerVolumn.swift
//  VideoPlayer
//
//  Created by Hai Le on 3/20/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import MediaPlayer

@IBDesignable
open class PlayerVolumn: MPVolumeView {
    
    public override init(frame: CGRect) {
    
        super.init(frame: frame)
        configureSlider()
        
    }
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSlider()
    }
    
    func configureSlider() {
        let subviews = self.subviews
        for current in subviews {
            if current.isKind(of: UISlider.self) {
                let tempSlider = current as! UISlider
                tempSlider.minimumTrackTintColor = .yellow
                tempSlider.maximumTrackTintColor = .blue
            }
        }

//        for current in subviews {
//            if current.isKind(of: UISlider.self) {
//                let tempSlider = current as! UISlider
//                tempSlider.minimumTrackTintColor = UIColor.white
//                tempSlider.maximumTrackTintColor = UIColor.clear
//                let thumbImage = UIImage(named: "ic_slider_thumb")
//                let normalThumbImage = thumbImage?.resizeTo(newSize: CGSize(width: 15, height: 15))
//                tempSlider.setThumbImage(normalThumbImage, for: .normal)
//                let highlightedThumbImage = thumbImage?.resizeTo(newSize: CGSize(width: 20, height: 20))
//                tempSlider.setThumbImage(highlightedThumbImage, for: .highlighted)
//            }
//        }
    }
    
}
