//
//  CoreDataExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject{
    func shallowCopy() -> NSManagedObject? {
        guard let context = managedObjectContext, let entityName = entity.name else { return nil }
        let copy = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        let attributes = entity.attributesByName
        for (attrKey, _) in attributes {
            copy.setValue(value(forKey: attrKey), forKey: attrKey)
        }
        return copy
    }
}



