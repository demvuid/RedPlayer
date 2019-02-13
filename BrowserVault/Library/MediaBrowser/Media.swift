//
//  Media.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import UIKit
import AssetsLibrary
import Photos
import SDWebImage
import RealmSwift

let MEDIA_LOADING_DID_END_NOTIFICATION  = "MEDIA_LOADING_DID_END_NOTIFICATION"
let MEDIA_PROGRESS_NOTIFICATION  = "MEDIA_PROGRESS_NOTIFICATION"

var PHInvalidImageRequestID = PHImageRequestID(0)

/// Media is object for photo and video
@objcMembers
open class Media: Object {
    @objc dynamic public var caption = ""
    
    @objc dynamic public var isVideo = false
    
    @objc dynamic var folder: FolderModel!
    
    @objc dynamic var uuid = NSUUID().uuidString
    
    
    override open class func primaryKey() -> String? {
        return "uuid"
    }
    
    override open class func ignoredProperties() -> [String] {
        return ["image", "emptyImage", "underlyingImage", "placeholderImage",
                "asset", "assetTargetSize", "loadingInProgress", "operation", "assetRequestID"]
    }
    
    public var photoURL: URL? {
        if let folderURL = self.folder?.folderURL {
            return folderURL.appendingPathComponent(self.caption)
        }
        return nil
    }
    
    //MARK: - Video
    
    public var videoURL: URL? {
        if let folderURL = self.folder?.folderURL {
            return folderURL.appendingPathComponent(self.caption)
        }
        return nil
    }
    var temporaryPath: String?
    var image: UIImage?
    /// emptyImage
    public var emptyImage = true
    /// underlyingImage
    public var underlyingImage: UIImage?
    public var placeholderImage: UIImage?
    private var asset: PHAsset?
    private var assetTargetSize = CGSize.zero
    
    private var loadingInProgress = false
    private var operation: SDWebImageOperation?
    private var assetRequestID = PHInvalidImageRequestID

    /// init with image
    public convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    /// init with image and caption
    public convenience init(image: UIImage, caption: String) {
        self.init()
        self.image = image
        self.caption = caption
    }
    
    /// init with image and caption
    public convenience init(caption: String, isVideo: Bool) {
        self.init()
        self.caption = caption
        self.isVideo = isVideo
    }

    /// init with PHAsset and targetSize
    public convenience init(asset: PHAsset) {
        self.init()
        self.asset = asset
        isVideo = asset.mediaType == PHAssetMediaType.video
    }
    
    /// init with temporaryPath
    public convenience init(temporaryPath: String, isVideo: Bool = false) {
        self.init()
        self.temporaryPath = temporaryPath
        self.isVideo = isVideo
    }

