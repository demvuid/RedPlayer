//
//  UIImage+Extentions.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageForResourcePath(name: String, inBundle: Bundle) -> UIImage? {
        return UIImage(named: name, in: inBundle, compatibleWith: nil)
    }
    
    func fixedOrientation() -> UIImage {
        
        if imageOrientation == .up {
            return self
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi/2)
            break
        case .up, .upMirrored:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: (self.cgImage?.colorSpace)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        guard let cgImage: CGImage = ctx.makeImage() else {
            return self
        }
        return UIImage(cgImage: cgImage)
    }
    
    func AspectScaleFit( sourceSize : CGSize,  destRect : CGRect) -> CGFloat  {
        let destSize = destRect.size
        let  scaleW = destSize.width / sourceSize.width
        let scaleH = destSize.height / sourceSize.height
        return fmin(scaleW, scaleH)
    }
    
    
    func RectAroundCenter(center : CGPoint, size : CGSize) -> CGRect  {
        let halfWidth = size.width / 2.0
        let halfHeight = size.height / 2.0
        
        return CGRect(x: center.x - halfWidth, y: center.y - halfHeight, width: size.width, height: size.height) //was: CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height)
    }
    
    func  RectByFittingRect(sourceRect : CGRect, destinationRect : CGRect) -> CGRect {
        let aspect = AspectScaleFit(sourceSize: sourceRect.size, destRect: destinationRect)
        let targetSize = CGSize(width: sourceRect.size.width * aspect, height: sourceRect.size.height * aspect)  // was: CGSizeMake(sourceRect.size.width * aspect, sourceRect.size.height * aspect)
        let center =  CGPoint(x: destinationRect.midX, y: destinationRect.midY)      // was: CGPointMake(destinationRect.midX, destinationRect.midY)
        return RectAroundCenter(center: center, size: targetSize)
    }
    
    func DrawPDFPageInRect(pageRef : CGPDFPage,  destinationRect : CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if context == nil  {
            NSLog("Error: No context to draw to")
            return
        }
        
        context!.saveGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Flip the context to Quartz space
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: 1.0, y: -1.0)
        transform = transform.translatedBy(x: 0.0, y: -image!.size.height)
        context!.concatenate(transform);
        
        // Flip the rect, which remains in UIKit space
        let d = destinationRect.applying(transform)
        
        // Calculate a rectangle to draw to
        let pageRect = pageRef.getBoxRect(CGPDFBox.cropBox)
        let drawingAspect = AspectScaleFit(sourceSize: pageRect.size, destRect: d)
        let drawingRect = RectByFittingRect(sourceRect: pageRect, destinationRect: d)
        
        // Adjust the context
        context!.translateBy(x: drawingRect.origin.x, y: drawingRect.origin.y)
        context!.scaleBy(x: drawingAspect, y: drawingAspect)
        
        // Draw the page
        context!.drawPDFPage(pageRef)
        context!.restoreGState()
    }
    
    
    func ImageFromPDFFile(pdfPath : NSString, targetSize : CGSize ) -> UIImage?
    {
        let filePath = NSURL(fileURLWithPath:pdfPath as String)
        let pdfRef = CGPDFDocument(filePath)
        if pdfRef == nil {
            NSLog("Error loading PDF")
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        let pageRef = pdfRef!.page(at: 1)!
        let targetRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)      // was CGRectMake(0, 0, targetSize.width, targetSize.height)
        DrawPDFPageInRect(pageRef: pageRef, destinationRect: targetRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func GetPDFFileAspect(pdfPath : NSString) -> CGFloat {
        let filePath = NSURL(fileURLWithPath:pdfPath as String)
        
        let pdfRef = CGPDFDocument(filePath)
        if pdfRef == nil  {
            NSLog("Error loading PDF")
            return 0.0
        }
        
        let pageRef = pdfRef!.page(at: 1)
        let pageRect = pageRef!.getBoxRect(CGPDFBox.cropBox)
        return pageRect.size.width / pageRect.size.height
    }
    
    
    
    func ImageFromPDFFileWithWidth(pdfPath : NSString, targetWidth : CGFloat) -> UIImage? {
        let aspect = GetPDFFileAspect(pdfPath: pdfPath)
        if aspect == 0.0 {
            return nil
        }
        return ImageFromPDFFile(pdfPath: pdfPath, targetSize:CGSize(width:targetWidth, height: targetWidth / aspect))       // was: CGSizeMake(targetWidth, targetWidth / aspect))
    }
    
    
    func ImageFromPDFFileWithHeight(pdfPath : NSString, targetHeight : CGFloat) -> UIImage? {
        let aspect = GetPDFFileAspect(pdfPath: pdfPath)
        if aspect == 0.0 {
            return nil
        }
        return ImageFromPDFFile(pdfPath: pdfPath, targetSize: CGSize(width:targetHeight * aspect, height:targetHeight ))    // was:CGSizeMake(targetHeight * aspect, targetHeight))
    }
    
    
    
    func imageWithTint(tintColor : UIColor) -> UIImage? {
        // Begin drawing
        let aRect = CGRect(x:0.0, y: 0.0, width: self.size.width, height: self.size.height)// wasCGRectMake(0.0, 0.0, self.size.width, self.size.height)
        
        // Compute mask flipping image
        UIGraphicsBeginImageContextWithOptions( aRect.size, false/*opaque?*/, self.scale)
        let c0 = UIGraphicsGetCurrentContext()
        
        // draw image
        c0!.translateBy(x: 0, y: aRect.size.height)
        c0!.scaleBy(x: 1.0, y: -1.0)
        self.draw(in: aRect)
        
        let alphaMask = c0!.makeImage()
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContextWithOptions( aRect.size, false/*opaque?*/, self.scale)
        
        // Get the graphic context
        let c = UIGraphicsGetCurrentContext()
        
        // Draw the image
        self.draw(in: aRect)
        
        // Mask
        c!.clip(to: aRect, mask: alphaMask!)
        
        // Set the fill color space
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        c!.setFillColorSpace(colorSpace)
        
        // Set the fill color
        c!.setFillColor(tintColor.cgColor)
        UIRectFillUsingBlendMode(aRect, CGBlendMode.normal)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    // Makes a colorized copy of this image
    // Colorization rules:
    //    Alpha is preserved
    //    White & Black source pixels are preserved (!)
    //    in-between colors are blended with the given tintColor (50% gray = 100% tint color)
    func hollowImageWithTint(tintColor : UIColor) -> UIImage? {
        // Begin drawing
        let aRect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height);        // CGRectMake(0.0, 0.0, self.size.width, self.size.height);
        
        // Compute mask flipping image
        UIGraphicsBeginImageContextWithOptions( aRect.size, false/*opaque?*/, self.scale)
        let c0 = UIGraphicsGetCurrentContext()
        
        // draw image
        c0!.translateBy(x: 0, y: aRect.size.height)
        c0!.scaleBy(x: 1.0, y: -1.0)
        
        
        
        //--------------
        // draw black background to preserve color of transparent pixels
        c0!.setBlendMode(CGBlendMode.normal)
        UIColor.black.setFill()
        c0!.fill(aRect)
        
        // draw original image
        c0!.setBlendMode(CGBlendMode.normal)
        c0!.draw(self.cgImage!, in: aRect)      // was: CGContextDrawImage(c0!, aRect, self.cgImage!)
        
        // tint image (loosing alpha) - the luminosity of the original image is preserved
        c0!.setBlendMode(CGBlendMode.color)
        tintColor.setFill()
        c0!.fill(aRect)
        
        // mask by alpha values of original image
        c0!.setBlendMode(CGBlendMode.destinationIn)
        c0!.draw(self.cgImage!, in: aRect)      // was:  CGContextDrawImage(c0!, aRect, self.cgImage!)
        //---------
        
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    
    
    func scaleToSize(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height)) // Draw the scaled image in the current context
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() // Create a new image from current context
        UIGraphicsEndImageContext() // Pop the current context from the stack
        return scaledImage;         // Return our new scaled image
    }
    
    
    
    // returns a an image sized to fit within a rectangle of the given size (preserving aspect ratio)
    // as a side-benefit, any exif orientation is flattened & applied
    func normalizedImageWithMaxiumSize( maximumSize : CGFloat) -> UIImage  {
        // how big should the dest image be?
        let srcSize = self.size
        var destSize : CGSize
        // don't scale the src image up, either!
        
        if srcSize.height > srcSize.width {
            // portrait
            
            // don't *enlarge* the source image
            var maxHeight = maximumSize
            if maxHeight > srcSize.height {
                maxHeight = srcSize.height
            }
            
            destSize = CGSize(width: maxHeight *  srcSize.width / srcSize.height, height: maxHeight )
        } else {
            // landscape orientation (width constrained)
            
            // don't *enlarge* the source image
            var maxWidth = maximumSize
            if maxWidth > srcSize.width {
                maxWidth = srcSize.width
            }
            
            destSize = CGSize(width: maxWidth, height: maxWidth * srcSize.height/srcSize.width )
        }
        
        // draw into the destination image
        UIGraphicsBeginImageContextWithOptions( destSize, true/*opaque?*/, self.scale)
        //let gc = UIGraphicsGetCurrentContext()
        self.draw(in: CGRect(x: 0, y: 0, width: destSize.width, height: destSize.height))
        
        // get the dest image out
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return destImage!
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio,  height:size.height * widthRatio)
        }
        
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if newImage == nil {
            newImage = (self.copy() as? UIImage) ?? self
        }
        return newImage!
    }
    
    func resizeImage(width: CGFloat) -> UIImage {
        let scaleFactor = width / self.size.width
        let newHeight = scaleFactor * self.size.height
        let size = CGSize(width: width, height: newHeight)
        return self.resizeImage(targetSize: size)
    }
}

extension UIImage {
    func resizeTo(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
