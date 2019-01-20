//
//  DownloadManager.swift
//  BrowserVault
//
//  Created by HaiLe on 1/30/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import MZDownloadManager

class DownloadManager {
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.amplayer.browservault.BackgroundSession"
        var completion = (UIApplication.shared.delegate as? AppDelegate)?.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
    }()
    static let shared = DownloadManager()
    
    func downloadURL(_ fileURL: URL) {
        var fileName = fileURL.lastPathComponent
        fileName = MZUtility.getUniqueFileNameWithPath(myDownloadURL.appendingPathComponent(fileName).path as NSString) as String
        self.downloadManager.addDownloadTask(fileName, fileURL: fileURL.absoluteString, destinationPath: myDownloadURL.path)
    }
}

extension DownloadManager: MZDownloadManagerDelegate {
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        
        
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        
        
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        if !fileManger.fileExists(atPath: myDownloadURL.path) {
            try? fileManger.createDirectory(atPath: myDownloadURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath(myDownloadURL.appendingPathComponent(downloadModel.fileName).path as NSString) as String
        try? fileManger.moveItem(at: location, to: myDownloadURL.appendingPathComponent(fileName))
    }
}
