//
//  DocumentManager.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/6/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class DocumentManager {
    static var shared = DocumentManager()
    
    var imageURL: URL {
        let imageURL = documentPathURL.appendingPathComponent("Images")
        if !fileManger.fileExists(atPath: imageURL.path) {
            try! fileManger.createDirectory(atPath: imageURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return imageURL
    }
    
    func imageURL(fileName: String) -> URL {
        return imageURL.appendingPathComponent(fileName)
    }
    
    func saveImage(image: UIImage, to fileURL: URL) {
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}

extension DocumentManager {
    func saveCoverFolder(_ folder: FolderModel) -> URL? {
        if let urlString = folder.url, let url = URL(string: urlString) {
            var pathName = url.lastPathComponent
            if url.pathExtension.count <= 0 {
                pathName = "\(UUID().uuidString).png"
            }
            let fileURL = DocumentManager.shared.imageURL(fileName: pathName)
            do {
                try fileManger.copyItem(at: url, to: fileURL)
                return fileURL
            } catch let error {
                Logger.debug("write file error:\(error.localizedDescription)")
            }
        } else if let image = folder.image {
            let fileURL = DocumentManager.shared.imageURL(fileName: "\(UUID().uuidString).png")
            self.saveImage(image: image, to: fileURL)
            return fileURL
        }
        return nil
    }
}
