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
    
    var fileNameNoExtension: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd' at 'HH:mm:ss"
        let fileName = dateFormater.string(from: Date())
        return fileName
    }
    
    var imageURL: URL {
        let imageURL = documentURL.appendingPathComponent("Images")
        if !fileManger.fileExists(atPath: imageURL.path) {
            try? fileManger.createDirectory(atPath: imageURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return imageURL
    }
    
    var videoURL: URL {
        let videoURL = documentURL.appendingPathComponent("Videos")
        if !fileManger.fileExists(atPath: videoURL.path) {
            try? fileManger.createDirectory(atPath: videoURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return videoURL
    }
    
    func saveImage(image: UIImage, to fileURL: URL) {
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
    
    func copyMediaFromURL(_ url: URL, toURL: URL) {
        try? fileManger.copyItem(at: url, to: toURL)
    }
    
    func moveMediaFromURL(_ url: URL, toURL: URL) {
        try? fileManger.moveItem(at: url, to: toURL)
    }
}

extension DocumentManager {
    func saveCoverFolder(_ folder: FolderModel) -> URL? {
        let pathName = "\(folder.name).jpeg"
        let fileURL = folder.folderURL.appendingPathComponent(pathName)
        if let urlString = folder.url, let url = URL(string: urlString) {
            try? fileManger.copyItem(at: url, to: fileURL)
        } else if let image = folder.image {
            self.saveImage(image: image, to: fileURL)
        } else {
            return nil
        }
        return fileURL
    }
    
    func deleteFolder(_ folder: FolderModel) {
        if fileManger.fileExists(atPath: folder.folderURL.path) {
            try? fileManger.removeItem(at: folder.folderURL)
        }
    }
}
