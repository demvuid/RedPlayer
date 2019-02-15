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
import UICircularProgressRing

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
    
    func downloadURL(_ fileURL: URL, name: String? = nil, inFolder folder: FolderModel? = nil, handler: (() ->())? = nil) {
        var fileName = fileURL.lastPathComponent
        if let name = name {
            fileName = name
        }
        fileName = fileName.replacingOccurrences(of: " ", with: "")
        fileName = MZUtility.getUniqueFileNameWithPath(myDownloadURL.appendingPathComponent(fileName).path as NSString) as String
        
        self.downloadManager.addDownloadTask(fileName, fileURL: fileURL.absoluteString, destinationPath: myDownloadURL.path)
        
        self.addHandlerDownloadedMedia {media in
            if media.caption.isMediaFileExtension || media.caption.isImageFileExtension {
                ModelManager.shared.subscriberAddMedias([media], inFolder: folder, handler: { (_) in
                    handler?()
                })
            } else {
                UIApplication.topViewController()?.showAlertWith(title: "Invalid File", messsage: "Sorry, this is not a media file to support.\nPlease check your file has an extension is media.")
            }
        }
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
    func configRow(_ row: LabelRow, atIndex index: Int)
    func showAppropriateActionController(atIndex index: Int)
    func handlerSubscriberDownloadModel(_ handler: @escaping (Int, Bool, Bool, Bool) -> ())
}

extension DownloadFormViewProtocol where Self: BaseFormViewController {
    func configRow(_ row: LabelRow, atIndex index: Int) {
        if index < DownloadManager.shared.downloadManager.downloadingArray.count {
            let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
            let title = "Downloading \(downloadModel.fileName ?? "") ..."
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
                if let size = downloadModel.downloadedFile?.size {
                    let downloadedFileSize = String(format: "%.2f %@", size, (downloadModel.downloadedFile?.unit)!)
                    row.value = "\(remainingTime) - Downloaded: \(downloadedFileSize)"
                } else {
                    row.value = remainingTime
                }
            }
            updateDetailDescription(downloadModel)
            
            if downloadModel.status == TaskStatus.gettingInfo.description() {
                row.title = "Prepare \(title)"
            } else if downloadModel.status == TaskStatus.paused.description() || downloadModel.status == TaskStatus.failed.description() {
                row.title = "\(downloadModel.status) \(title)"
            } else {
                row.title = title
            }
            row.cell.textLabel?.text = row.title
            row.cell.detailTextLabel?.text = row.value
            var progress = CGFloat(downloadModel.progress) * 100.0
            if progress > 100 {
                progress = 100
            }
            if let progressRing = row.baseCell.accessoryView as? UICircularProgressRing {
                progressRing.startProgress(to: progress, duration: 0)
            } else {
                let progressRing = UICircularProgressRing(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                progressRing.backgroundColor = .white
                progressRing.outerRingColor = ColorName.mainColor
                progressRing.innerRingColor = .white
                progressRing.outerRingWidth = 10
                progressRing.innerRingWidth = 8
                progressRing.ringStyle = .ontop
                progressRing.font = AppBranding.boldFont
                progressRing.startProgress(to: progress, duration: 0)
                row.baseCell.accessoryView = progressRing
                row.baseCell.accessoryType = .none
            }
        }
    }
    
    func showAlertControllerForPause(atIndex index: Int) {
        var items = [AlertActionItem]()
        var item = AlertActionItem(title: "Pause", style: .default, handler: { _ in
            DownloadManager.shared.downloadManager.pauseDownloadTaskAtIndex(index)
        })
        items.append(item)
        item = AlertActionItem(title: "Remove", style: .destructive, handler: { _ in
            DownloadManager.shared.downloadManager.cancelTaskAtIndex(index)
            if index < DownloadManager.shared.downloadManager.downloadingArray.count {
                let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
                DownloadManager.shared.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
                DownloadManager.shared.downloadManager.downloadingArray.remove(at: index)
            }
        })
        items.append(item)
        
        item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
        items.append(item)
        self.showActionSheet(items: items)
    }
    
