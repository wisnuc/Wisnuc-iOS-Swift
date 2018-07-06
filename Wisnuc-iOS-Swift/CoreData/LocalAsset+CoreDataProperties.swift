//
//  LocalAsset+CoreDataProperties.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//
//

import Foundation
import CoreData


extension LocalAsset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalAsset> {
        return NSFetchRequest<LocalAsset>(entityName: "LocalAsset")
    }

    @NSManaged public var digest: String?
    @NSManaged public var localId: String?

}
