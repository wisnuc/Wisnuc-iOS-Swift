//
//  User+CoreDataProperties.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/22.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var localToken: String?
    @NSManaged public var uuid: String?
    @NSManaged public var cloudToken: String?
    @NSManaged public var avaterURL: String?
    @NSManaged public var userName: String?
}
