//
//  CustomImagePickerController.swift
//  BrowserVault
//
//  Created by HaiLe on 1/28/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import DKImagePickerController

class CustomImagePickerController: DKImagePickerController {

    class func presentPickerInTarget(_ target: UIViewController?, completion: (([Media]) -> ())? = nil) {
        let pickerController = CustomImagePickerController()
        pickerController.showsCancelButton = true
        pickerController.exportsWhenCompleted = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var medias = [Media]()
            for asset in assets {
                guard asset.error == nil else { continue }
                if let localPath = asset.localTemporaryPath {
                    let media = Media(asset: asset.originalAsset!)
                    media.caption = localPath.lastPathComponent
                    media.temporaryPath = localPath.path
                    medias.append(media)
                }
            }
            completion?(medias)
        }
        let controller = target ?? UIApplication.shared.keyWindow?.rootViewController
        controller?.present(pickerController, animated: true) {}
    }

}
