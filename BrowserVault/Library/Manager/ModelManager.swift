//
//  ModelManager.swift
//  VintageCulture
//
//  Created by Hai Le on 2/26/18.
//  Copyright © 2018 Evizi. All rights reserved.
//
import RealmSwift

class ModelManager {
    static var shared = ModelManager()
    
    func fetchList<T: BaseModel>(_ type: T.Type) -> [T] {
        return realm.objects(type).map({$0})
    }
    
    func fetchList<T: BaseModel>(_ type: T.Type, filter predicate: NSPredicate) -> [T] {
        return realm.objects(type).filter(predicate).map({$0})
    }
    
    func fetchObjects<T: BaseModel>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func fetchObjects<T: BaseModel>(_ type: T.Type, predicate: String) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchObjects<T: BaseModel>(_ type: T.Type, filter predicate: NSPredicate) -> Results<T> {
        return realm.objects(type).filter(predicate)
    }
    
    func fetchObject<T: BaseModel>(_ type: T.Type, filter predicate: NSPredicate) -> T? {
        let results: Results<T> = realm.objects(type).filter(predicate)
        if results.count > 0 {
            return results.first
        }
        return nil
    }
    
    func fetchObject<T: BaseModel>(_ type: T.Type) -> T? {
        let results: Results<T> = realm.objects(type)
        if results.count > 0 {
            return results.first
        }
        return nil
    }
    
    func createObject<T: BaseModel>(_ type: T.Type, value: T) {
        realm.beginWrite()
        realm.create(type, value: value)
        realm.commitWriting()
    }
    
    func addObject<T: BaseModel>(_ object: T) {
        realm.beginWrite()
        realm.add(object, update: true)
        realm.commitWriting()
    }
    
    func updateObject(_ block:() -> ()) {
        try! realm.write {
            block()
        }
    }
    
    func deleteObject<T: BaseModel>(_ object: T) {
        realm.beginWrite()
        realm.delete(object)
        realm.commitWriting()
    }

    func deleteAllObjects<T: BaseModel>(_ type: T.Type) {
        try! realm.write {
            realm.delete(realm.objects(type))
        }
    }
}