    func showAlertControllerForRetry(atIndex index: Int) {
        var items = [AlertActionItem]()
        var item = AlertActionItem(title: "Retry", style: .default, handler: { _ in
            DownloadManager.shared.downloadManager.retryDownloadTaskAtIndex(index)
        })
        items.append(item)
        item = AlertActionItem(title: "Remove", style: .destructive, handler: { _ in
            DownloadManager.shared.downloadManager.cancelTaskAtIndex(index)
            if index < DownloadManager.shared.downloadManager.downloadingArray.count {
                let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
                DownloadManager.shared.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
                DownloadManager.shared.downloadManager.downloadingArray.remove(at: index)
            }
        })
        items.append(item)
        
        item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
        items.append(item)
        self.showActionSheet(items: items)
    }
    
    func showAlertControllerForStart(atIndex index: Int) {
        var items = [AlertActionItem]()
        var item = AlertActionItem(title: "Start", style: .default, handler: { _ in
            DownloadManager.shared.downloadManager.resumeDownloadTaskAtIndex(index)
        })
        items.append(item)
        item = AlertActionItem(title: "Remove", style: .destructive, handler: { _ in
            DownloadManager.shared.downloadManager.cancelTaskAtIndex(index)
            if index < DownloadManager.shared.downloadManager.downloadingArray.count {
                let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
                DownloadManager.shared.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
                DownloadManager.shared.downloadManager.downloadingArray.remove(at: index)
            }
        })
        items.append(item)
        
        item = AlertActionItem(title: L10n.Generic.Button.Title.cancel, style: .cancel, handler: nil)
        items.append(item)
        self.showActionSheet(items: items)
    }
    
    func showAppropriateActionController(atIndex index: Int) {
        if index < DownloadManager.shared.downloadManager.downloadingArray.count {
            let downloadModel = DownloadManager.shared.downloadManager.downloadingArray[index]
            let requestStatus = downloadModel.status
            if requestStatus == TaskStatus.downloading.description() {
                self.showAlertControllerForPause(atIndex: index)
            } else if requestStatus == TaskStatus.failed.description() {
                self.showAlertControllerForRetry(atIndex: index)
            } else if requestStatus == TaskStatus.paused.description() {
                self.showAlertControllerForStart(atIndex: index)
            }
        }
    }
    
    func handlerSubscriberDownloadModel(_ handler: @escaping (Int, Bool, Bool, Bool) -> ()) {
        DownloadManager.shared.addHandlerSubscriberDownloadModel { (model, isAdd, isUpdate, isFinish, index) in
            handler(index, isAdd, isUpdate, isFinish)
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
        NavigationManager.shared.updateStatusBanner()
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isFinish: true, index: index)
        let fileName = downloadModel.fileName
        var basePath = downloadModel.destinationPath == "" ? MZUtility.baseFilePath : downloadModel.destinationPath
        basePath = basePath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? basePath
        
        if let destinationPath = URL(string: basePath)?.appendingPathComponent(fileName!) {
            let media = Media(temporaryPath: destinationPath.path, isVideo: true)
            media.caption = fileName ?? destinationPath.lastPathComponent
            if let mimeType = downloadModel.task?.response?.mimeType, let ext = MimeType(mimeType: mimeType).ext {
                let fileExtension = media.caption.fileExtension()
                if fileExtension == "" {
                    media.caption = "\(media.caption).\(ext)"
                } else {
                    media.caption = media.caption.replacingOccurrences(of: fileExtension, with: ext)
                }
                if media.caption.isImageFileExtension {
                    media.isVideo = false
                }
            }
            self.mediaSubject.onNext(media)
        }
        NavigationManager.shared.updateStatusBanner()
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        self.addSubscriberDownloadModel(downloadModel, isUpdate: true, index: index)
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
