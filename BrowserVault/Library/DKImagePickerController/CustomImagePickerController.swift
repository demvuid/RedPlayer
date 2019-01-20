//
//  CustomImagePickerController.swift
//  BrowserVault
//
//  Created by HaiLe on 1/28/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import DKImagePickerController

typealias ImportMediasResult = [(Media, URL)]
class CustomImagePickerController: DKImagePickerController {

    class func presentPickerInTarget(_ target: UIViewController?, completion: ((ImportMediasResult) -> ())? = nil) {
        let pickerController = CustomImagePickerController()
        pickerController.showsCancelButton = true
        pickerController.exportsWhenCompleted = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var medias = ImportMediasResult()
            for asset in assets {
                guard asset.error == nil else { continue }
                if let localPath = asset.localTemporaryPath {
                    let media = Media(asset: asset.originalAsset!)
                    media.caption = localPath.lastPathComponent
                    medias.append((media, localPath))
                }
            }
            completion?(medias)
        }
        let controller = target ?? UIApplication.shared.keyWindow?.rootViewController
        controller?.present(pickerController, animated: true) {}
    }

}
