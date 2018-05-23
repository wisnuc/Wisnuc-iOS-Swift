//
//  CoreDataOperation.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import SugarRecord
class CoreDataOperation: NSObject {
    func coreDataStorage(name:String) -> CoreDataDefaultStorage {
        let store = CoreDataStore.named(name)
        let bundle = Bundle(for: self.classForCoder)
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }
    
//    func save(x:Void,){
//        let db = coreDataStorage(name: <#String#>)
//        do {
//            try db.operation { (context, save) throws in
//                // Do your operations here
//                x
//                save()
//            }
//        } catch {
//            // There was an error in the operation
//        }
//    }
}

