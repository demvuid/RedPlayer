//
//  ImageFetcher.swift
//  LifeSite
//
//  Created by Nang Nguyen on 6/15/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit
import Kingfisher

private let nameCachedImage = "bowservault_cached_image"

private var cache: ImageCache = {
    let cache = ImageCache(name: nameCachedImage)
    cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024 // 100MB
    return cache
}()

class ImageFetcher {
    
    static func clearAllCache() {
        cache.clearDiskCache()
        cache.clearMemoryCache()
        cache.cleanExpiredDiskCache()
    }
    
    static func fetchImage(from url: URL?, to imageView: UIImageView) {
        imageView.kf.setImage(with: url)
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
        ImageDownloader.default.downloadImage(with: url, options: [.targetCache(cache)]) { (result) in
            switch result {
            case .success(let value):
                let image = value.image.images?.first
                completion?(image)
            case .failure(let error):
                Logger.debug("failed fetch image with error:\(error.localizedDescription)")
                completion?(nil)
            }
        }
    }
    
    static func saveImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key, toDisk: true)
    }
    
    static func fetchImage(fromKey key: String, completion:((UIImage?)->())?) {
        cache.retrieveImageInDiskCache(forKey: key) { (result) in
            switch result {
            case .success(let value):
                let image = value?.images?.first
                completion?(image)
            case .failure(let error):
                Logger.debug("failed fetch image with error:\(error.localizedDescription)")
                completion?(nil)
            }
        }
    }
}