    func getMediaURL(completion: @escaping (URL?) -> ()) {
        if let a = asset {
            if a.mediaType == PHAssetMediaType.video {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestAVAsset(
                    forVideo: a,
                    options: options,
                    resultHandler: { asset, audioMix, info in
                        if let urlAsset = asset as? AVURLAsset {
                            completion(urlAsset.url)
                        } else {
                            completion(nil)
                        }
                })
            } else if a.mediaType == .image {
                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                    return true
                }
                a.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                    completion(contentEditingInput!.fullSizeImageURL)
                })
            } else {
                completion(nil)
            }
        } else if caption.count > 0, let vurl = self.photoURL {
            completion(vurl)
        } else {
            completion(nil)
        }
    }

    //MARK: - Photo Protocol Methods
    func loadUnderlyingImageAndNotify() {
        if loadingInProgress {
            return
        }
        
        loadingInProgress = true
        
        if underlyingImage != nil {
            imageLoadingComplete()
        } else {
            performLoadUnderlyingImageAndNotify()
        }
    }

    // Set the underlyingImage
    func performLoadUnderlyingImageAndNotify() {
        // Get underlying image
        if let img = image {
            // We have UIImage!
            underlyingImage = img
            imageLoadingComplete()
        } else if let purl = photoURL {
            // Check what type of url it is
            if purl.scheme?.lowercased() == "assets-library" {
                // Load from assets library
                performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(url: purl)
            } else if purl.isFileURL {
                // Load from local file async
                performLoadUnderlyingImageAndNotifyWithLocalFileURL(url: purl)
            } else {
                // Load async from web (using SDWebImage)
                performLoadUnderlyingImageAndNotifyWithWebURL(url: purl)
            }
        } else if let a = asset {
            // Load from photos asset
            performLoadUnderlyingImageAndNotifyWithAsset(asset: a, targetSize: assetTargetSize)
        } else {
            // Image is empty
            imageLoadingComplete()
        }
    }

    // Load from local file
    private func performLoadUnderlyingImageAndNotifyWithWebURL(url: URL) {
        operation = SDWebImageManager.shared().loadImage(with: url, options: [], progress: { (receivedSize, expectedSize, targetURL) in
            let dict = [
                "progress" : min(1.0, CGFloat(receivedSize)/CGFloat(expectedSize)),
                "photo" : self
                ] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MEDIA_PROGRESS_NOTIFICATION), object: dict)
            
        }) { [weak self] (image, _, error, cacheType, finish, imageUrl) in
            guard let wself = self else { return }
            
            DispatchQueue.main.async {
                if let _image = image {
                    wself.underlyingImage = _image
                }
                
                DispatchQueue.main.async() {
                    wself.imageLoadingComplete()
                }
            }
        }
    }
    
    // Load from local file
    private func performLoadUnderlyingImageAndNotifyWithLocalFileURL(url: URL) {
        if self.isVideo {
            DispatchQueue.global(qos: .default).async {
                let asset = AVAsset(url: url)
                let image: UIImage? = asset.videoThumbnail
                DispatchQueue.main.async() {[weak self] in
                    guard let self = self else {return }
                    self.underlyingImage = image
                    self.imageLoadingComplete()
                }
            }
        } else {
            DispatchQueue.global(qos: .default).async {
                ImageFetcher.fetchImageURL(url, completion: { (image) in
                    DispatchQueue.main.async() {[weak self] in
                        guard let self = self else {return }
                        self.underlyingImage = image
                        self.imageLoadingComplete()
                    }
                })
            }
        }
    }
    
    // Load from asset library async
    private func performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(url: URL) {
        if #available(iOS 11, *) {
            
        } else {
            DispatchQueue.global(qos: .default).async {
                let result = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                if let asset = result.lastObject {
                    self.performLoadUnderlyingImageAndNotifyWithAsset(asset: asset, targetSize: self.assetTargetSize)
                }
            }
        }
    }

    // Load from photos library
    private func performLoadUnderlyingImageAndNotifyWithAsset(asset: PHAsset, targetSize: CGSize) {
        let imageManager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.progressHandler = { progress, error, stop, info in
            let dict = [
                "progress" : progress,
                "photo" : self
            ] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MEDIA_PROGRESS_NOTIFICATION), object: dict)
        }
        
        assetRequestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: PHImageContentMode.aspectFit,
            options: options,
                resultHandler: { result, info in
                DispatchQueue.main.async() {
                    self.underlyingImage = result
                    self.imageLoadingComplete()
                }
            })
    }

    /// Release if we can get it again from path or url
    public func unloadUnderlyingImage() {
        loadingInProgress = false
        underlyingImage = nil
    }

    private func imageLoadingComplete() {
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")
        
        // Complete so notify
        loadingInProgress = false
        
        // Notify on next run loop
        DispatchQueue.main.async() {
            self.postCompleteNotification()
        }
    }

    private func postCompleteNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: MEDIA_LOADING_DID_END_NOTIFICATION),
            object: self)
    }
    
    /// Cancel loading
    public func cancelAnyLoading() {
        if let op = self.operation {
            op.cancel()
            loadingInProgress = false
        } else if assetRequestID != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(assetRequestID)
            assetRequestID = PHInvalidImageRequestID
        }
    }
    
    func equals(photo: Media) -> Bool {
        return uuid == photo.uuid
    }
}
