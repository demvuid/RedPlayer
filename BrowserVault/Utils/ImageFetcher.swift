//
//  ImageFetcher.swift
//  LifeSite
//
//  Created by Nang Nguyen on 6/15/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
import SDWebImage

private let nameCachedImage = "bowservault_cached_image"


private let kmaxCacheAge = 60 * 60 * 24
private var cache: SDImageCache = {
    let cache = SDImageCache.shared()
    cache.config.maxCacheAge = kmaxCacheAge
    return cache
}()

class ImageFetcher {
    
    static func clearAllCache() {
        cache.clearMemory()
        cache.clearDisk(onCompletion: nil)
    }
    
    static func fetchImage(from url: URL?, to imageView: UIImageView) {
        imageView.sd_setImage(with: url)
    }
    
    static func resizeImage(_ image: UIImage!, to imageView: UIImageView) {
        let size = CGSize(width: imageView.frame.size.width * UIScreen.main.scale, height: imageView.frame.size.height * UIScreen.main.scale)
        imageView.image = image?.resizeImage(targetSize: size)
    }
    
//    func resize(to size: CGSize, for contentMode: ContentMode) -> Image
    static func fetchImage(from url: URL, isCached: Bool = false, completion:((UIImage?)->())?) {
        let path = url.absoluteString
        if isCached {
            self.fetchImage(fromKey: path, completion: completion)
        }
        self.fetchImageURL(url) { (image) in
            if isCached, let image = image {
                cache.store(image, forKey: path, toDisk: true)
            }
            completion?(image)
        }
    }
    
    static func fetchImageURL(_ url: URL, completion:((UIImage?)->())?) {
        let _ = self.downloadImageURL(url, completion: completion)
    }
    
    static func downloadImageURL(_ url: URL, progressBlock:((CGFloat)->())? = nil , completion:((UIImage?)->())?) -> SDWebImageOperation? {
        let task = SDWebImageManager.shared().loadImage(with: url, options: [], progress: { (receivedSize, expectedSize, targetURL) in
            let progress: CGFloat = min(1.0, CGFloat(receivedSize)/CGFloat(expectedSize))
            progressBlock?(progress)
        }) {(image, _, error, cacheType, finish, imageUrl) in
            completion?(image)
        }
        return task
    }
    
    static func saveImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key, toDisk: true)
    }
    
    static func fetchImage(fromKey key: String, completion:((UIImage?)->())?) {
        let image = cache.imageFromCache(forKey: key)
        completion?(image)
    }
}
