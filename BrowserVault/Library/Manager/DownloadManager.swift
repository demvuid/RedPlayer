//
//  DownloadManager.swift
//  BrowserVault
//
//  Created by HaiLe on 1/30/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import MZDownloadManager
import Eureka
import RxSwift
import RxCocoa

class DownloadManager {
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.amplayer.browservault.BackgroundSession"
        var completion = (UIApplication.shared.delegate as? AppDelegate)?.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
    }()
    
    var downloadsSubject = PublishSubject<(MZDownloadModel, Bool, Bool, Bool, Int)>()
    var mediaSubject = PublishSubject<Media>()
    let bag = DisposeBag()
    
    static let shared = DownloadManager()
    
    func downloadURL(_ fileURL: URL, name: String? = nil) {
        var fileName = fileURL.lastPathComponent
        if fileURL.pathExtension.replacingOccurrences(of: " ", with: "") == "" {
            fileName = "\(fileName).mp4"
        }
        if let name = name {
            if name.fileExtension() == "" {
                fileName = "\(name).mp4"
            } else {
                fileName = name
            }
        }
        fileName = MZUtility.getUniqueFileNameWithPath(myDownloadURL.appendingPathComponent(fileName).path as NSString) as String
        
        self.downloadManager.addDownloadTask(fileName, fileURL: fileURL.absoluteString, destinationPath: myDownloadURL.path)
    }
    
    func numberItemsDownload() -> Int {
        return self.downloadManager.downloadingArray.count
    }
    
    func addSubscriberDownloadModel(_ model: MZDownloadModel, isAdd: Bool = false, isUpdate: Bool = false, isFinish: Bool = false, index: Int = 0) {
        downloadsSubject.onNext((model, isAdd, isUpdate, isFinish, index))
    }
    
    func addHandlerSubscriberDownloadModel(_ handler: @escaping (MZDownloadModel, Bool, Bool, Bool, Int) -> ()) {
        self.downloadsSubject.asObservable().subscribe(onNext: { (model, isAdd, isUpdate, isFinish, index) in
            handler(model, isAdd, isUpdate, isFinish, index)
        }).disposed(by: self.bag)
    }
    
    func addHandlerDownloadedMedia(_ handler: @escaping (Media) -> ()) {
        self.mediaSubject.asObservable().subscribe(onNext: { media in
            handler(media)
        }).disposed(by: self.bag)
    }
}

protocol DownloadFormViewProtocol {
    func configRow(_ row: TextRow, atIndex index: Int)
    func handlerSubscriberDownloadModel(_ handler: @escaping (String?, Bool, Bool, Bool) -> ())
}

extension DownloadFormViewProtocol where Self: BaseFormViewController {
    func configRow(_ row: TextRow, atIndex index: Int) {
        row.cellStyle = .subtitle
        let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
        let tag = "index_\(index)"
        row.tag = tag
        row.title = "Downloading \(downloadModel.fileName ?? "") ..."
        let updateDetailDescription = { (model: MZDownloadModel) in
            var remainingTime: String = ""
            if model.progress == 1.0 {
                remainingTime = "Please wait..."
            } else if let _ = model.remainingTime {
                if (model.remainingTime?.hours)! > 0 {
                    remainingTime = "\(model.remainingTime!.hours) Hours "
                }
                if (model.remainingTime?.minutes)! > 0 {
                    remainingTime = remainingTime + "\(model.remainingTime!.minutes) Min "
                }
                if (model.remainingTime?.seconds)! > 0 {
                    remainingTime = remainingTime + "\(model.remainingTime!.seconds) sec"
                }
                if remainingTime == "" {
                    remainingTime = "Please wait..."
                } else {
                    remainingTime = "Time Left: \(remainingTime)"
                }
            } else {
                remainingTime = "Calculating..."
            }
            row.value = remainingTime
            row.reload()
        }
        updateDetailDescription(downloadModel)
        let progressView: ProgressView = ProgressView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        progressView.animationStyle = CAMediaTimingFunctionName.linear.rawValue
        progressView.font = UIFont.boldSystemFont(ofSize: 13)
        var progress = CGFloat(downloadModel.progress) * 100.0
        if progress > 100 {
            progress = 100
        }
        progressView.setProgress(value: progress, animationDuration: 0)
        row.baseCell.accessoryView = progressView
        row.baseCell.accessoryType = .none
    }
    
    func handlerSubscriberDownloadModel(_ handler: @escaping (String?, Bool, Bool, Bool) -> ()) {
        DownloadManager.shared.addHandlerSubscriberDownloadModel { (model, isAdd, isUpdate, isFinish, index) in
            let tag = "index_\(index)"
            handler(tag, isAdd, isUpdate, isFinish)
        }
    }
}

extension DownloadManager: MZDownloadManagerDelegate {
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isAdd: true, index: index)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isUpdate: true, index: index)
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isUpdate: true, index: index)
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isUpdate: true, index: index)
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
        
        let fileName = downloadModel.fileName
        var basePath = downloadModel.destinationPath == "" ? MZUtility.baseFilePath : downloadModel.destinationPath
        basePath = basePath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? basePath
        if let destinationPath = URL(string: basePath)?.appendingPathComponent(fileName!) {
            let media = Media(temporaryPath: destinationPath.path, isVideo: true)
            media.caption = fileName ?? destinationPath.lastPathComponent
            self.mediaSubject.onNext(media)
        }
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
