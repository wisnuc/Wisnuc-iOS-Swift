//
//  CoreDataOperation.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import SugarRecord
import CoreData

class CoreDataOperation: NSObject {
    func coreDataStorage(name:String) -> CoreDataDefaultStorage {
        let store = CoreDataStore.named(name)
        let bundle = Bundle(for: self.classForCoder)
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }
    
 
   
    static func cloneObject(source :NSManagedObject, context :NSManagedObjectContext) -> NSManagedObject{
        let entityName = source.entity.name
        let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName!, into: context)
        
        let attributes = NSEntityDescription.entity(forEntityName: entityName!, in: context)?.attributesByName
        
        for (key,_) in attributes! {
            cloned.setValue(source.value(forKey: key), forKey: key)
        }
        
        let relationships = NSEntityDescription.entity(forEntityName: entityName!, in: context)?.relationshipsByName
        for (key,_) in relationships! {
            let sourceSet = source.mutableSetValue(forKey: key)
            let clonedSet = cloned.mutableSetValue(forKey: key)
            let e = sourceSet.objectEnumerator()
            
            var relatedObj = e.nextObject() as? NSManagedObject
            
            while ((relatedObj) != nil) {
                let clonedRelatedObject = CoreDataOperation.cloneObject(source: relatedObj!, context: context)
                clonedSet.add(clonedRelatedObject)
                relatedObj = e.nextObject() as? NSManagedObject
            }
        }
        
        return cloned
    }

}

