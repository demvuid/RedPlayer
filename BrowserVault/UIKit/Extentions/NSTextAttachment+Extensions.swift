//
//  NSTextAttachment+Extensions.swift
//  LifeSite
//
//  Created by macbookpro on 8/12/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
// Keeping Image aspect ratio
extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        bounds = CGRect(x:bounds.origin.x, y:bounds.origin.y, width:ratio * height, height:height)
    }
    
    static func getCenteredImageAttachment(with imageName: String, font: UIFont?, width: CGFloat?, color: UIColor) -> NSTextAttachment? {
        let imageAttachment = NSTextAttachment()
        guard let image = UIImage(named: imageName)?.maskWithColor(color: color),
            let font = font, let width = width else { return nil }
        
        imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - width).rounded() / 2, width: width, height: width)
        imageAttachment.image = image
        return imageAttachment
    }
    
    static func getCenteredImageAttachment(with image: UIImage, font: UIFont?, width: CGFloat?, color: UIColor) -> NSTextAttachment? {
        let imageAttachment = NSTextAttachment()
        guard let image = image.maskWithColor(color: color),
            let font = font, let width = width else { return nil }
        
        imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - width).rounded() / 2, width: width, height: width)
        imageAttachment.image = image
        return imageAttachment
    }
    
    static func attributedString(image: UIImage, bounds: CGRect, color: UIColor? = nil) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = bounds
        if let color = color {
            imageAttachment.image = image.maskWithColor(color: color)
        } else {
            imageAttachment.image = image
        }
        return NSAttributedString(attachment: imageAttachment)
    }

    static func attributedString(image: UIImage, font: UIFont, width: CGFloat, color: UIColor? = nil) -> NSAttributedString {
        let bounds = CGRect(x: 0, y: (font.capHeight - width).rounded() / 2, width: width, height: width)
        return self.attributedString(image: image, bounds: bounds, color: color)
    }
}
