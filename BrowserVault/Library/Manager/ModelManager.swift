//
//  ModelManager.swift
//  VintageCulture
//
//  Created by Hai Le on 2/26/18.
//  Copyright © 2018 Evizi. All rights reserved.
//
import RealmSwift
import RxSwift

class ModelManager {
    static var shared = ModelManager()
    lazy var bag = DisposeBag()
    
    init() {
        DispatchQueue.main.async {[weak self] in
            self?.setupData()
        }
    }
    
    func setupData() {
        let predicate = NSPredicate(format: "isLibrary == %@", NSNumber(value: true))
        if self.fetchList(FolderModel.self, filter: predicate).count < 1 {
            let model = self.generateLibraryFolder()
            self.addObject(model)
        }
    }
    
    
    func generateLibraryFolder() -> FolderModel {
        let folder = FolderModel()
        folder.isLibrary = true
        folder.name = "Library"
        return folder
    }
    
    var libraryFolder: FolderModel! {
        let predicate = NSPredicate(format: "isLibrary == %@", NSNumber(value: true))
        var folder = self.fetchList(FolderModel.self, filter: predicate).first
        if folder == nil {
            folder = self.generateLibraryFolder()
            self.addObject(folder!)
        }
        return folder
    }
    
    func fetchList<T: Object>(_ type: T.Type) -> [T] {
        return realm.objects(type).map({$0})
    }
    
    func fetchList<T: Object>(_ type: T.Type, filter predicate: NSPredicate) -> [T] {
        return realm.objects(type).filter(predicate).map({$0})
    }
    
    func fetchObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func fetchObjects<T: Object>(_ type: T.Type, predicate: String) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchObjects<T: Object>(_ type: T.Type, filter predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchObject<T: Object>(_ type: T.Type, filter predicate: NSPredicate) -> T? {
        let results: Results<T> = realm.objects(type).filter(predicate)
        if results.count > 0 {
            return results.first
        }
        return nil
    }
    
    func fetchObject<T: Object>(_ type: T.Type) -> T? {
        let results: Results<T> = realm.objects(type)
        if results.count > 0 {
            return results.first
        }
        return nil
    }
    
    func createObject<T: Object>(_ type: T.Type, value: T) {
        realm.beginWrite()
        realm.create(type, value: value)
        realm.commitWriting()
    }
    
    func addObject<T: Object>(_ object: T) {
        realm.beginWrite()
        realm.add(object, update: true)
        realm.commitWriting()
    }
    
    func updateObject(_ block:() -> ()) {
        try! realm.write {
            block()
        }
    }
    
    func deleteObject<T: Object>(_ object: T) {
        guard object != self.libraryFolder else {
            return
        }
        realm.beginWrite()
        realm.delete(object)
        realm.commitWriting()
    }
    
    func deleteObjects<T: Object>(_ objects: [T]) {
        realm.beginWrite()
        realm.delete(objects)
        realm.commitWriting()
    }

    func deleteAllObjects<T: Object>(_ type: T.Type) {
        try! realm.write {
            realm.delete(realm.objects(type))
        }
    }
}

extension ModelManager {
    func fetchMediaByFolder(_ folder: FolderModel) -> [Media] {
        let medias = self.fetchList(Media.self).filter({$0.folder?.id == folder.id})
        return medias
    }
    
    func subscriberAddMedias(_ medias: [Media], inFolder folder: FolderModel? = nil, handler: @escaping ([Media]) -> ()) {
        if let folder = folder {
            self.addObject(folder)
        }
        let folder = folder ?? self.libraryFolder
        for index in 0..<medias.count {
            let media = medias[index]
            let url = URL(fileURLWithPath: media.temporaryPath!)
            
            self.addObject(media)
            self.updateObject {
                media.folder = folder
            }
            if let localURL = media.photoURL {
                DocumentManager.shared.moveMediaFromURL(url, toURL: localURL)
            }
        }
        let localMedias = self.fetchMediaByFolder(folder!)
        handler(localMedias)
    }
}
